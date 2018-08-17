class Trip < ApplicationRecord
  belongs_to :user, touch: true

  has_many :itineraries
  has_many :countries, through: :itineraries

  validates :countries, presence: true
end
