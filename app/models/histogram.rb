class Histogram < ApplicationRecord
  belongs_to :word_length , inverse_of: :histograms
  has_many :words , inverse_of: :histogram

  has_many :hist_from_friends, class_name: "HistFriend", foreign_key: :hist_from_id
  has_many :hist_to_friends, class_name: "HistFriend", foreign_key: :hist_to_id

  serialize :hist

  def hist_from_friends
    HistFriend.where(hist_from: id)
  end

  def self.combine_keys(hist_a, hist_b)
    (hist_a.keys << hist_b.keys).flatten
  end

  def self.delta_hist(hist_a, hist_b)
    delta = {}
    delta_keys = combine_keys(hist_a, hist_b)
    delta_keys.each do |key|
      a = hist_a[key] || 0
      b = hist_b[key] || 0
      delta[key] = b - a
    end
    delta
  end

  def self.delta_trimmed(a_delta_hist)
    a_delta_hist.delete_if { |key, value| value == 0 }
  end

  def self.distance_hist(hist_a, hist_b)
    delta_hist(hist_a, hist_b).values.inject(0) { |sum, v| sum + v.abs }
  end

  def self.length_hist(hist_a)
    hist_a.values.inject(0) { |sum, v| sum + v }
  end

  def self.friends_hist_type(hist_a, hist_b)
    dist = distance_hist(hist_a, hist_b)
    d = delta_hist(hist_a, hist_b)
    dt = delta_trimmed(d)
    key_cnt = dt.keys.count
    if (dist == key_cnt)
      case dist
        when 1
          1 # aka true
        when 2
          dtk = dt.keys
          2 if (dt[dtk[0]] == - dt[dtk[1]]) # aka true
        else
          0 # aka false
      end
    else
      false
    end
  end
end
