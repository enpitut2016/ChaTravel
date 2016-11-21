#= require ../cable

#ページが読み込まれたとき最新の投稿に移動する
$(window).load ->
  $('#message_list').animate({scrollTop: $('#message_list')[0].scrollHeight}, 'slow');
  getEndTime();


#タブに関する記述
$ ->
  $(".tab_content > li").css("display","none");
  $('.tab_content li').eq(0).css('display','block');


$ ->
  $(".tab li").on 'click', ->
    index = $(".tab li").index(this);
    $(".tab_content > li").css("display","none");
    $('.tab_content li').eq(index).css('display','block');
    $('.tab li').removeClass('select');
    $(this).addClass('select')
    loadMap()
    
#botのレコメンドについて   

$ ->
  $("#post").on 'click', ->
    comment = $("#post_comment")
    text = comment.val().trim()
    if (text == '')
      alert '文字を入力してください'
      return
    App.room.speak text
    comment.val('')
    if (text.substring(0, 13) == '@bot -kankou ')
      console.log('kankou_recommend:' + text.substring(12)) 
      execKankouSearch(text.substring(12))
    else if (text.substring(0, 12) == '@bot -timer ')
      App.room.define_timer text.substring(11)
    else if (text.substring(0,11) == '@bot -yado ')
      App.room.request_recommend_yado text.substring(10)
      console.log('yado: ' + text.substring(10))
    else if (text.substring(0, 5) == '@bot ')
      App.room.request_bot_response text.substring(4)

# エンターキーを押してコメント送信

keypressing = false
$ ->
  $('#post_comment').on 'keypress', (e) ->
    if(e.keyCode == 13)
      keypressing = true
      $('#post').trigger('click')
      
# エンターキー上げたときに全部消す

$ ->
  $('#post_comment').on 'keyup', (e) ->
    if(e.keyCode == 13 && keypressing)
      $("#post_comment").val('')
      keypressing = false

#おすすめ表示について

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
  $('#ZMap').empty();
  map = new ZDC.Map(document.getElementById('ZMap'),{ latlon: new ZDC.LatLon(lat, lon), zoom: 6});   
  

  ### 通常のコントロールを作成 ###
  widget_normal = new (ZDC.Control)(
    pos:
      top: 10
      left: 10
    type: ZDC.CTRL_TYPE_NORMAL) 
  
  map.addWidget widget_normal #コントロールを表示  

#リサイズされるたびに地図を再描画する（連続して呼ばれないようにタイマーを用いて、リサイズ1.5秒後に描画）
timer = false
$(window).resize ->
  if timer != false
    clearTimeout timer
  timer = setTimeout((->
    console.log 'resized'
    loadMap()
    return
  ), 1000)
  return


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



### ぼっとおすすめ用 ###
execKankouSearch = (word) ->
  ZDC.Search.getPoiByWord { word: word, limit : "0,1", genrecode : "0012000150" }, (status, res) ->
    if status.code == '000'
      App.room.request_recommend_kankou res.item[0].text
    else
      alert status.text
      return

### トピック決め ###
$ ->
  $('#topic_submit').on 'click', ->
    topic_word =$("#topic_name").val()
    if (topic_word == '')
      alert 'トピックを入力してください'
      return
    sentence = "トピックが決まりました。それでは" + topic_word + "について話し合いましょう！"
    App.request_bot_response sentence
    $("#topic_name").val('')


getEndTime = ->
  targetDate = $('#targetDate').text()
  target = new Date(targetDate)
  now = new Date
  diff = target.getTime() - now.getTime()

  if (diff < 0)
    $('#endTimer').text("タイマー未設定")
  else

    # ミリ秒を日、時、分に分解する
    # 経過日数
    days = parseInt(diff/(24*60*60*1000), 10)
    diff -= days * 24 * 60 * 60 * 1000
    # 経過時間
    hours = parseInt(diff/(60*60*1000), 10)
    diff -= hours * 60 * 60 * 1000
    # 経過分
    minutes = parseInt(diff/(60*1000), 10)
    diff -= minutes * 60 * 1000
    # 経過秒
    seconds = parseInt(diff/1000, 10) 

    $('#endTimer').text(hours+'時間'+minutes+'分'+seconds+'秒')
  setTimeout ->
    getEndTime()
  , 1000

  return
