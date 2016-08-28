class User < ApplicationRecord
  validates :name,  presence: true, length: {maximum: 50}, uniqueness: true
  validates :icon, presence: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }


  # 与えられた文字列のハッシュ値を返す 
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
	end
end
	