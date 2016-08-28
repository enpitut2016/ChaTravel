class MessageBroadcastJob < ApplicationJob
  queue_as :default

  def perform(message)
    room_name = "room_#{Room.find(message.room_id).url}"
    u = User.find(message.user_id)
    user = { id: u.id, name: u.name }
    ActionCable.server.broadcast(room_name, { user: user ,message: message.message })
  end
end
