#= require action_cable
#= require_self
#= require ../cable

$ ->
  $("#post").on 'click', ->
    comment = $("#post_comment")
    if (comment.val().trim() == '')
      alert '文字を入力してください'
      return
    App.room.speak comment.val()
    comment.val('')


$ ->
  $('#suggest_submit').on 'click', ->
    App.room.suggest ({
        user_id: Chat.utils.user_id(),
        room_url: Chat.utils.room_url(),
        suggest_url: $('#suggest_name').val()
      })
    $('#suggest_name').val('')

$ ->
  $('#start_vote').on 'click', ->
    App.room.start_vote ({
      room_url: Chat.utils.room_url,
      suggest_list: create_suggest()
    })


create_suggest = () ->
  array = []
  $('.suggest_id').each((i, elem) ->
    array.push($(elem).data('suggest_id')))
  return array

