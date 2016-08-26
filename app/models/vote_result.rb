class VoteResult < ApplicationRecord
  belongs_to :vote
  belongs_to :user
  belongs_to :suggest
end
