class MessageBroadcastJob < ApplicationJob
  queue_as :default

  def perform(message)
    room_name = "room_#{Room.find(message.room_id).url}"
    u = User.find(message.user_id)
    gravatar_id = Digest::MD5::hexdigest(u.icon.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}"
    icon = image_tag(gravatar_url, alt: user.name, class: "gravatar")
    user = { id: u.id, name: u.name, icon: icon}
    ActionCable.server.broadcast(room_name, { type: 'chat', data: { user: user ,message: message.message }})
  end
end
