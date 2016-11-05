
class Loader
  def initialize(input_file, max_words, preclean = true, only_test = false) # , group_count, step
    # puts "\n\n#{self.class.name}##{__method__} -> input_file: #{input_file}, max_words: #{max_words}, preclean: #{preclean}" # , group_count: #{group_count}
    @input_file  = input_file
    @max_words   = max_words
    # @group_count = group_count
    # @step = step
    @preclean    = preclean
    @only_test   = only_test
  end

  def run
    # teardown if @preclean
    # reset if @preclean
    remove_records if @preclean
    read_input_file
    find_hist_friends
    find_word_friends
    # find_word_social_net
    SocNetBuilder.new.run
  end

  # def teardown
  #   puts "\n\n#{self.class.name}##{__method__}"
  #   Rake::Task['db:reset'].invoke
  #   # Rake::Task['db:drop'].invoke
  #   # Rake::Task['db:migrate'].invoke
  # end
  #
  # def reset
  #   Rails.application.eager_load!
  #   ActiveRecord::Base.descendants.each { |c| c.delete_all unless c == ActiveRecord::SchemaMigration  }
  # end

  def remove_records
    ActiveRecord::Base.connection.tables.map(&:classify).map{ |name|
      tbl_defined = Object.const_defined?(name)
      name.constantize if tbl_defined
    }.compact.each(&:delete_all)
  end

  def read_input_file # (input_file, max_words, group_count)
    i = 0

    # puts
    # puts [i, Time.now].inspect
    # puts

    file = File.read(@input_file)
    lines = file.lines
    len = lines.length
    max = @max_words < len ? @max_words : len

    # puts

    found_END_OF_INPUT = false
    (0...max).each do |i|
      name = lines[i].chomp
      at_END_OF_INPUT = (name == 'END OF INPUT')
      found_END_OF_INPUT ||= at_END_OF_INPUT
      is_test_case = !found_END_OF_INPUT
      # Word.create(name: lines[i].chomp, is_test_case: is_test_case) unless at_END_OF_INPUT
      unless at_END_OF_INPUT
        # word = Word.find_or_create_by(name: lines[i].chomp, is_test_case: is_test_case)
        word = Word.find_or_create_by(name: lines[i].chomp)
        word.is_test_case = is_test_case || word.is_test_case
        word.save
        RawWord.create(name: lines[i].chomp, is_test_case: is_test_case, word_id: word.id)
      end
      # puts "i: #{i}, name: '#{name}', @only_test: '#{@only_test}', at_END_OF_INPUT: #{at_END_OF_INPUT}, found_END_OF_INPUT: #{found_END_OF_INPUT}"
    end
  end

  def connect_hist_friends(hist_from, hist_to)
    connected = HistFriend.where(hist_from_id: hist_from.id, hist_to_id: hist_to.id)
    unless connected.length > 0
      # hf = HistFriend.new
      # hf.hist_from = hist_from
      # hf.hist_to = hist_to
      # hf.comment = 'from-to'
      # hf.save
      # hf = HistFriend.find_or_create_by(hist_from_id: hist_from.id, hist_to_id: hist_to.id)
      hf = HistFriend.create(hist_from_id: hist_from.id, hist_to_id: hist_to.id)
      hf.comment = 'from-to'
      hf.save

      # hf = HistFriend.new
      # hf.hist_from = hist_to
      # hf.hist_to = hist_from
      # hf.comment = 'to-from'
      # hf.save
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

  ################################

  def find_word_friends
    # find_word_friends_v1
    find_word_friends_v1b
    # find_word_friends_v2
  end

  ################################

  def find_word_friends_v1
    WordLength.order(:length).each do |word_length|
      from_length = word_length.length
      to_length = from_length + 1
      from_hists = word_length.histograms
      from_hists.each do |from_hist|
        from_words = from_hist.words
        from_hists.each do |to_hist|
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

  def find_word_friends_v1b
    word_lengths = WordLength.includes(:histograms).includes(:words).order('word_lengths.length')
    word_lengths.each do |word_length| # .includes(:histograms)
      from_length = word_length.length
      # to_length = from_length + 1
      from_hists = word_length.histograms
      from_hists.each do |from_hist|
        from_words = from_hist.words
        from_from(from_hists, from_hist, from_words)
        from_to(from_hist, from_words)
      end
    end
  end

  def from_from(from_hists, from_hist, from_words)
    (from_hists - [from_hist]).each do |to_hist|
      to_words = to_hist.words
      check_for_word_friends(from_words, to_words, 'from-from')
    end
  end

  def from_to(from_hist, from_words)
    hist_to_friends = HistFriend.where(hist_from_id: from_hist.id)
    hist_to_friends.each do |hist_to_friend|
      to_hist = hist_to_friend.hist_to
      to_words = to_hist.words
      check_for_word_friends(from_words, to_words, 'from-to')
    end
  end

  def check_for_word_friends(from_words, to_words, comment)
    from_words.each do |from_word|
      to_words.each do |to_word|
        WordFriend.find_or_create_by(word_from_id: from_word.id, word_to_id: to_word.id) if Word.friends?(from_word.name, to_word.name)
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

    # puts "\n#{self.class.name}##{__method__} ->"
    # puts ".. word_lengths: #{word_lengths}" if word_lengths
    # puts ".. hists_and_words_per_length: #{hists_and_words_per_length}" if hists_and_words_per_length

    (1...word_lengths.length).each do |len|
      cur_hists_and_words = hists_and_words_per_length[len]
      next_hists_and_words = hists_and_words_per_length[len+1]

      # puts "\n#{self.class.name}##{__method__} -> len: #{len}"
      # puts ".. cur_hists_and_words.length: #{cur_hists_and_words.length}" if cur_hists_and_words
      # puts ".. next_hists_and_words.length: #{next_hists_and_words.length}" if next_hists_and_words

      find_word_friends_len_same(cur_hists_and_words) if cur_hists_and_words && !(cur_hists_and_words.empty?)
      find_word_friends_len_plus_1(cur_hists_and_words, next_hists_and_words) if cur_hists_and_words && next_hists_and_words && !(cur_hists_and_words.empty? || next_hists_and_words.empty?)
    end
  end

  def find_word_friends_len_same(cur_hists_and_words)
    qty = cur_hists_and_words.length
    cur_hists_and_words.each_with_index do |hist_and_words, i|
      (i+1...qty).each do |j|
        vs_hist_and_words = cur_hists_and_words[j]

        # puts "\n#{self.class.name}##{__method__} -> i: #{i}, j: #{j}"
        # puts ".. hist_and_words: #{hist_and_words}"
        # puts "  .. hist_and_words.hist: #{hist_and_words.hist}"
        # puts "  .. hist_and_words.words: #{hist_and_words.words.to_a}"
        # puts ".. vs_hist_and_words: #{vs_hist_and_words}"
        # puts "  .. vs_hist_and_words.hist: #{vs_hist_and_words.hist}"
        # puts "  .. vs_hist_and_words.words: #{vs_hist_and_words.words.to_a}"

        check_for_word_friends_in_bulk(hist_and_words.words, vs_hist_and_words.words, "#{self.class.name}##{__method__} -> i: #{i}, j: #{j}")
      end
    end
  end

  def find_word_friends_len_plus_1(cur_hists_and_words, next_hists_and_words)
    # qty = cur_hists_and_words.length
    cur_hists_and_words.each_with_index do |cur_hist_and_words, i|
      next_hists_and_words.each_with_index do |next_hist_and_words, j|
        # vs_hist_and_words = cur_hists_and_words[j]

        # puts "\n#{self.class.name}##{__method__} -> i: #{i}, j: #{j}"
        # puts ".. cur_hist_and_words.length: #{cur_hist_and_words.length}"
        # puts "  .. cur_hist_and_words.hist: #{cur_hist_and_words.hist}"
        # puts "  .. cur_hist_and_words.words: #{cur_hist_and_words.words.to_a}"
        # puts ".. next_hist_and_words.length: #{next_hist_and_words.length}"
        # puts "  .. next_hist_and_words.hist: #{next_hist_and_words.hist}"
        # puts "  .. next_hist_and_words.words: #{next_hist_and_words.words.to_a}"

        check_for_word_friends_in_bulk(cur_hist_and_words.words, next_hist_and_words.words, "#{self.class.name}##{__method__} -> i: #{i}, j: #{j}")
      end
    end
  end

  def check_for_word_friends_in_bulk(from_words, to_words, comment)
    from_words_to_words = []
    from_words.each do |from_word|
      to_words.each do |to_word|
        # are_friends = Word.friends?(from_word.name, to_word.name)
        # connect_word_friends(from_word, to_word, comment) if are_friends
        if Word.friends?(from_word.name, to_word.name)
          from_words_to_words << {word_from_id: from_word.id, word_to_id: to_word.id}
          from_words_to_words << {word_from_id: to_word.id, word_to_id: from_word.id}
        end
      end
    end

    # puts "\n#{self.class.name}##{__method__} -> comment: #{comment}"
    # puts ".. from_words_to_words: #{from_words_to_words}"

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
    # WordLength.select(:id).includes(:words).order(:length).each do |word_length|
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
      # puts wf
      word_from_id = wf.word_from_id
      word_to_id = wf.word_to_id
      @word_ids_to_friend_ids[word_from_id] ||= []
      @word_ids_to_friend_ids[word_from_id] << word_to_id
    end
    # @word_ids_to_friend_ids


    # Word.limit(5).includes(:word_to_friends).all.each do |word|
    #   # @word_ids_and_friend_ids[word.id] = word.word_to_friends.
    #   # puts "#{word.id} : #{word.word_to_friends}"
    #   puts "#{word.id} : #{word.word_to_friends.pluck(:word_from_id)}"
    # end

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