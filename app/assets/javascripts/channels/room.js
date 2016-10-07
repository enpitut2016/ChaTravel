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
    }
  },

  speak: function(data) {
    this.perform('speak', { message: data });
  },

  request_recommend: function(data) {
    this.perform('request_recommend', { data: data });
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
  }
});

(function() {
  Chat = {};
  Chat.received_func = {
    received_chat: function(data) {
      var message =
          "<p>" + data.user.name + "</p>" +
          "<p>" + data.message + "</p>";
      var icon = "<img alt='"+ data.user.name + "' class='gravatar' src="+ data.user.icon + ">";

      var dom = "";

      if (parseInt(data.user.id) == $('#current_user').data('current_user_id')) {
        dom = "<li class=" + data.user.name + "><div class='row'>"
        + "<div class='comment col-md-9 chat_frame_right'>" + message + "</div>"
        + "<div class='col-md-3 icon_right'>" + icon + "</div></div></li>";
      } else {
        dom = "<li class=" + data.user.name + "><div class='row'>"
        + "<div class='col-md-3 icon_left'>" + icon + "</div>"
        + "<div class='comment col-md-9 chat_frame_left'>" + message + "</div></div></li>";
      }
      $('#message_list').append(dom)
      $('#message_list').animate({scrollTop: $('#message_list')[0].scrollHeight}, 'slow');
    },

    received_suggest: function(data) {
      var dom = "<div class='panel panel-default'>" +
        "<div class='panel-heading'>" +
        "<h5 class='suggest_title_wrapper panel-title'>" +
        "<a data-toggle='collapse' data-parent='#accordion' href='#suggest_" + data.suggest_id + "' class='suggest_collapse'> " +
        "<p class='suggest_title' >" + data.title + "</p>" +
        "<span class='badge vote_badge' id='badge_suggest_"+ data.suggest_id +"'>0</span>" +
        "</a>" +
        "</h5>" +
        "</div>" +
        "<div id='suggest_" + data.suggest_id +"' class='panel-collapse collapse'>" +
        "<div class='panel-body'>" +
        "<div id='media'>" +
        "<a href='#' class='media-left'>" +
         "<img src='"+ data.image +"' class='suggest_image' width='180' height='150'>" +
        "</a>" +
        "<p class='suggest_description media-body'>" +
          data.description + "</p></div></div></div>" +
        "<div class='suggest_id' data-suggest_id='" + data.suggest_id + "'></div>" +
        "</div>";

      $('.suggest_list').append(dom);
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
      var dom = "<li><a href='"+ data.decided.url +"'>"+ data.decided.title +"</a></li>"
      $('#decided_list').append(dom);
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
