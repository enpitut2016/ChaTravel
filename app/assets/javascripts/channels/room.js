App.room = App.cable.subscriptions.create({ channel: 'RoomChannel', room: window.location.href.match(/^http.*\/(.*?)$/).pop() }, {
  connected: function() {
    this.perform('subscribed');
  },

  disconnected: function() {
    this.perform('unsubscribed');
  },

  received: function(data) {
    var type = data['type'];
    switch (type) {
      case 'chat':
        Chat.received_func.received_chat(data['data']);
        break;
      case 'suggest':
        Chat.received_func.received_suggest(data['data']);
        break;
      case 'start_vote':
        Chat.received_func.received_start_vote(data['data']);
        break;
      case 'vote':
        Chat.received_func.received_vote(data['data']);
        break;
      case 'finish_vote':
        Chat.received_func.received_finish_vote(data['data']);
        break;
      case 'define_timer':
        Chat.received_func.received_define_timer(data['data']);
        break;
      case 'itsmo_command':
        Chat.received_func.received_itsmo_command(data['data']);
        break;
    }
  },

  speak: function(data) {
    this.perform('speak', { message: data });
  },

  speak_bot: function(data){
    this.perform('speak_bot', {message:data});
  },

  request_bot_response: function(data) {
    this.perform('request_bot_response', { data: data });
  },

  request_recommend_kankou: function(data) {
    console.log(data);
    this.perform('request_recommend_kankou', { text: data });
  },

  request_recommend_yado: function(data) {
    this.perform('request_recommend_yado', { keyword: data });
  },

  suggest: function(data) {
    this.perform('suggest', { data: data });
  },

  start_vote: function(data) {
    this.perform('start_vote', { data: data });
  },

  vote: function(data) {
    this.perform('vote', { data: data });
  },

  finish_vote: function(data) {
    this.perform('finish_vote', { data: data });
  },

  define_timer: function(data){
    this.perform('define_timer', {data: data});
  }
});

