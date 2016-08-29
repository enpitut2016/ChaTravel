# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $('#suggest_submit').on 'click', ->
    $.ajax({
      type: 'POST',
      url: 'rooms/ajax_suggest_request',
      data: {
        user_id: $('#current_user').data('current_user_id'),
        room_url: window.location.href.match(/^http.*\/(.*?)$/).pop(),
        suggest_url: $('#suggest_name').val()
      },
      timeout: 100000
    })
    .done((data, status) ->
      dom = "<div class='suggest_item'>" +
      "<h3 class='suggest_title'>" + data['title'] + "</h3>" +
      "<img class='suggest_image' src = " + data['image'] + " width='180' height='150'>" +
      "<p class='suggest_description'>" + data['description'] + "</p></div>"
      $('#suggest_list').append(dom))
#    TODO errorハンドリング retryとか?
    .fail(() -> alert('error'))