App.room = App.cable.subscriptions.create({ channel: 'RoomChannel', room: window.location.href.match(/^http.*\/(.*?)$/).pop() }, {
  connected: function() {
    this.perform('subscribed')
  },

  disconnected: function() {
    this.perform('unsubscribed')
  },

  received: function(data) {
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

  speak: function(message) {
    this.perform('speak', { message: message })
  }

});
