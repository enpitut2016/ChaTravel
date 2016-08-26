# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class RoomChannel < ApplicationCable::Channel
  def subscribed
    @room = Room.find_by(url: params[:room])
    @room_name = "room_#{@room.url}"
    stream_from @room_name
  end

  def unsubscribed
    stop_all_streams
  end

  def speak (data)
    ActionCable.server.broadcast(@room_name, message: data['message'])
  end

end
