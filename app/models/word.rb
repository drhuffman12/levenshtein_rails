require 'json'

class Word < ApplicationRecord
  # TODO: add field for orig_name OR usable_name to Word
  # TODO: add 'is_test_word' flag (set 'true' for all words before 'ENDOFINPUT')
  # TODO: exclude 'ENDOFINPUT'

  belongs_to :word_length , inverse_of: :words
  belongs_to :histogram , inverse_of: :words

  has_many :word_from_friends, class_name: WordFriend, foreign_key: :word_from_id
  has_many :word_to_friends, class_name: WordFriend, foreign_key: :word_to_id

  has_many :word_orig_soc_nodes, class_name: SocialNode, foreign_key: :word_orig_id
  has_many :word_from_soc_nodes, class_name: SocialNode, foreign_key: :word_from_id
  has_many :word_to_soc_nodes, class_name: SocialNode, foreign_key: :word_to_id

  has_many :raw_words # , class_name: RawWord, foreign_key: :id

  serialize :traversed_ids

  before_save :reset_length

  # def raw_words
  #   RawWord.where(word_id: id)
  # end

  def in_soc_net
    Word.where(id: ((traversed_ids || []) - [id]))
  end

  def in_soc_net_names
    in_soc_net.pluck(:name)
  end

  def word_friends # in_friend_net
    # WordFriend.where(word_from_id: id).join(:words).where
    WordFriend.where(word_from_id: id)
  end

  def word_friends_words
    Word.where(id: word_friends ? word_friends.pluck(:word_to_id) : nil)
  end

  def word_friends_word_names
    word_friends_words ? word_friends_words.pluck(:name) : nil
  end

  def in_friend_names
    word_from_friends.pluck(:name)
  end

  def reset_length
    usable_name = Word.to_usable(name)
    self.name = usable_name
    len = usable_name.length
    self.length ||= len
    unless self.word_length
      wl = WordLength.find_or_create_by(length: len)
      self.word_length = wl
    end

    unless self.histogram
      hist_tos = Word.to_simple_hist(usable_name).to_s
      related_hist = Histogram.find_or_create_by(hist: hist_tos)

      related_hist.length = len
      related_hist.word_length = wl
      related_hist.save
      self.histogram = related_hist
    end
  end

  EXCLUDE_CHARS = ["\n","\r","'","-"," "] # ["\n","\r"] # ["\n","\r","'"]
  def self.to_usable(name)
    name.split('').reject { |c| EXCLUDE_CHARS.include?(c) }.join
  end

  private

  def self.to_simple_hist(word_name)
    hist = Hash.new(0)
    word_name.split('').sort.each do |char|
      s = char.to_sym
      hist[s] += 1
    end
    hist
  end

  def self.friends_in_mem?(word_a_name, word_b_name)
    word_length_delta = word_b_name.length - word_a_name.length
    return false unless [-1, 0, 1].include?(word_length_delta)
    hist_a = Word.to_simple_hist(word_a_name)
    hist_b = Word.to_simple_hist(word_b_name)
    friends_hist_type = Histogram.friends_hist_type(hist_a, hist_b)
    if [-1, 1].include?(word_length_delta)
      friends_word_type_len_delta_1(word_a_name, word_b_name, friends_hist_type)
    else
      friends_word_type_len_delta_0(word_a_name, word_b_name, hist_a, hist_b, friends_hist_type)
    end
  end

  def self.friends?(word_a_name, word_b_name)
    word_length_delta = word_b_name.length - word_a_name.length
    return false unless [-1, 0, 1].include?(word_length_delta)

    hist_a = Word.where(:name => word_a_name).includes(:histogram).first
    hist_b = Word.where(:name => word_b_name).includes(:histogram).first

    hist_a = hist_a ? hist_a.histogram : Histogram.find_or_create_by(hist: Word.to_simple_hist(word_a_name).to_s)
    hist_b = hist_b ? hist_b.histogram : Histogram.find_or_create_by(hist: Word.to_simple_hist(word_b_name).to_s)

    if !hist_a || !hist_b
      msg = "#{self.class.name}##{__method__} -> word_a_name: #{word_a_name}, word_b_name: #{word_b_name}, hist_a: #{hist_a || '(nil)'}, hist_b: #{hist_b || '(nil)'}"
      Rails.logger.debug msg
      puts msg
    end
    friends_hist_type = Histogram.friends_hist_type(eval(hist_a.hist), eval(hist_b.hist)) # TODO: pull from 'hist_friends' table

    if [-1, 1].include?(word_length_delta)
      friends_word_type_len_delta_1(word_a_name, word_b_name, friends_hist_type)
    else
      friends_word_type_len_delta_0(word_a_name, word_b_name, hist_a, hist_b, friends_hist_type)
    end

  end

  def self.friends_in_db?(word_a, word_b)
    word_length_delta = word_b.length - word_a.length
    return false unless [-1, 0, 1].include?(word_length_delta)

    hist_a = word_a.histogram
    hist_b = word_b.histogram

    if !hist_a || !hist_b
      msg = "#{self.class.name}##{__method__} -> word_a: #{word_a}, word_b: #{word_b}, hist_a: #{hist_a || '(nil)'}, hist_b: #{hist_b || '(nil)'}"
      Rails.logger.debug msg
      puts msg
    end
    friends_hist_type = Histogram.friends_hist_type(eval(hist_a.hist), eval(hist_b.hist)) # TODO: pull from 'hist_friends' table

    if [-1, 1].include?(word_length_delta)
      friends_word_type_len_delta_1(word_a.name, word_b.name, friends_hist_type)
    else
      friends_word_type_len_delta_0(word_a.name, word_b.name, hist_a, hist_b, friends_hist_type)
    end

  end

  private

  def self.friends_word_type_len_delta_1(word_a_name, word_b_name, friends_hist_type)
    return false if friends_hist_type != 1
    friend_seq?(word_a_name, word_b_name)
  end

  def self.friends_word_type_len_delta_0(word_a_name, word_b_name, hist_a, hist_b, friends_hist_type)
    return false if hist_a == hist_b
    return false if friends_hist_type != 2
    friend_seq?(word_a_name, word_b_name)
  end

  # sequence related:
  def self.friend_seq?(word_a_name, word_b_name)
    len_a = word_a_name.length
    len_b = word_b_name.length
    is_done = (len_a == 0) || (len_b == 0)
    delta = a = b = 0
    until is_done
      let_a = word_a_name[a]
      let_b = word_b_name[b]
      is_same = let_a == let_b
      a_next = a + 1
      b_next = b + 1
      done_a_next = a_next >= len_a
      done_b_next = b_next >= len_b

      if is_same
        # go to next char
        a = a_next
        b = b_next

      else
        delta += 1

        let_a_next = word_a_name[a_next]
        let_b_next = word_b_name[b_next]
        has_a_next = !done_a_next
        has_b_next = !done_b_next

        # which kind of delta; decide how to inc a and b:
        if has_a_next || has_b_next
          case
            when done_a_next
              # end of word_a_name, start counting extra letters from word_b_name
              b = b_next
            when done_b_next
              # end of word_b_name, start counting extra letters from word_a_name
              a = a_next
            when let_a_next == let_b
              # word_a_name has extra letter
              a = a_next
            when let_a == let_b_next
              # word_b_name has extra letter
              b = b_next
            when let_a_next == let_b_next
              # both diff at a and b, but re-sync at next chars
              # so go to next chars
              a = a_next
              b = b_next
            else
              # Neither 'next' char matches
              # We'd have to try various combo's of 'currnet' vs next' vs 'next-next'
              # Either way, we'd exceed our limit of on, so just bump up delta
              delta += 1
          end
        else
          # at ends of both words, so can't check further, so done
        end
      end

      is_done = (delta > 1) || (done_a_next && done_b_next)
    end
    delta == 1
  end
end
