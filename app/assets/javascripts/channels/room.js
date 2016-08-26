App.room = App.cable.subscriptions.create({ channel: 'RoomChannel', room: window.location.href.match(/rooms\/(.*$)/).pop() }, {
  connected: function() {
    this.perform('subscribed')
  },

  disconnected: function() {
    this.perform('unsubscribed')
  },

  received: function(data) {
    // Called when there's incoming data on the websocket for this channel
    // TODO domに追加
    console.log(data)
  },

  speak: function(message) {
    // console.log(message)
    this.perform('speak', {message: message})
  }

});
