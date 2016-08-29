#= require action_cable
#= require_self
#= require ../cable

$ ->
  $("#post").on 'click', ->
    comment = $("#post_comment")
    App.room.speak comment.val()
    comment.val('')


$ ->
  $('#suggest_submit').on 'click', ->
    App.room.suggest ({
        user_id: $('#current_user').data('current_user_id'),
        room_url: window.location.href.match(/^http.*\/(.*?)$/).pop(),
        suggest_url: $('#suggest_name').val()
      })
    $('#suggest_name').val('')

$ ->
  $('#start_vote').on 'click', ->
    App.room.start_vote ({
      room_url: window.location.href.match(/^http.*\/(.*?)$/).pop(),
      suggest_list: create_suggest()
    })


create_suggest = () ->
  array = []
  $('.suggest_id').each((i, elem) ->
    array.push($(elem).data('suggest_id')))
  return array

