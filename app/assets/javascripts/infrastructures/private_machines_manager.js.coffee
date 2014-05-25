class window.PrivateMachinesManagerDialog
  constructor: (@baseName, @machinesTableId, loadingImgId) ->
    @reloadTable()

    @addMachineForm = $("##{@baseName}-submission-panel form")

    @loading = $("##{@baseName}-busy")

    @bindToAddMachineForm()

  reloadTable: () ->
    $("##{@baseName}-table-partial").html(window.loaderHTML)
    $("##{@baseName}-table-partial").load('/infrastructure/get_credentials_table_partial?' +
      $.param({infrastructure_name: @baseName}), =>
        @bindToRemoveButtons()
    )

  bindToAddMachineForm: () ->
    @addMachineForm
    .bind('ajax:before', => @loading.show())
    .bind('ajax:success', (status, data, xhr) =>
      switch data.status
        when 'banned', 'error', 'invalid', 'not-in-db'
          toastr.error(data.msg)
        when 'ok', 'added'
          toastr.success(data.msg)
        else
          toastr.error(data.msg)

    )
    .bind('ajax:failure', (xhr, data, error) => toastr.error(data.msg))
    .bind('ajax:complete', () =>
        @loading.hide()
        @reloadTable()
      )

  bindToRemoveButtons: ->
    $("##{@baseName}-table-panel tr[id]").each( ->
      row_id = this['id']
      row_loading = $("##{row_id}-busy")
      $("##{row_id} form")
      .bind('ajax:before', => row_loading.show())
      .bind('ajax:success', (status, data, xhr) =>
        switch data.status
          when 'removed-ok'
            toastr.success(data.msg)
            $("##{row_id}").remove()
          when 'error'
            toastr.error(data.msg)
          else
            toastr.error(data.msg)
      )
      .bind('ajax:failure', (xhr, status, error) => toastr.error(status.msg))
      .bind('ajax:complete', () => row_loading.hide())
    );

