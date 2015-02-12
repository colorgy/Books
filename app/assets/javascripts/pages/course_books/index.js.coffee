$ ->

  $("#org-select").select2()

  $('#lecturer-select').select2
    allowClear: true
    placeholder: '請輸入您的姓名 ^^'
    ajax:
      url: '/course_books.json'
      dataType: 'json'
      quietMillis: 250
      data: (term, page) ->
        org: $("#org-select").val()
        lecturer: term
      results: (courses) ->
        resultData = []
        courses.forEach (course) ->
          itemData = {}
          itemData.id = course.lecturer_name
          itemData.text = course.lecturer_name
          resultData.push itemData
        { results: resultData }
      cache: true
    minimumInputLength: 1

  $('#lecturer-select').change ->
    $.ajax
      url: '/course_books.js'
      dataType: 'script'
      data:
        org: $("#org-select").val()
        lecturer: $('#lecturer-select').val()

  refreshView = ->
    if !!$('#org-select').select2('val')
      $('.step-2').removeClass('disabled')
    else
      $('.step-2').addClass('disabled')
    if !!$('#lecturer-select').select2('val')
      $('.step-3').removeClass('disabled')
    else
      $('.step-3').addClass('disabled')

  refreshView()

  $("#org-select").change ->
    $('#lecturer-select').val('')
    $('#lecturer-select').select2('val', '')
    refreshView()

  $("#lecturer-select").change ->
    refreshView()
