require 'json'

class Word < ApplicationRecord
  # TODO: add field for orig_name OR usable_name to Word
  # TODO: add 'is_test_word' flag (set 'true' for all words before 'ENDOFINPUT')
  # TODO: exclude 'ENDOFINPUT'

  belongs_to :word_length , inverse_of: :words
  belongs_to :histogram , inverse_of: :words
  # has_many :words
  has_many :word_from_friends, inverse_of: :word_from
  has_many :word_to_friends, inverse_of: :word_too

  has_many :word_orig_soc_nodes, inverse_of: :word_orig
  has_many :word_from_soc_nodes, inverse_of: :word_from
  has_many :word_to_soc_nodes, inverse_of: :word_to

  before_save :reset_length

  def reset_length
    self.name = Word.to_usable(name)
    len = name.length
    # hist = Word.to_simple_hist(name)
    self.length = len
    wl = WordLength.find_or_create_by(length: len)
    self.word_length = wl

    hist_tos = Word.to_simple_hist(name).to_s
    # hist_tos = Word.to_usable_hist(name).to_s
    # self.histogram = Histogram.find_or_create_by(hist: hist)
    # related_hist = Histogram.find_or_create_by_hist(hist)
    related_hist = Histogram.find_or_create_by(hist: hist_tos)

    related_hist.length = len
    related_hist.word_length = wl
    related_hist.save
    # puts "*"*80 + "\nword: #{self}, related_hist: #{related_hist}"
    print '.'
    self.histogram = related_hist
    # self.histogram = Histogram.find_or_create_by(hist: hist.to_s)
    # self.histogram = Histogram.find_or_create_by(hist: hist.to_s)
    # self.histogram = Histogram.find_or_create_by(["hist = ?", hist])
  end

  private

  EXCLUDE_CHARS = ["\n","\r","'","-"," "] # ["\n","\r"] # ["\n","\r","'"]
  def self.to_usable(name)
    name.split('').reject { |c| EXCLUDE_CHARS.include?(c) }.join
  end

  def self.to_simple_hist(word_name)
    hist = Hash.new(0)
    # word_name.gsub("\n",'').gsub("\r",'').split('').sort.each do |letter|
    word_name.split('').sort.each do |char|
      s = char.to_sym
      hist[s] += 1
    end
    hist
  end

  # def self.to_usable_hist(word_name)
  #   hist = Hash.new(0)
  #   # word_name.gsub("\n",'').gsub("\r",'').split('').sort.each do |letter|
  #   to_usable(word_name).split('').sort.each do |char|
  #     s = char.to_sym
  #     hist[s] += 1
  #   end
  #   hist
  # end
  #
  # def self.to_simple_hist_json(word_name)
  #   to_simple_hist(word_name).to_json
  # end
end
