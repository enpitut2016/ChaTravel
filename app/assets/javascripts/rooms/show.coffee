#= require action_cable
#= require_self
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
    #else if (text.substring(0, 12) == '@bot -timer ')
     # App.room.define_timer text.substring(11)
    else if (text.substring(0,11) == '@bot -yado ')
      App.room.request_recommend_yado text.substring(10)
      console.log('yado: ' + text.substring(10))
    else if (text.substring(0, 5) == '@bot ')
      App.room.request_bot_response text.substring(4)

#botのレコメンドをおすすめリストに追加
$ ->
  $(document).on 'click', '.suggest_button', ->
    bot_suggest_url = $(this.parentNode.parentNode).find('.search_text').children('a').attr("href"); 
    console.log(bot_suggest_url);
    App.room.suggest ({
        user_id: Chat.utils.user_id(),
        room_url: Chat.utils.room_url(),
        suggest_url: bot_suggest_url
      })

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
    markerDelete()
    if word == ''
      return
    else
      execEkiSearch word
    return

$ ->
  $('#poi-search-btn').on 'click', ->
    word = document.getElementById('word').value
    markerDelete()
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
  element = document.getElementById('search-poi-list')
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
  document.getElementById('search-poi-list').appendChild table
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
  document.getElementById('search-poi-list').appendChild table
  return  

### 検索結果テーブル作成 ###
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

  ### クリック時の処理 ###
  ZDC.addDomListener div, 'click', ->
    map.moveLatLon latlon
    select_poi text, latlon
    return

  td.appendChild div
  tr.appendChild td
  tr

#選択ポイを保持する
select_poi_name = ""
select_poi_latlon = ""
select_poi = (text, latlon) ->
  select_poi_name = text.nodeValue
  select_poi_latlon = latlon　# クリックされた駅の緯度経度を保存
  console.log(select_poi_name);
  console.log(select_poi_latlon);
  $('#select-poi-1').html("選択：#{select_poi_name}")
  return



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

#マーカがクリックされた時の処理
markerClick = ->
  text = document.createTextNode(@text)
  select_poi text, @latlon

  #labelhtml = undefined
  #labelhtml = '<div><font size = "-1"><div><b>' + @text + '</b></div>'
  #labelhtml += '<table><tr><td>〒' + @zipcode + ' ' + @addressText + '</td></tr>'
  #labelhtml += '<tr><td>電話番号：' + @phoneNumber + '</td></tr></table></font></div>'
  #msg.setHtml labelhtml
  #msg.moveLatLon new (ZDC.LatLon)(@latlon.lat, @latlon.lon)
  #msg.open()
  return


### マーカを削除 ###
markerDelete = ->
  while arrmrk.length > 0
    map.removeWidget arrmrk.shift()
  return


route_to_name = ""
route_to_latlon = ""
route_from_name = ""
route_from_latlon = ""
$ ->
  $('#route-from-btn').on 'click', ->
    route_from_name = select_poi_name
    route_from_latlon = select_poi_latlon
    console.log(route_from_name);
    console.log(route_from_latlon);
    $('#route-from').html("出発地：#{route_from_name}")
    return

$ ->
  $('#route-to-btn').on 'click', ->
    route_to_name = select_poi_name
    route_to_latlon = select_poi_latlon
    console.log(route_to_name);
    console.log(route_to_latlon);
    $('#route-to').html("目的地：#{route_to_name}")
    return


### ルート探索ボタン ###

guyde_type = undefined
line_property = undefined
line_property_drive = undefined
pl = []
mk = []
start = undefined
end = undefined
msg_info = undefined
$ ->
  imgdir ='/assets/';
  guyde_type = 
    'start':
      custom:
        base:
          src: imgdir + 'start.png'
          imgSize: new (ZDC.WH)(35, 35)
          imgTL: new (ZDC.TL)(0, 0)
      offset: ZDC.Pixel(0, -36)
    'end':
      custom:
        base:
          src: imgdir + 'goal.png'
          imgSize: new (ZDC.WH)(35, 35)
          imgTL: new (ZDC.TL)(38, 0)
      offset: ZDC.Pixel(0, -36)

$ ->
  line_property = 
    '通常通路':
      strokeColor: '#3000ff'
      strokeWeight: 5
      lineOpacity: 0.5
      lineStyle: 'solid'
    '横断歩道':
      strokeColor: '#008E00'
      strokeWeight: 5
      lineOpacity: 0.5
      lineStyle: 'solid'
    '横断通路':
      strokeColor: '#007777'
      strokeWeight: 5
      lineOpacity: 0.5
      lineStyle: 'solid'
    '歩道橋':
      strokeColor: '#880000'
      strokeWeight: 5
      lineOpacity: 0.5
      lineStyle: 'solid'
    '踏切内通路':
      strokeColor: '#008800'
      strokeWeight: 5
      lineOpacity: 0.5
      lineStyle: 'solid'
    '連絡通路':
      strokeColor: '#000088'
      strokeWeight: 5
      lineOpacity: 0.5
      lineStyle: 'solid'
    '建物内通路':
      strokeColor: '#550000'
      strokeWeight: 5
      lineOpacity: 0.5
      lineStyle: 'solid'
    '敷地内通路':
      strokeColor: '#005500'
      strokeWeight: 5
      lineOpacity: 0.5
      lineStyle: 'solid'
    '乗換リンク':
      strokeColor: '#000055'
      strokeWeight: 5
      lineOpacity: 0.5
      lineStyle: 'solid'
    '道路外':
      strokeColor: '#110000'
      strokeWeight: 5
      lineOpacity: 0.5
      lineStyle: 'solid'
    '引き込みリンク':
      strokeColor: '#FF0000'
      strokeWeight: 5
      lineOpacity: 0.5
      lineStyle: 'solid'
    '通路外':
      strokeColor: '#00FF00'
      strokeWeight: 5
      lineOpacity: 0.5
      lineStyle: 'solid'

