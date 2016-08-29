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
        suggest_item: $('#suggest_name').val()

      },
    })
    .done((data, status)->
      alert(data['suggest_item']))

#    TODO errorハンドリング retryとか?
    .fail(() -> alert('error'))