class Room < ApplicationRecord
  has_many :room_to_users, class_name:  "RoomToUser",
                                  dependent:   :destroy
  has_many :users, through: :room_to_users
  has_many :messages, dependent: :destroy
  has_many :suggests, dependent: :destroy
  has_many :decideds, dependent: :destroy
  has_many :topics, dependent: :destroy

  validates_uniqueness_of :url
  validates_presence_of :url
  after_initialize :set_url
  validates :name, presence: true,length: { maximum: 50}


  def to_param
    url
  end

  private
  def set_url
    self.url = self.url.blank? ? generate_url : self.url
  end

  def generate_url
    url = SecureRandom.urlsafe_base64(9)
    self.class.where(:url => url).blank? ? url : generate_url
  end

end
