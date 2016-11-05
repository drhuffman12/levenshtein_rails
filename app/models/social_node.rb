class SocialNode < ApplicationRecord
  belongs_to :word_orig, autosave: false, class_name: "Word", counter_cache: false, foreign_key: :word_orig_id, inverse_of: :word_orig_soc_nodes
  belongs_to :word_from, autosave: false, class_name: "Word", counter_cache: false, foreign_key: :word_from_id, inverse_of: :word_from_soc_nodes
  belongs_to :word_to, autosave: false, class_name: "Word", counter_cache: false, foreign_key: :word_to_id, inverse_of: :word_to_soc_nodes
end

# belongs_to :hist_from, autosave: true, class_name: "Histogram", counter_cache: true, inverse_of: :hist_from_friends
# belongs_to :hist_to, autosave: true, class_name: "Histogram", counter_cache: true, inverse_of: :hist_to_friends
#
# belongs_to :word_from, autosave: true, class_name: "Word", counter_cache: true, inverse_of: :word_from_friends
# belongs_to :word_to, autosave: true, class_name: "Word", counter_cache: true, inverse_of: :word_to_friends
#
# has_many :word_orig_soc_nodes, inverse_of: :word_orig
# has_many :word_from_soc_nodes, inverse_of: :word_from
# has_many :word_to_soc_nodes, inverse_of: :word_to
