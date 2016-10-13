class HistFriend < ApplicationRecord
  belongs_to :hist_from, autosave: false, class_name: "Histogram", inverse_of: :hist_from_friends
  belongs_to :hist_to, autosave: false, class_name: "Histogram", inverse_of: :hist_to_friends
end
#  counter_cache: true,