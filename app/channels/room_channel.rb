# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class RoomChannel < ApplicationCable::Channel
  def subscribed
    @room = Room.find_by(url: params[:room])
    @room_name = "room_#{@room.url}"
    stop_all_streams
    stream_from @room_name
  end

  def unsubscribed
    stop_all_streams
  end

  def speak (data)
    #TODO user_idを入れる
    Message.create!(message: data['message'], user_id: 1, room_id: @room.id)
  end

end
