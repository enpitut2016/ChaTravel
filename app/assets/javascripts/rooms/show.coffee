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
    $(this).css({display: 'none'});
    $('#finish_vote').css({display: 'block'});
    $('#suggest_name').prop('disabled', true);
    $('#suggest_submit').prop('disabled', true);

$ ->
  $('#finish_vote').on 'click', ->
    App.room.finish_vote ({
      vote_result: create_vote_result()
    })
    $(this).css({display: 'none'});
    $('#start_vote').css({display: 'block'});
    $('#suggest_name').prop('disabled', false);
    $('#suggest_submit').prop('disabled', false);


create_suggest = () ->
  array = []
  $('.suggest_id').each((_, elem) ->
    array.push($(elem).data('suggest_id')))
  return array

create_vote_result = () ->
  hash = {}
  $('.suggest_id').each((_, elem) ->
    suggest_id = $(elem).data('suggest_id')
    badge = $('#badge_suggest_' + suggest_id)
    hash[suggest_id] = badge.text())
  return hash
