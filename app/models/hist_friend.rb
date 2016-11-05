class HistFriend < ApplicationRecord
  belongs_to :hist_from, autosave: false, class_name: "Histogram", foreign_key: :id
  belongs_to :hist_to, autosave: false, class_name: "Histogram", foreign_key: :id
end
