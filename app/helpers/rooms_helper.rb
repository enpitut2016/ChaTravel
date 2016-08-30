module RoomsHelper
  def get_suggest_title_from_decided(id)
    Suggest.find(id).title
  end
end
