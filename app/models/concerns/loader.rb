
class Loader
  def initialize(input_file, max_words, step, preclean = true) # , group_count
    # puts "\n#{self.class.name}##{__method__} -> input_file: #{input_file}, max_words: #{max_words}, preclean: #{preclean}" # , group_count: #{group_count}
    @input_file  = input_file
    @max_words   = max_words
    # @group_count = group_count
    @step = step
    @preclean    = preclean
  end

  def run
    # teardown if @preclean
    # reset if @preclean
    remove_records if @preclean
    read_input_file
    find_hist_friends
    find_word_friends
  end

  # def teardown
  #   puts "\n#{self.class.name}##{__method__}"
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

    (0...max).step(@step).each do |i|
      Word.create(name: lines[i].chomp)
    end

    # File.read(@input_file).each_line do |name|
    #   i += 1
    #
    #   # TODO: add field for orig_name OR usable_name to Word
    #   unless (@max_words && i > @max_words)
    #     # if i % @group_count == 0
    #     #   puts
    #     #   puts [i, Time.now].inspect
    #     #   puts
    #     # end
    #     Word.create(name: name)
    #   end
    #   # Word.create(name: Word.to_usable(name)) # if i < 20
    # end
  end

  def connect_hist_friends(hist_from, hist_to)
    hf = HistFriend.new
    hf.hist_from = hist_from
    hf.hist_to = hist_to
    hf.comment = 'from-to'
    hf.save
    # HistFriend.find_or_create_by(hist_from_id: hist_from.id, hist_to_id: hist_to.id)

    hf = HistFriend.new
    hf.hist_from = hist_to
    hf.hist_to = hist_from
    hf.comment = 'to-from'
    hf.save
    # HistFriend.find_or_create_by(hist_from_id: hist_to.id, hist_to_id: hist_from.id)
  end

  def find_hist_friends
    # puts "\n#{self.class.name}##{__method__}"
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
    WordLength.order(:length).each do |word_length|
      from_length = word_length.length
      to_length = from_length + 1
      from_hists = word_length.histograms
      from_hists.each do |from_hist|
        from_words = from_hist.words
        # (from_hists - from_hist).each do |to_hist|
        from_hists.each do |to_hist|
          to_words = to_hist.words
          check_for_word_friends(from_words, to_words, 'from-from')
        end

        # hist_to_friends = HistFriend.where(hist_from_id: from_hist.id, to_length: to_length).all
        hist_to_friends = HistFriend.where(hist_from_id: from_hist.id).all
        hist_to_friends.each do |hist_to_friend|
          to_hist = hist_to_friend.hist_to
          to_words = to_hist.words
          check_for_word_friends(from_words, to_words, 'from-to')
        end

        # hist_to_friends = HistFriend.where(hist_from_id: from_hist.id).all
        # hist_to_friends.each do |hist_to_friend|
        #   to_hist = hist_to_friend.hist_to
        #   to_words = to_hist.words
        #   check_for_word_friends(from_words, to_words)
        # end

        # # if from_hist.respond_to?(:hist_to_friends) # FIX: NameError: uninitialized constant Histogram::HistToFriend
        # if defined?(from_hist.hist_to_friends)
        #   from_hist.hist_to_friends.each do |to_hist|
        #     to_words = to_hist.words
        #     check_for_word_friends(from_words, to_words)
        #   end
        # else
        #   puts "find_word_friends .. from_hist.inspect: #{from_hist.inspect}"
        # end
      end
    end
  end

  def check_for_word_friends(from_words, to_words, comment)
    from_words.each do |from_word|
      to_words.each do |to_word|
        are_friends = Word.friends?(from_word.name, to_word.name)
        connect_word_friends(from_word, to_word, comment) if are_friends
      end
    end
  end

  def connect_word_friends(from_word, to_word, comment)
    # wf = WordFriend.new
    wf = WordFriend.find_or_create_by(word_from_id: from_word.id, word_to_id: to_word.id)
    # wf.word_from = from_word
    # wf.word_to = to_word
    wf.comment = comment
    wf.save
    # WordFriend.find_or_create_by(word_from_id: from_word.id, word_to_id: to_word.id)

    # wf = WordFriend.new
    # wf.word_from = to_word
    # wf.word_to = from_word
    # wf.save
    # # WordFriend.find_or_create_by(word_from_id: to_word.id, word_to_id: from_word.id)
  end

end