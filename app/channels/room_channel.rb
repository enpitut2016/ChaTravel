# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class RoomChannel < ApplicationCable::Channel
  def subscribed
    @room = Room.find_by(url: params[:room])
    @room_name = "room_#{@room.url}"
    # @vote_name = "vote_#{@room.url}"
    stop_all_streams
    stream_from @room_name
    # stream_from @vote_name
  end

  def unsubscribed
    stop_all_streams
  end

  def speak (data)
    #TODO user_idを入れる
    Message.create!(message: data['message'], user_id: 1, room_id: @room.id)
  end

  def suggest (data)
    data = data['data']
    p data
    @room = Room.find_by(url: data['room_url'])
    @user = User.find(data['user_id'])
    url = data['suggest_url']
    result = ApplicationController::scrape(url)
    id = Suggest.create!(url: url, title: result[:title], description: result[:description], image: result[:image], room_id: @room.id, user_id: @user.id).id
    ActionCable.server.broadcast(@room_name, {type: 'suggest', data: result.merge({suggest_id: id,url: url, user_name: @user.name})})
  end

  def start_vote(data)
    ActionCable.server.broadcast(@room_name, {type: 'start_vote', data:data})
  end



end
