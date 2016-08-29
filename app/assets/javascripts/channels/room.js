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
        Chat.utils.received_chat(data['data']);
        break;
      case 'suggest':
        Chat.utils.received_suggest(data['data']);
        break;
      case 'start_vote':
        Chat.utils.received_start_vote(data['data']);
        break;
    var message = "<div class='col-md-9 chat_frame_right'><p>Name: " + data.user.name + "</p><p>Message: " + data.message+ "</p></div>"
    var icon = "<div class='col-md-3 icon'><p>icon</p> </div>"
    var dom = ""
    if (parseInt(data.user.id) == $('#current_user').data('current_user_id')) {
      dom =  message + icon
    } else {
      dom = icon + message
    }

  },

  speak: function(data) {
    this.perform('speak', { message: data });
  },

  suggest: function(data) {
    console.log(data);
    this.perform('suggest', { data: data })
  },
  
  start_vote: function(data) {
    this.perform('start_vote', { data: data});
  }
  
});

(function() {
  Chat = {};
  Chat.utils = {
    received_chat: function(data) {
      var message = "<div class='col-md-9'><p>Name: " + data.user.name + "</p><p>Message: " + data.message+ "</p></div>"
      var icon = "<div class='col-md-3'><p>icon</p> </div>"
      var dom = ""
      if (parseInt(data.user.id) == $('#current_user').data('current_user_id')) {
        dom =  message + icon
      } else {
        dom = icon + message
      }
      $('#message_list').append(dom)
    },
    
    received_suggest: function(data) {
      var dom = "<li><div class='suggest_item'>" +
        "<h3 class='suggest_title'>" + data['title'] + "</h3>" +
        "<img class='suggest_image' src = " + data['image'] + " width='180' height='150'>" +
        "<p class='suggest_description'>" + data['description'] + "</p>" +
        "<div class='suggest_id' data-suggest_id=" + data['suggest_id']+ "></div></div></li>";
      $('#suggest_list').append(dom)
    },
    received_start_vote: function(data) {
      suggest = data['suggest'];
      var doms = "<ul id='vote_list'>";
      $.each(suggest['titles'], function(idx, val) {
        doms += "<li><div>"+ val +" </div></li>";
      });
      doms += "</ul>"
      $('#vote_area').append(doms);
      console.log(data)

    }
  };
})();
