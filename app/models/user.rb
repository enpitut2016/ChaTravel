class User < ApplicationRecord
  has_many :room_to_users, class_name:  "RoomToUser",
                                  dependent:   :destroy
  has_many :rooms, through: :room_to_users
  has_many :messages, dependent: :destroy

  validates :name,  presence: true, length: {maximum: 50}, uniqueness: true
  validates :icon, presence: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, on: :create


  # グループに参加する
  def enter(room)
    room_to_users.create(room_id: room.id)
  end

  # グループを退出
  def out(room)
    room_to_users.find_by(room_id: room.id).destroy
  end

  # 現在のユーザーが参加していたらtrueを返す
  def entering?(room)
    rooms.include?(room)
  end

  # 与えられた文字列のハッシュ値を返す 
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
	end
end
	