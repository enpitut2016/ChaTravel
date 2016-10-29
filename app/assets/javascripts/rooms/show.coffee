#= require action_cable
#= require_self
#= require ../cable


#タブに関する記述
$ ->
  $(".tab_content li").css("display","none");
  $('.tab_content li').eq(0).css('display','block');


$ ->
  $(".tab li").on 'click', ->
    index = $(".tab li").index(this);
    $(".tab_content li").css("display","none");
    $('.tab_content li').eq(index).css('display','block');
    $('.tab li').removeClass('select');
    $(this).addClass('select')


$ ->
  $("#post").on 'click', ->
    comment = $("#post_comment")
    text = comment.val().trim()
    if (text == '')
      alert '文字を入力してください'
      return
    App.room.speak text
    if (text.substring(0, 5) == '@bot ')
      App.room.request_recommend text.substring(4)
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


$ ->
  $('#finish_vote').on 'click', ->
    App.room.finish_vote ({
      vote_result: create_vote_result()
    })
  

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
