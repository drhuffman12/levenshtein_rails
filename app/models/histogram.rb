class Histogram < ApplicationRecord
  belongs_to :word_length , inverse_of: :histograms
  has_many :words , inverse_of: :histogram

  has_many :hist_from_friends , inverse_of: :hist_from
  has_many :hist_to_friends , inverse_of: :hist_to

  # store :hist, accessors: [ :letters, :homepage ], coder: JSON
  # store :hist, coder: JSON
  serialize :hist
  # serialize :hist #, Hash
  # serialize :hist #, JSON

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

  # Histogram.friends_hist?(hist_a, hist_b)
  # Histogram.friends_hist_type(hist_a, hist_b)
  def self.friends_hist_type(hist_a, hist_b)
    dist = distance_hist(hist_a, hist_b)
    d = delta_hist(hist_a, hist_b)
    dt = delta_trimmed(d)
    key_cnt = dt.keys.count
    if (dist == key_cnt)
      case dist
        when 1
          1 # true
        when 2
          dtk = dt.keys
          2 if (dt[dtk[0]] == - dt[dtk[1]])
        else
          0 # false
      end
    else
      false
    end
  end
end
