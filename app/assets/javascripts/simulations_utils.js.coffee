# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.readParameterSpaceFile = (event) ->
  console.log "Reading files"
  if event.target.files.length > 0
    file = event.target.files[0]

    reader = new FileReader()
    reader.onload = (f) ->
      console.log f.target.result

    reader.readAsText(file)

window.importClick = () ->
  console.log 'Click'

  file = document.getElementById('parameter_space_file').files[0]
  if file != undefined

    reader = new FileReader()
    reader.onload = (f) ->
      file_content = f.target.result

      $.ajax window.import_file_url,
        method: 'POST',
        data: {
          file_content: file_content,
          simulation_id: $('#simulation_id').val()
        },
        success: (data, status, xhr) ->
          console.log data
#          console.log status
#          console.log xhr
          $("#parameter_selection").html(data.columns)

    reader.readAsText(file)
  else
    alert "You must select a file"


window.bindImportParameterSpaceListeners = (url) ->
  window.import_file_url = url
#  document.getElementById('parameter_space_file').addEventListener('change', window.readParameterSpaceFile, false)
  document.getElementById('import_submit').addEventListener('click', window.importClick, false)