class RoomToUsersController < ApplicationController
	#before_action :logged_in_user

  def create
  	room = Room.find(params[:room_id])
    current_user.enter(room)
    redirect_to room
  end

  def destroy
  	room = RoomToUser.find(params[:id]).room
    current_user.out(room)
    redirect_to rooms_path
  end
end
