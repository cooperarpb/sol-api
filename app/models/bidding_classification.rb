class BiddingClassification < ApplicationRecord
  belongs_to :bidding
  belongs_to :classification

  validates :bidding,
            :classification,
            presence: true
end
