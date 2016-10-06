class Word < ApplicationRecord
  belongs_to :word_length , inverse_of: :words
  belongs_to :histogram , inverse_of: :words
  has_many :words
  has_many :word_from_friends, inverse_of: :word_from
  has_many :word_to_friends, inverse_of: :word_too

  has_many :word_orig_soc_nodes, inverse_of: :word_orig
  has_many :word_from_soc_nodes, inverse_of: :word_from
  has_many :word_to_soc_nodes, inverse_of: :word_to
end
