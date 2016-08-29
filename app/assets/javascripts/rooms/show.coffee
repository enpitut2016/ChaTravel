#= require action_cable
#= require_self
#= require ../cable

$ ->
  $("#post").on 'click', ->
    comment = $("#post_comment")
    App.room.speak comment.val()
    comment.val('')
