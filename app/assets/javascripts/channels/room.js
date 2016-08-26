App.room = App.cable.subscriptions.create({ channel: 'RoomChannel', room: window.location.href.match(/rooms\/(.*$)/).pop() }, {
  connected: function() {
    this.perform('subscribed')
  },

  disconnected: function() {
    this.perform('unsubscribed')
  },

  received: function(data) {
    // TODO domに追加
    console.log(data)
   
  },

  speak: function(message) {
    this.perform('speak', { message: message })
  }

});
