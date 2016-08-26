#= require action_cable
#= require_self
#= require ../cable

$ ->
  $("#post").on 'click', ->
    comment = $("#comment")
    App.room.speak comment.val()
    comment.val('')
  console.log('show coffee')