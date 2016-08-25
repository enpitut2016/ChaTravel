class Room < ApplicationRecord
  validates_uniqueness_of :url
  validates_presence_of :url
  after_initialize :set_url

  def to_param
    url
  end

  private
  def set_url
    self.url = self.url.blank? ? generate_url : self.url
  end

  def generate_url
    url = SecureRandom.urlsafe_base64(9)
    print "URL is #{url}"
    puts
    self.class.where(:url => url).blank? ? url : generate_url
  end

end
