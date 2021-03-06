# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
#require "open-uri"

class RoomChannel < ApplicationCable::Channel
  def subscribed
    @room = Room.find_by(url: params[:room])
    @room_name = "room_#{@room.url}"
    # @vote_name = "vote_#{@room.url}"
    stop_all_streams
    stream_from @room_name
    # stream_from @vote_name
  end

  def unsubscribed
    stop_all_streams
  end

  def speak (data)
    Message.create!(message: data['message'], user_id: current_user.id, room_id: @room.id)
  end

  #botに何か言わせたいとき
  def speak_bot(data)
    Message.create!(message: data['message'], user_id: 1, room_id: @room.id)
  end

  #botの返答
  def request_bot_response(data)

    

    #形態素解析を行い、もしメッセージを表示するイベントが行われていたらreturn
    isMes = decomposeSentences(data);
    if isMes == true then
      return;
    end 

    #repl-AIからの雑談対応 
    request_repl(data)

    #ユーザローカル雑談APIを使い、適当な返答をする。もし、エラーがあれば"zzz"と返す
    # chatRes = use_api(data,'chat');
    # if chatRes == nil then
    #   Message.create!(message: "zzz", user_id: 1, room_id: @room.id)
    #   return
    # end
    # Message.create!(message: "[ユーザローカル] #{chatRes['result']}", user_id: 1, room_id: @room.id)
  end

  def request_repl(data)

    #まずエンドユーザID取得
    resMes = use_api({},'repl-registration')
    appUserId = resMes['appUserId']
    resMes = use_api({"data" => data['data'], "appUserId" => appUserId},'repl-dialogue')
    
    Message.create!(message: "#{ resMes["systemText"]["expression"]}", user_id: 1, room_id: @room.id) 
  
  end  

  #botAPIの処理
  def use_api(data,type)

    case type
    #---------ここからGETをつかうAPI-------------
    when 'chat'
      params = URI.encode_www_form({ message: data['data'], key: Rails.application.secrets.USERLOCAL_KEY})
      uri = URI.parse("https://chatbot-api.userlocal.jp/api/chat?#{params}")
      method = 'GET'
    when 'dec'
      params = URI.encode_www_form({ message: data['data'], key: Rails.application.secrets.USERLOCAL_KEY})
      uri = URI.parse("https://chatbot-api.userlocal.jp/api/decompose?#{params}")
      method = 'GET'
    when 'geo'
      params = URI.encode_www_form({ method: 'suggest', matching: 'prefix', keyword: data})
      uri = URI.parse("http://geoapi.heartrails.com/api/json?#{params}")
      method = 'GET'
    when 'itsmo'
      ActionCable.server.broadcast(@room_name, {type: 'itsmo_command', data: { user_id: current_user.id, word: j } }) #クライアント側にデータを送信
      return
    when 'gnavi'
      params = URI.encode_www_form({ keyid: Rails.application.secrets.GNAVI_KEY, format: 'json', address: data['address'], hit_per_page: '3', freeword: data['freeword']})
      uri = URI.parse("http://api.gnavi.co.jp/RestSearchAPI/20150630/?#{params}")
      method = 'GET'
    when 'yado'
       params = URI.encode_www_form({ keyword: data['keyword'], format: 'json',responseType: 'small', hits: '3', page: '3',datumType: '1', elements: 'hotelName,hotelInformationUrl,hotelImageUrl,address2,latitude,longitude' , applicationId: Rails.application.secrets.RAKUTEN_KEY})
       uri = URI.parse("https://app.rakuten.co.jp/services/api/Travel/KeywordHotelSearch/20131024?#{params}") 
       method = 'GET'
    #---------ここからPOSTをつかうAPI-------------
    when 'repl-registration'
      uri = URI.parse("https://api.repl-ai.jp/v1/registration")
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true #httpsに
      req = Net::HTTP::Post.new(uri.request_uri)
      req["Content-Type"] = "application/json" # httpリクエストヘッダの追加
      req["x-api-key"] = Rails.application.secrets.REPL_KEY # httpリクエストヘッダの追加
      payload = { "botId" => "chatraBot" }.to_json
      method = 'POST'
    when 'repl-dialogue'
      uri = URI.parse("https://api.repl-ai.jp/v1/dialogue")
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true #httpsに
      req = Net::HTTP::Post.new(uri.request_uri)
      req["Content-Type"] = "application/json" # httpリクエストヘッダの追加
      req["x-api-key"] = Rails.application.secrets.REPL_KEY # httpリクエストヘッダの追加
      payload = { 
        "appUserId" => data['appUserId'], 
        "botId" => "chatraBot",
        "voiceText" => data['data'],
        "initTalkingFlag" => true,
        "initTopicId" => "zatsudan"
      }.to_json
      method = 'POST'
    when 'langAnaEnt'
      params = URI.encode_www_form({ APIKEY: Rails.application.secrets.DOCOMO_KEY })
      uri = URI.parse("https://api.apigw.smt.docomo.ne.jp/gooLanguageAnalysis/v1/entity?#{params}")
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true #httpsに
      req = Net::HTTP::Post.new(uri.request_uri)
      req["Content-Type"] = "application/json" # httpリクエストヘッダの追加
      payload = {
        "sentence" => data['data']
      }.to_json
      method = 'POST'
    when 'langAnaMor'
      params = URI.encode_www_form({ APIKEY: Rails.application.secrets.DOCOMO_KEY })
      uri = URI.parse("https://api.apigw.smt.docomo.ne.jp/gooLanguageAnalysis/v1/morph?#{params}")
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true #httpsに
      req = Net::HTTP::Post.new(uri.request_uri)
      req["Content-Type"] = "application/json" # httpリクエストヘッダの追加
      payload = {
        "sentence" => data['data']
      }.to_json
      method = 'POST'
    when 'sentenceUnderstanding'
      params = URI.encode_www_form({ APIKEY: Rails.application.secrets.DOCOMO_KEY })
      uri = URI.parse("https://api.apigw.smt.docomo.ne.jp/sentenceUnderstanding/v1/task?#{params}")
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true #httpsに
      req = Net::HTTP::Post.new(uri.request_uri)
      req["Content-Type"] = "application/json" # httpリクエストヘッダの追加
      payload = {
        "projectKey" => 'OSU',
        "appInfo" => {"appName" => "hoge_app", "appKey" => "hoge_app01"},
        "clientVer" => "1.0.0",
        "dialogMode" => "off",
        "language" => "ja",
        "userId" => "12 123456 123456 0",
        "location" => {"lat" => 139.766084, "lon"=> 35.681382},
        "userUtterance" => {"utteranceText" => data['data']}
      }.to_json
      method = 'POST'
      Rails.logger.debug(payload)
    else
      Rails.logger.debug("API Type Error")
      return
    end


    begin

      if method == 'GET' then
        response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|        
          http.open_timeout = 5 # Net::HTTP.open_timeout=で接続時に待つ最大秒数の設定をする。タイムアウト時はTimeoutError例外が発生
          http.read_timeout = 10 # Net::HTTP.read_timeout=で読み込み1回でブロックして良い最大秒数の設定をする 
          http.get(uri.request_uri) # 返り値はNet::HTTPResponseのインスタンス
        end
      elsif method == 'POST' then
        req.body = payload # リクエストボデーにJSONをセット
        response = https.request(req);
      end

      # [レスポンス処理]
      case response
      when Net::HTTPSuccess   #うまくいっていたらbotが発言
        p = JSON.parse(response.body)
        return p;
      when Net::HTTPRedirection
        Rails.logger.debug("Redirection: code=#{response.code} message=#{response.message}")
      else
        Rails.logger.debug("HTTP ERROR: code=#{response.code} message=#{response.message}")
      end

    rescue IOError => e
      Rails.logger.debug(e.message);
    rescue TimeoutError => e
      Rails.logger.debug(e.message);
    rescue JSON::ParserError => e
      Rails.logger.debug(e.message);
    rescue => e
      Rails.logger.debug(e.message);
    end

  end

  #形態素解析の処理
  def decomposeSentences(data)

    resHatsuwaType = use_api(data,'sentenceUnderstanding');
    Rails.logger.debug("発話理解 = #{resHatsuwaType}");
    hatuwaType = resHatsuwaType["dialogStatus"]["command"]["commandName"]#[command][commandName]
    Rails.logger.debug("発話タイプ = #{hatuwaType}");

    resEnt = use_api(data,'langAnaEnt');
    location = [];
    resEnt["ne_list"].each{|i| 
      if i[1]=="LOC" then location << i[0] end #地名を抽出
    }

    resMor = use_api(data,'langAnaMor');
    keyword = [];
    resMor["word_list"].each{|i| 
      i.each{|j|
        if j[1]=="名詞" && !location.include?(j[0]) then keyword << j[0] end #キーワードを抽出
        Rails.logger.debug("形態素 = #{j}");
      }
    }

    Rails.logger.debug("地名 = #{location}");
    Rails.logger.debug("キーワード = #{keyword}");


    if !location.empty? && !keyword.empty? then #キーワードと地名を含んでいたら

      keywords = "";
      keyword.each{|i| keywords << "#{i}," } #カンマ形式に整える
      keywords.slice!(keywords.length-1, 1);#最後のカンマを削除
      

      location.each{|loc|

        if keyword.include?("ニュース") then #ニュースというキーワードがあったら雑談に移行する
          return false;
        end 



        if keyword.include?("ホテル") || keyword.include?("宿") || keyword.include?("旅館") then #キーワードに宿があれば宿を探す
          yado = use_api({"keyword" => loc}, 'yado');
          Rails.logger.debug("宿APIレスポンス = #{yado}");
          if true then #検索してみつからなかったときのなにかしらのエラー処理

            sendMessage = '-rakuten-' + loc+'のホテルを'+yado["hotels"].length.to_s+'件検索しました。' + ' -resultS- ' 
            yado["hotels"].each{|i|
              sendMessage += ' -mainS- ' \
                           + ' -imgS- ' \
                           + i["hotel"][0]["hotelBasicInfo"]["hotelImageUrl"] \
                           + ' -E- ' \
                           + ' -textS- ' \
                           + '「'+i["hotel"][0]["hotelBasicInfo"]["hotelName"]+'」' \
                           + ' -br- ' \
                           + ' 住所：'+i["hotel"][0]["hotelBasicInfo"]["address2"] \
                           + ' -br- ' \
                           + ' -br- ' \
                           + i["hotel"][0]["hotelBasicInfo"]["hotelInformationUrl"] \
                           + ' -E- ' \
                           + ' -suggest- ' \
                           + ' -lat- ' + i["hotel"][0]["hotelBasicInfo"]["latitude"].to_s + ' -E- '\
                           + ' -lon- ' + i["hotel"][0]["hotelBasicInfo"]["longitude"].to_s + ' -E- '\
                           + ' -map- ' \
                           + ' -br-　 ' \
                           + ' -br-　 ' \
                           + ' -E- ' \
                           + ' -br-　 ' 
            }
            sendMessage += '-E-' 

            Message.create!(message: sendMessage, user_id: 1, room_id: @room.id)
          else
            Message.create!(message: loc+'のホテルは見つかりませんでした。', user_id: 1, room_id: @room.id)
          end
          return true;
        end

        if hatuwaType=="グルメ検索" then
          gnavi = use_api({"address" => loc, "freeword" => keywords},'gnavi');  #グルメを探す
          #Rails.logger.debug("ぐるなびAPIレスポンス = #{gnavi}");
          if !gnavi.include?('error') then

            sendMessage = '-gnavi-'+loc+'のレストランを'+gnavi["rest"].length.to_s+'件検索しました（キーワード；'+keywords+'）' + ' -resultS- '
            gnavi['rest'].each{|i|
              sendMessage +=  ' -mainS- ' \
                            + ' -imgS- ' \
                            + i['image_url']['shop_image1'] \
                            + ' -E- ' \
                            + ' -textS- ' \
                            + '「'+i['name']+'」' \
                            + ' -br- ' \
                            + ' 住所：'+i['address'] \
                            + ' -br- -br-' \
                            + i['pr']['pr_short'] \
                            + ' -br- ' \
                            + ' -br- ' \
                            + i['url'] \
                            + ' -br-　 ' \
                            + ' -br-　 ' \
                            + ' -E- ' \
                            + ' -suggest- ' \
                            + ' -lat- ' + i['latitude'].to_s + ' -E- '\
                            + ' -lon- ' + i['longitude'].to_s + ' -E- '\
                            + ' -map- ' \
                            + ' -br-　 ' \
                            + ' -br-　 ' \
                            + ' -E- '                    
            }
            sendMessage += '-E-'          
            Message.create!(message: sendMessage, user_id: 1, room_id: @room.id);
            return true;
          else   
            Message.create!(message: loc+'のレストラン（キーワード；'+keywords+'）は見つかりませんでした。', user_id: 1, room_id: @room.id) 
            return true;
          end 

        end   

      }      

      return false;
    end



  end

  

  def request_recommend_kankou(data)
    # 検索した観光スポットを表示する
    Rails.logger.debug("メッセージ: #{data['text']}")
    Message.create!(message: data['text'], user_id: 1, room_id: @room.id)
  end


  def request_recommend_yado(data)
    yado = use_api(data, 'yado');
    Rails.logger.debug("検索キーワード: #{data['keyword']}")
    Rails.logger.debug("検索結果: #{yado}")
    Message.create!(message: yado["hotels"][0]["hotel"][0]["hotelBasicInfo"]["hotelName"], user_id: 1, room_id: @room.id)
  end

  def suggest (data)
    data = data['data']
    @room = Room.find_by(url: data['room_url'])
    @user = User.find(data['user_id'])
    url = data['suggest_url']
    url = url.gsub(/http:(.*)/, 'https:\1')
    result = ApplicationController::scrape(url)
    @suggests = Suggest.find_by(url: url, room_id: @room.id, enable: true)  #サジェストがリストに登録されていれば、再登録させない
    if @suggests != nil then
      Rails.logger.debug("すでにおすすめリストに存在")
      return
    end
    suggest = Suggest.create!(url: url, title: result[:title], description: result[:description], image: result[:image], room_id: @room.id, user_id: @user.id)

    dom = ApplicationController.renderer.render partial: 'rooms/suggest_item', locals: { suggest: suggest}
    ActionCable.server.broadcast(@room_name, {type: 'suggest', data: {dom: dom} })
  end

  def start_vote(data)
    data = data['data']
    suggest_ids = data['suggest_list']
    @suggests = Suggest.where('id IN (?)', suggest_ids)
    @vote = Vote.create!(name: data['name'], content: data['content'])
    ids = []
    @suggests.each do |suggest|
      ids.push suggest.id
    end
    ActionCable.server.broadcast(@room_name, {type: 'start_vote', data: { vote:{id: @vote.id, name: data['name'], content: data['content']}, suggest: { ids: ids }}})
  end

  def vote(data)
    data = data['data']
    suggest_id = data['suggest_id']
    @user = User.find(data['user_id'])
    vote_result = VoteResult.find_by(vote_id: data['vote_id'], user_id: @user.id)
    if vote_result.nil?
      VoteResult.create!(vote_id: data['vote_id'], suggest_id: suggest_id, user_id: @user.id)
      ActionCable.server.broadcast(@room_name, {type: 'vote', data: { suggest_id: suggest_id }})
    end
  end

  def finish_vote(data)
    data = data['data']
    result = data['vote_result'].map do |k , v|
      [k, v.to_i]
    end.to_h
    decided_id = result.max{|a,b| a[1] <=> b[1]}.first.to_i
    # TODO dbにいれる
    d = @suggests.find(decided_id)
    @suggests.update_all(enable: false)
    # decided = { id: d.id, title: d.title, url:d.url }
    decided = Decided.create!(room_id: @room.id, suggest_id: decided_id)
    dom = ApplicationController.renderer.render partial: 'rooms/decided_item', locals: { decided: decided }
    # ActionCable.server.broadcast(@room_name, {type: 'finish_vote', data: {user: {user_id: @user.id} }})
    p dom
    ActionCable.server.broadcast(@room_name, {type: 'finish_vote', data: { dom: dom }})
  end

  def define_timer(data)
    target = data['data']
    if target.match(/\d{4}\-\d{2}\-\d{2}\s\d{2}\:\d{2}\:\d{2}.\d{3}/) != nil
      ActionCable.server.broadcast(@room_name, {type: 'define_timer', data: {target: target}})
      Message.create!(message: "タイマーをセットします", user_id: 1, room_id: @room.id)
    else
      Message.create!(message: "タイマーセットに失敗しました。形式が間違っています", user_id: 1, room_id: @room.id)
    end
  end

  def define_topic(data)
    data = data['data']
    time = data['time']
    topic_name = data['topic_name']
    ActionCable.server.broadcast(@room_name, {type: 'define_topic', data: {time: time, topic: topic_name}})
    Topic.create!(name: topic_name, time: time, room_id: @room.id)
    Message.create!(message: "タイマーをセットします", user_id: 1, room_id: @room.id)
  end

end
