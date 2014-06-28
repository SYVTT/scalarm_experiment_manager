// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery.ui.all
//= require jquery_ujs
//= require custom.modernizr
//= require foundation
//= require_tree .
//= require highcharts/highcharts
//= require highcharts/highcharts-more
//= require highcharts/modules/exporting
//= require dataTables/jquery.dataTables
//= require jit-yc
//= require toastr
//= require jquery.remotipart
//= require d3


$(function(){ $(document).foundation(); });

toastr.options = {
  "closeButton": false,
  "debug": false,
  "positionClass": "toast-top-full-width",
  "onclick": null,
  "showDuration": "3000",
  "hideDuration": "1000",
  "timeOut": "5000",
  "extendedTimeOut": "1000",
  "showEasing": "swing",
  "hideEasing": "linear",
  "showMethod": "fadeIn",
  "hideMethod": "fadeOut"
};

function string_with_delimeters() {
    var string_copy = this.split("").reverse().join("");
    var len = 3; var num_of_comas = 0;

    while((len + num_of_comas <= string_copy.length) && string_copy.length > 3) {
        string_copy = string_copy.substr(0,len) + "," + string_copy.substr(len);
        num_of_comas = 1; len += 4;
    }

    return string_copy.split("").reverse().join("");
}

String.prototype.with_delimeters = string_with_delimeters;

window.loaderHTML = '<div class="row small-1 small-centered" style="margin-bottom: 10px;"><img src="/assets/loading.gif"/></div>'
