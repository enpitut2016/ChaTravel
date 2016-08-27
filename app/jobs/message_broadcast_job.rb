class MessageBroadcastJob < ApplicationJob
  queue_as :default

  def perform(message)
    room_name = "room_#{Room.find(message.room_id).url}"
    ActionCable.server.broadcast(room_name, { user_name: User.find(message.user_id).name ,message: message.message })
  end
end
