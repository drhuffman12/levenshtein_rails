class WordLength < ApplicationRecord
  has_many :words #, inverse_of: :word_length
  has_many :histograms #, inverse_of: :word_length
end
