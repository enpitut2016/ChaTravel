class StaticPagesController < ApplicationController
  def home
	  @room = Room.new
  end

  def help
  end

  def room_page
	  @room = Room.find_by(name:params[:name])
	  @url  = @room.url
  end
end
