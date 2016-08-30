# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class RoomChannel < ApplicationCable::Channel
  def subscribed
    p @room
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
    @room = Room.find_by(url: data['room_url'])
    @user = User.find(data['user_id'])
    url = data['suggest_url']
    result = ApplicationController::scrape(url)
    id = Suggest.create!(url: url, title: result[:title], description: result[:description], image: result[:image], room_id: @room.id, user_id: @user.id).id
    ActionCable.server.broadcast(@room_name, {type: 'suggest', data: result.merge({suggest_id: id, url: url, user_name: @user.name})})
  end

  def start_vote(data)
    data = data['data']
    suggest_ids = data['suggest_list']
    @suggests = Suggest.where('id IN (?)', suggest_ids)
    vote = Vote.create!(name: data['name'], content: data['content'])
    ids = []
    p @suggests
    @suggests.each do |suggest|
      ids.push suggest.id
      VoteToSuggest.create!(vote_id: vote.id, suggest_id: suggest.id)
    end
    ActionCable.server.broadcast(@room_name, {type: 'start_vote', data: { vote:{id: vote.id, name: data['name'], content: data['content']}, suggest: { ids: ids }}})
  end

  def vote(data)
    data = data['data']
    suggest_id = data['suggest_id']
    @user = User.find(data['user_id'])
    VoteResult.create!(vote_id: data['vote_id'], suggest_id: suggest_id, user_id: @user.id)
  end
end
