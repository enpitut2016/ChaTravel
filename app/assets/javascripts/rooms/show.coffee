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
    loadMap()
    
#おすすめ表示について                

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


#mapAPIについて

map = undefined
arrmrk = []

loadMap = () ->
  lat = 35.6778614
  lon = 139.7703167
  map = new ZDC.Map(document.getElementById('ZMap'),{ latlon: new ZDC.LatLon(lat, lon), zoom: 6});   

  ### 通常のコントロールを作成 ###
  widget_normal = new (ZDC.Control)(
    pos:
      top: 10
      left: 10
    type: ZDC.CTRL_TYPE_NORMAL) 
  
  map.addWidget widget_normal #コントロールを表示  

$ ->
  $('#eki-search-btn').on 'click', ->
    word = document.getElementById('word').value
    markerDelete
    if word == ''
      return
    else
      execEkiSearch word
    return

$ ->
  $('#poi-search-btn').on 'click', ->
    word = document.getElementById('word').value
    markerDelete
    if word == ''
      return
    else
      execPoiSearch word
    return

execEkiSearch = (word) ->
  ZDC.Search.getStationByWord { word: word }, (status, res) ->
    if status.code == '000'
      initTable()
      writeEkiTable res
      markerDisp status, res
    else
      alert status.text
    return
  return

execPoiSearch = (word) ->
  ZDC.Search.getPoiByWord { word: word }, (status, res) ->
    if status.code == '000'
      initTable()
      writePoiTable res
      markerDisp status, res
    else
      alert status.text
    return
  return  

### 駅検索結果テーブル作成 ###
initTable = ->
  element = document.getElementById('search-result')
  while element.firstChild
    element.removeChild element.firstChild
  return

### 駅検索結果テーブル作成 ###
writeEkiTable = (res) ->
  item = res.item
  table = document.createElement('table')
  table.style.width = '100%'
  i = 0
  l = item.length
  while i < l
    tbody = document.createElement('tbody')
    tr = createTr(item[i].poi.text, item[i].poi.latlon)
    tbody.appendChild tr
    table.appendChild tbody
    i++
  document.getElementById('search-result').appendChild table
  return

### ポイ検索結果テーブル作成 ###
writePoiTable = (res) ->
  item = res.item
  table = document.createElement('table')
  table.style.width = '100%'
  i = 0
  l = item.length
  while i < l
    tbody = document.createElement('tbody')
    tr = createTr(item[i].text, item[i].latlon)
    tbody.appendChild tr
    table.appendChild tbody
    i++
  document.getElementById('search-result').appendChild table
  return  

### 駅検索結果テーブル作成 ###
createTr = (text, latlon) ->
  `var text`
  tr = document.createElement('tr')

  ### TD作成 ###
  td = document.createElement('td')
  div = document.createElement('div')
  div.className = 'eki-list'
  div.style.cursor = 'pointer'
  text = document.createTextNode(text)
  div.appendChild text

  ### 駅名クリック時の処理 ###
  ZDC.addDomListener div, 'click', ->
    map.moveLatLon latlon
    select_eki_latlon = latlon　# クリックされた駅の緯度経度を保存
    return

  td.appendChild div
  tr.appendChild td
  tr


### マーカを作成 ###
markerDisp = (status, res) ->
  items = res.item
  latlons = []
  i = 0
  j = items.length
  while i < j
    if items[i].poi != undefined
      itemlatlon = new (ZDC.LatLon)(items[i].poi.latlon.lat, items[i].poi.latlon.lon)
    else
      itemlatlon = new (ZDC.LatLon)(items[i].latlon.lat, items[i].latlon.lon)
    latlons.push itemlatlon
    mrk = new (ZDC.Marker)(itemlatlon)
    map.addWidget mrk
    arrmrk.push mrk

    ZDC.bind mrk, ZDC.MARKER_CLICK, items[i].poi, markerClick  # マーカをクリックしたときの動作
    i++
  return

markerClick = ->
  labelhtml = undefined
  labelhtml = '<div><font size = "-1"><div><b>' + @text + '</b></div>'
  labelhtml += '<table><tr><td>〒' + @zipcode + ' ' + @addressText + '</td></tr>'
  labelhtml += '<tr><td>電話番号：' + @phoneNumber + '</td></tr></table></font></div>'
  msg.setHtml labelhtml
  msg.moveLatLon new (ZDC.LatLon)(@latlon.lat, @latlon.lon)
  msg.open()
  return

### マーカを削除 ###
markerDelete = ->
  while arrmrk.length > 0
    map.removeWidget arrmrk.shift()

  msg.close() # 吹き出しを閉じる
  return

$ ->
  $('#zoom').on 'click', ->
    map.setZoom Number(document.getElementById('zoom').value)
    return







