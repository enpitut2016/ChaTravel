class StaticPagesController < ApplicationController
  def home
	  @room = Room.new
  end

  def help
  end
  def room_page
	  @room = Room.last
	  @url  = @room.url
  end
end