$ ->
  line_property_drive =  
    '高速道路':             
      strokeColor: '#3000ff'
      strokeWeight: 5
      lineOpacity: 1.0
      lineStyle: 'solid'
    '都市高速道路':
      strokeColor: '#008E00'
      strokeWeight: 5
      lineOpacity: 1.0
      lineStyle: 'solid'
    '国道':
      strokeColor: '#007777'
      strokeWeight: 5
      lineOpacity: 1.0
      lineStyle: 'solid'
    '主要都市道':
      strokeColor: '#880000'
      strokeWeight: 5
      lineOpacity: 1.0
      lineStyle: 'solid'
    '一般道路(幹線)':
      strokeColor: '#008800'
      strokeWeight: 5
      lineOpacity: 1.0
      lineStyle: 'solid'
    '一般道路(その他)':
      strokeColor: '#000088'
      strokeWeight: 5
      lineOpacity: 1.0
      lineStyle: 'solid'
    '導入路':
      strokeColor: '#550000'
      strokeWeight: 5
      lineOpacity: 1.0
      lineStyle: 'solid'
    '細街路(主要)':
      strokeColor: '#005500'
      strokeWeight: 5
      lineOpacity: 1.0
      lineStyle: 'solid'
    '細街路(詳細)':
      strokeColor: '#000055'
      strokeWeight: 5
      lineOpacity: 1.0
      lineStyle: 'solid'
    'フェリー航路':
      strokeColor: '#110000'
      strokeWeight: 5
      lineOpacity: 1.0
      lineStyle: 'solid'
  

mode = undefined
from = undefined
to = undefined
$ ->
  $('#route-btn').on 'click', ->
    from = route_from_latlon
    to = route_to_latlon

    ### 歩行者ルート探索を実行 ###
    ZDC.Search.getRouteByDrive {
      from: from
      to: to
    }, (status, res) ->
      if status.code == '000'

        ### 取得成功 ###     
        markerDelete()
        writeRoute status, res
        alert "走行時間：#{res.route.time}分\n走行距離：#{res.route.distance}m\n通行料金：#{res.route.toll}円"
      else
        ### 取得失敗 ###
        alert status.text
      return
    return

  ### ルートを描画します ###
  writeRoute = (status, res) ->
    `var opt`

    ### スタートとゴールのアイコンを地図に重畳します ###
    setStartEndWidget()
    link = res.route.link

    ### 現在描画しているロードタイプを保存する ###
    now_road_type = undefined
    i = 0
    j = link.length
    while i < j
      if i == 0
        now_road_type = link[i].roadType
        opt = line_property_drive[link[i].roadType]
      else
        if now_road_type != link[i].roadType
          opt = line_property_drive[link[i].roadType]
      latlons = []
      k = 0
      l = link[i].line.length
      while k < l
        latlons.push link[i].line[k]
        k++
      pl[i] = new (ZDC.Polyline)(latlons, opt)
      map.addWidget pl[i]
      if link[i].roadType != '通常通路'
        guide = link[i].roadType
        #marker = new (ZDC.Marker)(link[i].line[0])
        #map.addWidget marker
      i++
    return

  ### スタートとゴールのアイコンを地図に重畳します ###
  setStartEndWidget = ->
    mrks = new (ZDC.Marker)(from)
    mrkg = new (ZDC.Marker)(to)
    map.addWidget mrks
    map.addWidget mrkg
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
    minutes = $("#topic_time").val()
    if (topic_word == '')
      alert 'トピックを入力してください'
      return
    if (minutes == '')
      alert '時間を入力してください'
      return
    sentence = "トピックが決まりました。それでは" + topic_word + "について話し合いましょう！"
    now = new Date
    topic_time = now.getTime() + 60 * 1000 * minutes
    target = new Date(topic_time)
    App.room.speak_bot sentence
    App.room.define_topic ({
      time: target,
      topic_name: topic_word
      })
    $("#topic_name").val('')
    $("#topic_time").val('')

timerCheck = false

getEndTime = ->
  targetDate = $('#targetDate').text()
  target = new Date(targetDate)
  now = new Date
  diff = target.getTime() - now.getTime()

  if (diff <= 0)
    if (timerCheck == false)
      $('#endTimer').text("タイマー未設定")
    else if(timerCheck == true)
      alert "時間になりました。議論を終えてください"
      timerCheck = false
  else if(diff > 0)
    timerCheck = true
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
  , 500

  return
