# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#create_suggest = () ->
#  array = []
#  $('.suggest_id').each((i, elem) ->
#    array.push($(elem).data('suggest_id')))
#  return array
#
#$ ->
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
#      "<h3 class='suggest_title'>" + data['title'] + "</h3>" +
#      "<img class='suggest_image' src = " + data['image'] + " width='180' height='150'>" +
#      "<p class='suggest_description'>" + data['description'] + "</p>" +
#      "<div class='suggest_id' data-suggest_id=" + data['suggest_id']+ "></div>" +
#      "</div></li>"
#      $('#suggest_list').append(dom))
#    TODO errorハンドリング retryとか?
#    .fail((error) -> alert(error))
#$ ->
#  $('#start_vote').on 'click', ->
#    $.ajax({
#      type: 'POST',
#      url: 'rooms/ajax_vote_request',
#      data: {
#        room_url: window.location.href.match(/^http.*\/(.*?)$/).pop(),
#        suggest_list: create_suggest
#      }
#    })
#    .done((data, status) ->
#      
#
#    )
#    .fail((error) -> alert(error))
