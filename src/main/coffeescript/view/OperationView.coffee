class OperationView extends Backbone.View
  events: {
  'click .submit' : 'submitOperation'
  }

  initialize: ->

  render: ->
    $(@el).html(Handlebars.templates.operation(@model))

    # Render each parameter
    @addParameter param for param in @model.parameters
    @

  addParameter: (param) ->
    # Render a parameter
    paramView = new ParameterView({model: param, tagName: 'tr', readOnly: !@model.isGetMethod})
    $('.operation-params', $(@el)).append paramView.render().el

  submitOperation: ->
    # Check for errors
    form = $('.sandbox', $(@el))
    error_free = true
    form.find("input.required").each ->
      $(@).removeClass "error"
      if jQuery.trim($(@).val()) is ""
        $(@).addClass "error"
        $(@).wiggle
          callback: => $(@).focus()
        error_free = false

    # if error free submit it
    if error_free
      map = {}
      for o in form.serializeArray()
        map[o.name] = o.value

      invocationUrl = @model.urlify(map)
      log 'submitting ' + invocationUrl
      $(".request_url", $(@el)).html "<pre>" + invocationUrl + "</pre>"
      $.getJSON(invocationUrl, (r) => @showResponse(r)).complete((r) => @showCompleteStatus(r)).error (r) => @showErrorStatus(r)


  showResponse: (response) ->
    prettyJson = JSON.stringify(response, null, "\t").replace(/\n/g, "<br>")
    $(".response_body", $(@el)).html prettyJson
    $(".response", $(@el)).slideDown()

  showErrorStatus: (data) ->
    @showStatus data
    $(".response", $(@el)).slideDown()

  showCompleteStatus: (data) ->
    @showStatus data

  showStatus: (data) ->
    response_body = "<pre>" + JSON.stringify(JSON.parse(data.responseText), null, 2).replace(/\n/g, "<br>") + "</pre>"
    $(".response_code", $(@el)).html "<pre>" + data.status + "</pre>"
    $(".response_body", $(@el)).html response_body
    $(".response_headers", $(@el)).html "<pre>" + data.getAllResponseHeaders() + "</pre>"
