# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class RoomChannel < ApplicationCable::Channel
  def subscribed
    p @room
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

  #botの返答
  def request_bot_response(data)

    #形態素解析を行い、もしメッセージを表示するイベントが行われていたらreturn
    isMes = decomposeSentences(data);
    if isMes == true then
      return;
    end 


    #雑談APIを使い、適当な返答をする。もし、エラーがあれば"zzz"と返す
    chatRes = use_api(data,'chat');
    if chatRes == nil then
      Message.create!(message: "zzz", user_id: 1, room_id: @room.id)
      return
    end
    Message.create!(message: chatRes['result'], user_id: 1, room_id: @room.id)
    

  end

  #botAPIの処理
  def use_api(data,type)
    
    case type
    when 'chat'
      params = URI.encode_www_form({ message: data['data'], key: 'd18e1f9b28ac66406002'})
      uri = URI.parse("https://chatbot-api.userlocal.jp/api/chat?#{params}")
    when 'dec'
      params = URI.encode_www_form({ message: data['data'], key: 'd18e1f9b28ac66406002'})
      uri = URI.parse("https://chatbot-api.userlocal.jp/api/decompose?#{params}")
    when 'geo'
      params = URI.encode_www_form({ method: 'suggest', matching: 'prefix', keyword: data})
      uri = URI.parse("http://geoapi.heartrails.com/api/json?#{params}")
    when 'eki'
      #http://express.heartrails.com/api/json?method=getStations&name=%22%E6%96%B0%E5%B7%9D%22
    when 'gMap'
      ActionCable.server.broadcast(@room_name, {type: 'gmap_command', data: { user_id: current_user.id, word: j } }) #クライアント側にデータを送信
      return
    when 'gnavi'
      params = URI.encode_www_form({ keyid: '39da3c7e2563a8d9f4ba015c4e173268', format: 'json', address: data['address'], hit_per_page: '1', freeword: data['freeword']})
      uri = URI.parse("http://api.gnavi.co.jp/RestSearchAPI/20150630/?#{params}")
    else
      Rails.logger.debug("API Type Error")
      return
    end

    begin

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|        
        http.open_timeout = 5 # Net::HTTP.open_timeout=で接続時に待つ最大秒数の設定をする。タイムアウト時はTimeoutError例外が発生
        http.read_timeout = 10 # Net::HTTP.read_timeout=で読み込み1回でブロックして良い最大秒数の設定をする
        http.get(uri.request_uri) # 返り値はNet::HTTPResponseのインスタンス
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
    decRes = use_api(data,'dec');
    result = decRes['result'];
    Rails.logger.debug("#{result}(#{result[0]})");
    nouns = [];
    yomis = [];
    for i in result do
      surface = i['surface'];
      pos = i['pos'];
      yomi = i['yomi']
      if yomi == '*' then
        yomi = surface.tr('ぁ-ん','ァ-ン'); #読みがアスタリスクだったら、surfaceをカタカナに変換して代入 
      end  
      Rails.logger.debug("#{surface}(#{pos})"); #結果を表示

      if pos == "名詞" then
        nouns.push(surface);
        yomis.push(yomi);
      end
    end


    if yomis.include?("オススメ") then #チャット内容に読みが「オススメ」の文字を含んでいて

        for j in nouns do
          res = use_api(j,'geo');
          if res['response'].key?('error') == false then #実在する地名の文字も含んでいたら
            gnavi = use_api({"address" => j, "freeword" => 'カレー'},'gnavi');
            Message.create!(message: j+'のオススメのカレー屋さんを教えるニャ　「'+gnavi['rest']['name']+'」'+gnavi['rest']['url'], user_id: 1, room_id: @room.id)

            return true;
          end
        end  
        Message.create!(message: 'わからないにゃ...', user_id: 1, room_id: @room.id) 
      
    end

  end

  

  def request_recommend_kankou(data)
    # 検索した観光スポットを表示する
    Message.create!(message: data['text'], user_id: 1, room_id: @room.id)
  end

  def suggest (data)
    data = data['data']
    @room = Room.find_by(url: data['room_url'])
    @user = User.find(data['user_id'])
    url = data['suggest_url']
    result = ApplicationController::scrape(url)
    id = Suggest.create!(url: url, title: result[:title], description: result[:description], image: result[:image], room_id: @room.id, user_id: @user.id).id
    ActionCable.server.broadcast(@room_name, {type: 'suggest', data: result.merge({suggest_id: id, url: url, user_name: @user.name})})
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
      ActionCable.server.broadcast(@room_name, {type: 'vote', data: { suggest_id: suggest_id}})
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
    decided = { id: d.id, title: d.title, url:d.url }
    Decided.create!(room_id: @room.id, suggest_id: decided_id)
    ActionCable.server.broadcast(@room_name, {type: 'finish_vote', data: {user: {user_id: @user.id} }})
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
end
