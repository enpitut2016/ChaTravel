class StaticPagesController < ApplicationController
  def home
	  @room = Room.new
  end

  def help
  end
end
