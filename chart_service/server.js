var http = require("http");
var url = require("url");
var jsdom = require("jsdom").jsdom();
var fs = require("fs");
var querystring = require("querystring");
var exec = require("child_process").exec;

var decoder_configuration = require("./decoder_configuration.js");
	// options.secret_key_base = process.env.USER;	//we can set here secret_key_base
var cookieDecoder = require("cookieDecoder")(decoder_configuration);
var ChartsMap = require("./service.js")();	//TODO - zienic zeby modul eksportowal mape a nie funkcje, albo przekazywac handlery
var DataRetriever = require("./data_retriever.js");

var jade = require("jade");
var locals = require("./config.js");

var PORT = 8080,
	EXTERNAL_IP = "172.16.67.121",			//TODO - retrieve external IP
	ADDRESS = EXTERNAL_IP + "/chart";		//address suffix set in /etc/nginx/conf.d/default.conf

var app = http.createServer(function(req, res) {
	var parsedUrl = url.parse(req.url);
	var pathname = parsedUrl.pathname;
	var parameters = querystring.parse(parsedUrl.query);
	console.log("Pathname: " + pathname);
	console.log("Parameters: " + JSON.stringify(parameters));

	//TODO - jak nie tworzyc mapy za kazdym razem? -> wystarczy zmieniac tylko map["/panel"] ALBO parameters jako dodatkowy argument map[...](..., parameters)
	var map = prepare_map_with_requests(parameters);

	var path = pathname.split("/")[1];
	if(map[path]){
		map[path](req, res, pathname);
	}
	else if(ChartsMap["/"+path]) {
		ChartsMap["/"+path](parameters, function(object) {
			authenticate(req.headers.cookie, parameters["id"], function(data) {
				console.log("OK! Successfully authorized.");
				res.writeHead(200, {'Content-Type': 'text/plain'});
				var output = jade.renderFile("."+pathname+pathname+"Chart.jade", parameters);
				output += object.content;
				res.write(output);
				res.end();
			}, function(err) {
				console.log("FAILED! Sending info about error to Scalarm... \n" + err);
				res.write("Unable to authenticate");
				res.end();
			});
		}, function(err) {
			res.write(err);
			res.end();
			return;
		});
	}
	else {	//when URL doesn't match => incorrect request
		res.writeHead(404);
		res.write(pathname + " : incorrect request!");
		res.end();
	}
})
DataRetriever.connect(function(){
	app.listen(PORT, function(){
		console.log(new Date() + " Listening on port " + PORT);
	});
}, function(){
	console.log("Connection to database failed");
	throw new Error("Connection to database failed");
})

var WebSocketServer = require('websocket').server;
wsServer = new WebSocketServer({
	httpServer: app
})

wsServer.on('request', function(request) {
	//TODO -- authentication!
	console.log(new Date() + " Connection from origin " + request.origin + ".");
	var experimentID = request.httpRequest.url.slice(1);
	authenticate(request.httpRequest.headers.cookie, experimentID, function(data) {
		console.log("OK! Successfully authorized.");
		var connection = request.accept(null, request.origin);
		console.log(new Date() + " Connection accepted.");

		connection.on('close', function(connection) {
	        console.log(new Date() + " Connection closed");
	        //TODO - close cursor?
	    });

		DataRetriever.createStreamFor(connection, experimentID);
	}, function(err) {
		console.log("Authentication failed! \n" + err);
	});
});

//--------------------------------
function authenticate(cookie, experimentID, success, error){
	//what if there are more cookies??
	var cookieGood = cookie.substr(17, cookie.length); //MAGIC NUMBER! :D (just for remove _scalarm_session= from the beginning)
	var output = cookieDecoder(cookieGood);

	exec("ruby serialized_object_to_json.rb " + new Buffer(output).toString("base64"), function(err, stdout, stderr) {
	    if (err !== null) {
	    	console.log('stderr: ' + stderr);
	    	console.log('exec error: ' + err);
	    	error(err);
	    	return;
	    }

		var userID = JSON.parse(stdout)["user"];
		console.log("\tuserID: ", userID); 
		console.log("\texperimentID: ", experimentID);

		DataRetriever.authenticate(userID, experimentID, function(dataSuccess) {
			success(dataSuccess);
		}, function(dataError) {
			error(dataError);
		});
	});
}

function prepare_script_and_style_tags(typeOfChart) {
	var tags = {};
	tags.script_tag_main = jsdom.createElement("script");
	tags.script_tag_main.setAttribute("type", "text/javascript");
	tags.script_tag_main.setAttribute("src","//" + ADDRESS +"/main"+ typeOfChart);

	for(var prop in tags) {
		tags[prop] = tags[prop].outerHTML;
	}

    return tags;
}

function prepare_map_with_requests(parameters) {
	var map = {};
	map["panel"] = function(req, res){
		DataRetriever.getParameters(parameters["id"], function(data) {
			locals.parameters = data.parameters;
			locals.output = data.result;
			locals.address = ADDRESS;
			res.writeHead(200);
			var panel = jade.renderFile("panel.jade", locals);
			res.write(panel);
			res.end();
		},
		function(err) {
			res.writeHead(404);
			res.write("Error getting parameters\n");
			res.write(err+"\n");
			res.end();
		})
	};

	map["images"] = function(req, res, pathname) {
		fs.readFile('.'+pathname, function(error, data) {
			if(error) {
				res.writeHead(404);
				res.write("File " + file_path + " : not found!\n");
				res.write(error.toString());
				res.end();
			}
			else {
				res.writeHead(200);
				res.write(data);
				res.end();
			}
		});
	};

	map["main"] = function(req, res, pathname){
		var type = pathname.split("/")[2];
		var resource = pathname.split("/")[1];

		var file_path = type+"/"+type+"_chart_"+resource;
		file_path += resource==="style" ? ".css" : ".js";

		fs.readFile(file_path, function(error, data) {
			if(error) {
				res.writeHead(404);
				res.write("File " + file_path + " : not found!\n");
				res.write(error.toString());
				res.end();
				return;
			}
			else {
				res.writeHead(200);
				res.write(data);
				res.end();
				return;
			}
		});
	};

	map["scripts"] = function(req, res, pathname){
		var chart_type = pathname.split("/")[2];
		var tags = prepare_script_and_style_tags("/"+chart_type);

		res.writeHead(200);
		res.write(tags.script_tag_main);
		res.end();
	};

	return map;
}