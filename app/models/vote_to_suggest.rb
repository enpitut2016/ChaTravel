class VoteToSuggest < ApplicationRecord
  belongs_to :vote
  belongs_to :suggest
end