(function() {
  Chat = {};
  Chat.received_func = {
    received_chat: function(data) {

      var message = "";
      var gnavi = false;
      var rakuten = false;
      if (data.message.match(/-gnavi-/) && parseInt(data.user.id)==1) {
        message = 
          "<p>" + data.user.name + "</p>" +
          "<p>" + data.message.replace(/(http:\/\/[\x21-\x7e]+)/gi, "<a href='$1' target='_blank'>詳しくはこちら</a>") + "</p>"; //urlなら<a>タグ挿入
        message = message.replace(/-gnavi-/,"");
        gnavi = true;
      } else if (data.message.match(/-rakuten-/) && parseInt(data.user.id)==1) {
        message = ""
        message += "<p>" + data.user.name + "</p>";
        message += "<p>" + data.message + "</p>";

        console.log(data.message);

        message = message.replace(/-rakuten-/,"");
        message = message.replace(/-E-/g,"</div>");
        message = message.replace(/-br-/g,"<br>");
        message = message.replace(/-mainS-/g,"<div class='rakuten_result'>");
        message = message.replace(/-imgS-/g, "<div class='col-md-5'>");
        message = message.replace(/-textS-/g, "<div class='col-md-7'>");

        var url = message.match(/(http:\/\/[\x21-\x7e]+)/gi);
        for(var i=0; i<url.length; i++){
          if( url[i].match(/.jpg/) ){
            message =  message.replace(url[i], "<img class='thumbnail' src="+url[i]+" alt='ホテル画像' >"); 
          }else{
            message = "<p>" + message.replace(url[i], "<a href="+url[i]+" target='_blank'>詳しくはこちら</a>") + "</p>"; //urlなら<a>タグ挿入
          }
        }


        rakuten = true;
      } else {
        message = 
          "<p>" + data.user.name + "</p>" +
          data.message.replace(/(http:\/\/[\x21-\x7e]+)/gi, "<a href='$1' target='_blank'>$1</a>") + "</p>"; //urlなら<a>タグ挿入
      }


      var icon = "<img alt='"+ data.user.name + "' class='gravatar' src="+ data.user.icon + ">";
      var dom = "";

      if (parseInt(data.user.id) == $('#current_user').data('current_user_id')) {
        dom = "<li class=" + data.user.name + "><div class='row'>"
        + "<div class='comment col-md-9 chat_frame_right'>" + message + "</div>"
        + "<div class='col-md-3 icon_right'>" + icon + "</div></div></li>";
      } else {

        if(gnavi){ //ぐるなび用の表示
          dom = "<li class=" + data.user.name + "><div class='row'>"
          + "<div class='col-md-3 icon_left'>" + icon + "</div>"
          + "<div class='comment col-md-9 chat_frame_left'>" + message 
          + "<a href='http://www.gnavi.co.jp/'>"
          + "<div class='api_banner'><img class='gnavi-icon' src='http://apicache.gnavi.co.jp/image/rest/b/api_155_20.gif' alt='グルメ情報検索サイト　ぐるなび'></div>";
          + "</a></div></div></li>";
        } else if(rakuten) { //楽天用の表示
          dom = "<li class=" + data.user.name + "><div class='row'>"
          + "<div class='col-md-3 icon_left'>" + icon + "</div>"
          + "<div class='comment col-md-9 chat_frame_left'>" + message 
          + "<div class='api_banner col-md-12'>"
          +"<!-- Rakuten Web Services Attribution Snippet FROM HERE -->"
          +'<a href="http://webservice.rakuten.co.jp/" target="_blank"><img src="https://webservice.rakuten.co.jp/img/credit/200709/credit_22121.gif" border="0" alt="楽天ウェブサービスセンター" title="楽天ウェブサービスセンター" width="221" height="21"/></a>'
          +"<!-- Rakuten Web Services Attribution Snippet TO HERE -->"
          + "</div></div></div></li>";
        } else {  
          dom = "<li class=" + data.user.name + "><div class='row'>"
          + "<div class='col-md-3 icon_left'>" + icon + "</div>"
          + "<div class='comment col-md-9 chat_frame_left'>" + message + "</div></div></li>";
        }
      }        

      $('#message_list').append(dom);
      $('#message_list').animate({scrollTop: $('#message_list')[0].scrollHeight}, 'slow');
    },

    received_suggest: function(data) {
      $('.suggest_list').append(data.dom);
    },

    received_start_vote: function(data) {
      $('.vote_badge').css({display: 'inline'});
      $('#vote_id').data('vote_id', data.vote.id);
      $('#finish_vote').css({display: 'block'});
      $('#start_vote').css({display: 'none'});
      $('#suggest_name').prop('disabled', true);
      $('#suggest_submit').prop('disabled', true);
      $.each(data.suggest.ids, function (idx, val) {
        $('#badge_suggest_' + val).on('click', function(e) {
          e.stopPropagation();
          // TODO 一回押したら無効化 とりあえずサーバー側で実装してある.
          App.room.vote({
            user_id: Chat.utils.user_id(),
            vote_id: $('#vote_id').data('vote_id'),
            suggest_id: val });
          return false;
        });
      });
    },

    received_vote: function(data) {
      //表示を一つ増やす
      var badge = $('#badge_suggest_' + data.suggest_id);
      badge.text(parseInt(badge.text()) + 1);
    },

    received_finish_vote: function(data) {
    // //  TODO 左側に追加，右側の削除
      $('.vote_badge').css({display: 'none'});
      $('.suggest_list').empty();
      $('#finish_vote').css({display: 'none'});
      $('#start_vote').css({display: 'block'});
      $('#suggest_name').prop('disabled', false);
      $('#suggest_submit').prop('disabled', false);
      $('.decided_list').append(data.dom);
    },

    received_define_timer: function(data){
      $('#targetDate').text(data['target']);
    },


    received_itsmo_command: function(data){
      console.log(data);
      if (parseInt(data.user_id) == $('#current_user').data('current_user_id')) { //コマンドの受け取りが投稿者自身であったら
        ZDC.Search.getPoiByWord({word: data.word, limit: "0,1", genrecode: "0012000150" }, function(status, res) {
          if (status.code === '000') {
            App.room.request_recommend_kankou(res.item[0].text);
          } else {
            alert(status.text);
          }
        });

      }else{
        console.log("other");
      }
    }

  };

  Chat.utils = {
    room_url: function() {
      return window.location.href.match(/^http.*\/(.*?)$/).pop()
    },
    user_id: function() {
      return $('#current_user').data('current_user_id')
    }
  }
})();
