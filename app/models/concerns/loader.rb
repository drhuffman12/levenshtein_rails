
class Loader
  def initialize(input_file, max_words, preclean = true, only_test = false) # , group_count, step
    @input_file  = input_file
    @max_words   = max_words
    @preclean    = preclean
    @only_test   = only_test
  end

  def run
    remove_records if @preclean
    read_input_file
    find_hist_friends

    find_word_friends
    # WordFriendBuilder.new.run

    # find_word_social_net
    SocNetBuilder.new.run
  end

  def remove_records
    ActiveRecord::Base.connection.tables.map(&:classify).map{ |name|
      tbl_defined = Object.const_defined?(name)
      name.constantize if tbl_defined
    }.compact.each(&:delete_all)
  end

  ####

  def read_input_file
    i = 0

    file = File.read(@input_file)
    lines = file.lines
    len = lines.length
    max = @max_words < len ? @max_words : len

    @words = []
    @ids_per_word = {}
    @raw_words_per_word = {}
    @raw_words = []

    found_END_OF_INPUT = false
    (0...max).each do |i|
      if !lines.blank? && lines[i]
        name = lines[i].chomp
        at_END_OF_INPUT = (name == 'END OF INPUT')
        found_END_OF_INPUT ||= at_END_OF_INPUT
        is_test_case = !found_END_OF_INPUT
        unless at_END_OF_INPUT
          raw_word = lines[i].chomp
          word = Word.to_usable(raw_word)
          unless @ids_per_word.keys.include?(word)
            @ids_per_word[word] = Word.create(name: word).id
          end
          @raw_words << {name: raw_word, is_test_case: is_test_case, word_id: @ids_per_word[word]}
        end
      end
    end
    bulk_add_raw_words
  end

  def bulk_add_raw_words
    RawWord.bulk_insert do |worker|
      @raw_words.each do |raw_word|
        worker.add(raw_word)
      end
    end
  end

  def read_input_file_newer # (input_file, max_words, group_count)
    i = 0

    file = File.read(@input_file)
    lines = file.lines
    len = lines.length
    max = @max_words < len ? @max_words : len

    @words = []
    @words_to_add = []
    @ids_per_word = {}
    @raw_words_per_word = {}
    @raw_words = []

    found_END_OF_INPUT = false
    (0...max).each do |i|
      if !lines.blank? && lines[i]
        name = lines[i].chomp
        at_END_OF_INPUT = (name == 'END OF INPUT')
        found_END_OF_INPUT ||= at_END_OF_INPUT
        is_test_case = !found_END_OF_INPUT
        unless at_END_OF_INPUT
          raw_word = lines[i].chomp
          word = Word.to_usable(raw_word)
          unless @words.include?(word)
            @words << word
            @words_to_add << {name: word, is_test_case: is_test_case}
          end
          @raw_words << {name: raw_word, is_test_case: is_test_case, word: word} #, word_id: @ids_per_word[word]}
        end
      end
    end
    bulk_add_words
    bulk_add_raw_words_v2
  end

  def bulk_add_words
    Word.bulk_insert do |worker|
      @words_to_add.each do |word|
        worker.add(word)
      end
    end
    Word.select(:name, :id).order(:name, :id).pluck(:name, :id).collect{|name_and_id| @ids_per_word[name_and_id[0]] = name_and_id[1]}
    Rails.logger.info "#{self.class.name}##{__method__} -> @words_to_add: #{@words_to_add}"
    Rails.logger.info "#{self.class.name}##{__method__} -> @ids_per_word: #{@ids_per_word}"
  end

  def bulk_add_raw_words_v2
    RawWord.bulk_insert do |worker|
      @raw_words.each do |raw_word|
        # params = raw_word.merge(word_id: @ids_per_word[raw_word[:name]])
        params = {name: raw_word[:name], is_test_case: raw_word[:is_test_case], word_id: @ids_per_word[raw_word[:word]]}
        Rails.logger.info "#{self.class.name}##{__method__} -> raw_word: #{raw_word}, params: #{params}"
        worker.add(params)
      end
    end
  end

  ####

  def connect_hist_friends(hist_from, hist_to)
    connected = HistFriend.where(hist_from_id: hist_from.id, hist_to_id: hist_to.id)
    unless connected.length > 0
      hf = HistFriend.create(hist_from_id: hist_from.id, hist_to_id: hist_to.id)
      hf.comment = 'from-to'
      hf.save

      hf = HistFriend.create(hist_from_id: hist_to.id, hist_to_id: hist_from.id)
      hf.comment = 'to-from'
      hf.save
    end
  end

  def find_hist_friends
    # puts "\n\n#{self.class.name}##{__method__}"
    lens = WordLength.order(:length).pluck(:length)
    # hists_len_m1 = []
    hists_len_cur = []
    hists_len_p1 = Histogram.where(length: lens.first).all
    lens.each do |len_cur|
      # len_m1 = len_cur - 1
      len_p1 = len_cur + 1

      # hists_len_m1 = hists_len_cur
      hists_len_cur = hists_len_p1
      hists_len_p1 = Histogram.where(length: len_p1).all

      unless hists_len_cur.empty?
        hists_len_cur.each do |hist_from|
          (hists_len_cur - [hist_from]).each do |hist_to|
            are_friends = Histogram.friends_hist_type(eval(hist_from.hist), eval(hist_to.hist)) == 2
            connect_hist_friends(hist_from, hist_to) if are_friends
          end
        end
        unless hists_len_p1.empty?
          hists_len_cur.each do |hist_from|
            hists_len_p1.each do |hist_to|
              are_friends = Histogram.friends_hist_type(eval(hist_from.hist), eval(hist_to.hist)) == 1
              connect_hist_friends(hist_from, hist_to) if are_friends
            end
          end
        end
      end

    end
  end

  def find_word_friends
    word_lens = WordLength.includes(:histograms).includes(:words).order('word_lengths.length')
    word_lens.each do |word_length| # .includes(:histograms)
      from_hists = word_length.histograms
      from_hists.each do |from_hist|
        from_words = from_hist.words
        (from_hists - [from_hist]).each do |to_hist|
          to_words = to_hist.words
          check_for_word_friends(from_words, to_words, 'from-from')
        end
        hist_to_friends = HistFriend.where(hist_from_id: from_hist.id)
        hist_to_friends.each do |hist_to_friend|
          to_hist = hist_to_friend.hist_to
          to_words = to_hist.words
          check_for_word_friends(from_words, to_words, 'from-to')
        end
      end
    end
  end

  def check_for_word_friends(from_words, to_words, comment)
    to_adds = []
    from_words.each do |from_word|
      to_words.each do |to_word|
        to_add = {word_from_id: from_word.id, word_to_id: to_word.id}
        to_adds << to_add if Word.friends?(from_word.name, to_word.name) && !to_adds.include?(to_add)
      end
    end
    WordFriend.bulk_insert do |worker|
      to_adds.each do |to_add|
        worker.add(to_add)
      end
    end
  end

  ################################

  def find_word_friends_scratch
    from_hists = Histogram.order(:length, :hist).all
    from_hists_len = from_hists.length
    from_hists.each_with_index do |from_hist, i|
      find_word_friends_len_same(from_hists, from_hist, i, from_hists_len)
      find_word_friends_len_plus_1(from_hist, i, from_hists_len)
    end
  end

  def find_word_friends_v2
    word_lengths = WordLength.order(:length).all
    hists_and_words_per_length = {}
    word_lengths.each do |word_length|
      len = word_length.length
      hists_and_words_per_length[len] = Histogram.where(:length => len).includes(:words).to_a # , :hist_to_friends
    end
    (1...word_lengths.length).each do |len|
      cur_hists_and_words = hists_and_words_per_length[len]
      next_hists_and_words = hists_and_words_per_length[len+1]
      find_word_friends_len_same(cur_hists_and_words) if cur_hists_and_words && !(cur_hists_and_words.empty?)
      find_word_friends_len_plus_1(cur_hists_and_words, next_hists_and_words) if cur_hists_and_words && next_hists_and_words && !(cur_hists_and_words.empty? || next_hists_and_words.empty?)
    end
  end

  def find_word_friends_len_same(cur_hists_and_words)
    qty = cur_hists_and_words.length
    cur_hists_and_words.each_with_index do |hist_and_words, i|
      (i+1...qty).each do |j|
        vs_hist_and_words = cur_hists_and_words[j]
        check_for_word_friends_in_bulk(hist_and_words.words, vs_hist_and_words.words, "#{self.class.name}##{__method__} -> i: #{i}, j: #{j}")
      end
    end
  end

  def find_word_friends_len_plus_1(cur_hists_and_words, next_hists_and_words)
    cur_hists_and_words.each_with_index do |cur_hist_and_words, i|
      next_hists_and_words.each_with_index do |next_hist_and_words, j|
        check_for_word_friends_in_bulk(cur_hist_and_words.words, next_hist_and_words.words, "#{self.class.name}##{__method__} -> i: #{i}, j: #{j}")
      end
    end
  end

  def check_for_word_friends_in_bulk(from_words, to_words, comment)
    from_words_to_words = []
    from_words.each do |from_word|
      to_words.each do |to_word|
        if Word.friends?(from_word.name, to_word.name)
          from_words_to_words << {word_from_id: from_word.id, word_to_id: to_word.id}
          from_words_to_words << {word_from_id: to_word.id, word_to_id: from_word.id}
        end
      end
    end
    connect_word_friends_in_bulk(from_words_to_words) unless from_words_to_words.empty?
  end

  def connect_word_friends_in_bulk(from_words_to_words)
    WordFriend.bulk_insert do |worker|
      from_words_to_words.each do |attrs|
        worker.add(attrs)
      end
    end
  end

  ################################
  def find_word_social_net_orig
    WordLength.select(:id).order(:length).includes(:words).each do |word_length|
      orig_words = word_length.words
      orig_words.each do |orig_word|
        to_word_friends = WordFriend.where(word_from_id: orig_word.id).order(:to_length, :word_to_id).all
        orig_word.traversed_ids = walk_friendship_nodes(orig_word, orig_word, to_word_friends, 1, [orig_word.id])
        orig_word.soc_net_size = orig_word.traversed_ids.length - 1
        orig_word.save
      end
    end
  end

  def find_word_social_net
    @word_ids_to_friend_ids = {}
    WordFriend.select(:word_from_id, :word_to_id).order(:word_from_id, :word_to_id).all.each do |wf|
      word_from_id = wf.word_from_id
      word_to_id = wf.word_to_id
      @word_ids_to_friend_ids[word_from_id] ||= []
      @word_ids_to_friend_ids[word_from_id] << word_to_id
    end
  end

  def walk_friendship_nodes_orig(orig_word, from_word, to_word_friends, qty_steps, traversed_ids)
    to_word_friends.each do |to_word_friend|
      to_word = to_word_friend.word_to
      already_connected = connect_friends(orig_word, from_word, to_word, qty_steps)
      unless already_connected
        next_to_word_friends = WordFriend.where(word_from_id: to_word.id).where.not(word_to_id: from_word.id).order(:to_length, :word_to_id).all
        walk_friendship_nodes(orig_word, to_word, next_to_word_friends, qty_steps + 1, traversed_ids << to_word.id)
      end
    end
    traversed_ids
  end

  def walk_friendship_nodes(orig_word, from_word, to_word_friends, qty_steps, traversed_ids)
    SocialNode.where(word_orig_id: orig_word.id, word_from_id: from_word.id, word_to_id: to_word_friends, qty_steps: qty_steps)
    to_word_friends.each do |to_word_friend|
      to_word = to_word_friend.word_to
      already_connected = connect_friends(orig_word, from_word, to_word, qty_steps)
      unless already_connected
        next_to_word_friends = WordFriend.where(word_from_id: to_word.id).where.not(word_to_id: from_word.id).order(:to_length, :word_to_id).all
        walk_friendship_nodes(orig_word, to_word, next_to_word_friends, qty_steps + 1, traversed_ids << to_word.id)
      end
    end
    traversed_ids
  end

  def connect_friends(orig_word, from_word, to_word, qty_steps)
    already_connected = SocialNode.where(word_orig_id: orig_word.id, word_from_id: from_word.id, word_to_id: to_word.id).first
    unless already_connected
      SocialNode.create(word_orig_id: orig_word.id, word_from_id: from_word.id, word_to_id: to_word.id, qty_steps: qty_steps)
      SocialNode.create(word_orig_id: orig_word.id, word_from_id: to_word.id, word_to_id: from_word.id, qty_steps: qty_steps)
    end
    already_connected
  end
end
