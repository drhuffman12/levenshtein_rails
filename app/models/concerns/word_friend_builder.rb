# TODO: Pull code out of Loader and into WordFriendBuilder (i.e.: replace broken code in WordFriendBuilder with code form Loader)
# wfb = WordFriendBuilder.new; wfb.run;nil
# wfb.lengths_to_hist_ids
# wfb.friends_word_from_ids_to_word_to_ids
# from_hist_ids = [7]; to_length = 2; hist_to_friends = HistFriend.where(hist_from_id: from_hist_ids, to_length: to_length).includes(:hist_to); hist_to_friends.all.each {|htf| puts htf, htf.hist_to.words};nil # .includes(:words)

class WordFriendBuilder

  attr_reader :lengths, :lengths_to_hist_ids #, :hist_ids_to_hist_friends_ids
  attr_reader :hist_ids_to_words, :friends_word_from_ids_to_word_to_ids

  def initialize
    @lengths = []
    @lengths_to_hist_ids = {}
    @hist_ids_to_hist_friends_ids = {}
    @hist_ids_to_words = {}
    @friends_word_from_ids_to_word_to_ids = {}
  end

  def run
    WordFriend.delete_all # if writable
    update_hist_friends_lengths
    cache_lengths_and_histograms
    cache_hist_ids_to_words
    connect
  end

  def cache_lengths_and_histograms
    Rails.logger.debug "#{self.class.name}##{__method__}"
    WordLength.order(:length).includes(:histograms).all.each do |word_length| # .select(:length)
      cache_length_histograms(word_length)
    end
    @lengths = @lengths_to_hist_ids.keys
  end

  def cache_length_histograms(word_length)
    length = word_length.length
    histograms = word_length.histograms.includes(:words)
    Rails.logger.debug "#{self.class.name}##{__method__} -> word_length: #{word_length}, length: #{length}, histograms: #{histograms}"
    @lengths_to_hist_ids[length] = histograms.pluck(:id)
  end

  def cache_hist_ids_to_words
    @lengths_to_hist_ids.each_pair do |length, histogram_ids|
      histogram_ids.each do |hist_from_id|
        @hist_ids_to_words[hist_from_id] = Word.where(histogram_id: hist_from_id).includes(:histogram)
      end
    end
  end

  ####
  def update_hist_friends_lengths
    # TODO: move this to previous 'builder'
    HistFriend.includes(:hist_from, :hist_to).all.each {|hf| hf.from_length = hf.hist_from.length; hf.to_length = hf.hist_to.length; hf.save}
  end

  def connect
    @lengths.each do |from_length|
      from_hist_ids = @lengths_to_hist_ids[from_length]
      to_length = from_length + 1
      from_hist_ids.each do |from_hist_id|
        from_words = hist_ids_to_words[from_hist_id]
        from_from(from_hist_ids, from_hist_id, from_words)
        from_to(from_hist_ids, from_words, to_length)
      end
    end
  end

  def from_from(from_hist_ids, from_hist_id, from_words)
    Rails.logger.debug "#{self.class.name}##{__method__} -> from_hist_ids: #{from_hist_ids}, from_hist_id: #{from_hist_id}, from_words: #{from_words}"
    (from_hist_ids - [from_hist_id]).each do |to_hist_id|
      to_words = hist_ids_to_words[to_hist_id]
      check_for_word_friends(from_words, to_words, 'from-from')
    end
  end

  def from_to(from_hist_ids, from_words, to_length)
    Rails.logger.debug "#{self.class.name}##{__method__} -> from_hist_ids: #{from_hist_ids}, from_words: #{from_words}, to_length: #{to_length}"
    to_words = []

    hist_to_friends = HistFriend.where(hist_from_id: from_hist_ids, to_length: to_length).includes(:hist_to)
    hist_to_friends.all.each do |htf|
      Rails.logger.debug "#{self.class.name}##{__method__} -> htf: #{htf}, htf.hist_to.words: #{htf.hist_to.words}"
      to_words_partial = htf.hist_to.words.includes(:histogram)
      to_words << to_words_partial # .pluck(:id,:name)
    end
    unless to_words.blank?
      to_words.flatten!.sort!.uniq!
      check_for_word_friends(from_words, to_words, 'from-to')
    end
  end

  def check_for_word_friends(from_words, to_words, comment)
    to_adds = []
    from_words.each do |from_word|
      @friends_word_from_ids_to_word_to_ids[from_word.id] ||= []
      to_words.each do |to_word|
        to_adds << {word_from_id: from_word.id, word_to_id: to_word.id} if Word.friends_in_db?(from_word, to_word)
        @friends_word_from_ids_to_word_to_ids[from_word.id] << to_word.id
      end
    end
    Rails.logger.debug "#{self.class.name}##{__method__} -> from_words: #{from_words}, to_words: #{to_words}, to_adds: #{to_adds}"
    add_friends(to_adds) # if writable
  end

  def add_friends(to_adds)
    WordFriend.bulk_insert do |worker|
      to_adds.each do |to_add|
        worker.add(to_add)
      end
    end
  end
end
