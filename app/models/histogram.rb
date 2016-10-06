class Histogram < ApplicationRecord
  belongs_to :word_length , inverse_of: :histograms
  has_many :words , inverse_of: :histogram
  # store :hist, accessors: [ :letters, :homepage ], coder: JSON
  store :hist, coder: JSON
end
