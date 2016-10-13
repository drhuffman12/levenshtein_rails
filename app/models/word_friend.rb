class WordFriend < ApplicationRecord
  belongs_to :word_from, autosave: false, class_name: "Word", counter_cache: false, inverse_of: :word_from_friends
  belongs_to :word_to, autosave: false, class_name: "Word", counter_cache: false, inverse_of: :word_to_friends
end
