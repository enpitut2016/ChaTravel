#= require action_cable
#= require_self
#= require ../cable

$ ->
  $("#post").on 'click', ->
    comment = $("#comment")
    App.room.speak comment.val()
    comment.val('')


$ ->
  $('#suggest_submit').on 'click', ->
    App.room.suggest ({
        user_id: $('#current_user').data('current_user_id'),
        room_url: window.location.href.match(/^http.*\/(.*?)$/).pop(),
        suggest_url: $('#suggest_name').val()
      })


#  $ ->
#  $('#suggest_submit').on 'click', ->
#    $.ajax({
#      type: 'POST',
#      url: 'rooms/ajax_suggest_request',
#      data: {
#        user_id: $('#current_user').data('current_user_id'),
#        room_url: window.location.href.match(/^http.*\/(.*?)$/).pop(),
#        suggest_url: $('#suggest_name').val()
#      },
#      timeout: 100000
#    })
#    .done((data, status) ->
#      dom = "<li><div class='suggest_item'>" +
#        "<h3 class='suggest_title'>" + data['title'] + "</h3>" +
#        "<img class='suggest_image' src = " + data['image'] + " width='180' height='150'>" +
#        "<p class='suggest_description'>" + data['description'] + "</p>" +
#        "<div class='suggest_id' data-suggest_id=" + data['suggest_id']+ "></div>" +
#        "</div></li>"
#      $('#suggest_list').append(dom))
##    TODO errorハンドリング retryとか?
#    .fail((error) -> alert(error))