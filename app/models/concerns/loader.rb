
class Loader
  def initialize(input_file, max_words, only_test = false)
    @input_file  = input_file
    @max_words   = max_words
    @only_test   = only_test

    @cache_known_friends = {}
    @cache_known_NOT_friends = {}
  end

  def run
    remove_records

    read_input_file
    find_hist_friends

    find_word_friends
    # WordFriendBuilder.new.run

    SocNetBuilder.new.run
  end

  def report # (max_words)
    File.open("report.#{@max_words}.txt", 'w') do |f|
      content = report_content
      # puts content
      f.write(content)
    end
  end

  def report_content
    content = []
    RawWord.all.each do |rw|
      content << rw.name + ',' + (rw.word.soc_net_size || 0).to_s # + "\n"
    end
    content.join("\n")
  end

  def report_friends_per_word #(max_words)
    wfis = WordFriend.group(:word_from_id).count(:word_to_id)
    data = wfis.values
    hist = Hash[*data.group_by{ |v| v }.flat_map{ |k, v| [k, v.size] }].sort_by{|k,v| k}
    File.open("report_friends_per_word.#{@max_words}.txt", 'w') do |f|
      line = {RawWord: RawWord.count, Word: Word.count, Histogram: Histogram.count, HistFriend: HistFriend.count, HistFriend_max: HistFriend.maximum(:hist_from_id), WordFriend: WordFriend.count, WordFriend_max_word_from_id: WordFriend.maximum(:word_from_id), SocialNode: SocialNode.count, SocialNode_max_word_orig_id: SocialNode.maximum(:word_orig_id)}.to_s + "\n\n"
      puts line
      f.write(line)
      line = "#friends : #occurs graph" + "\n"
      puts line
      f.write(line)
      hist.each do |h|
        line = ("%8s" % h[0]) + ' : ' + ("%7s" % h[1]) + ' ' + ('*' * h[1]) + "\n"
        puts line
        f.write(line)
      end
      line = "\ncount of distinct #friends: #{hist.count}" + "\n"
      puts line
      f.write(line)

      line = "\navg #friends/word: #{1.0 * WordFriend.count / WordFriend.select(:word_from_id).distinct.count}" + "\n"
      puts line
      f.write(line)
    end
    nil
  end

  private

  def remove_records
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.start
    DatabaseCleaner.clean

    counts = {
        WordLength: WordLength.count,
        RawWord: RawWord.count,
        Word: Word.count,
        Histogram: Histogram.count,
        WordFriend: WordFriend.count,
        HistFriend: HistFriend.count,
        SocialNode: SocialNode.count
    }

    msg = "\n#{self.class.name}##{__method__} -> .. Starting with record counts: #{counts.inspect}.\n"
    puts msg
    Rails.logger.info msg

    # WordLength.destroy_all
    # RawWord.destroy_all
    # Word.destroy_all
    # Histogram.destroy_all
    # WordFriend.destroy_all
    # HistFriend.destroy_all
    # SocialNode.destroy_all

    # ActiveRecord::Base.connection.tables.map{ |table_name|
    #   next if table_name.match(/\Aschema_migrations\Z/) || table_name.match(/\Aar_internal_metadata\Z/)
    #   table_name if Object.const_defined?(table_name.classify)
    # }.compact.each do |table_name|
    #   begin
    #     msg = "\n#{self.class.name}##{__method__} -> Processing Table #{table_name} ...\n"
    #     ActiveRecord::Migration.drop_table(table_name)
    #     ActiveRecord::Migration.create_table(table_name)
    #     msg = "\n#{self.class.name}##{__method__} -> .. Table #{table_name} cleaned.\n"
    #     puts msg
    #     Rails.logger.info msg
    #   rescue => e
    #     msg = "\n#{self.class.name}##{__method__} -> .. Table #{table_name} left alone due to error: #{e.message}.\n"
    #     puts msg
    #     Rails.logger.info msg
    #   end
    # end

    # ActiveRecord::Base.connection.tables.map(&:classify).map{ |name|
    #   tbl_defined = Object.const_defined?(name)
    #   name.constantize if tbl_defined
    #   # }.compact.each(&:delete_all)
    # }.compact.each do |table|
    #   begin
    #     # table.delete_all
    #     table.destroy_all
    #     msg = "\n#{self.class.name}##{__method__} -> Table #{table} cleaned.\n"
    #     puts msg
    #     Rails.logger.info msg
    #   rescue => e
    #     msg = "\n#{self.class.name}##{__method__} -> Table #{table} left alone due to error: #{e.message}.\n"
    #     puts msg
    #     Rails.logger.info msg
    #   end
    # end

  end

  ####

  def read_input_file
    # file = File.read(@input_file)
    # lines = file.lines
    lines = File.read(@input_file).lines
    len = lines.length
    max = @max_words < len ? @max_words : len

    @words = []
    @ids_per_word = {}
    @raw_words_per_word = {}
    @raw_words_to_add = []

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
          @raw_words_to_add << {name: raw_word, is_test_case: is_test_case, word_id: @ids_per_word[word]}
        end
      end
    end
    RawWord.bulk_insert do |worker|
      @raw_words_to_add.each do |raw_word|
        worker.add(raw_word)
      end
    end
  end

  def find_hist_friends
    # lens = WordLength.order(:length).pluck(:length)
    lens_and_hists = WordLength.order(:length).includes(:histograms)
    lens = []
    @hists_per_len = {}
    lens_and_hists.each do |lh|
      len = lh.length
      lens << len
      hists = lh.histograms.all
      @hists_per_len[len] = hists
    end
    hists_len_p1 = Histogram.where(length: lens.first).all
    lens.each do |len_cur|
      # len_m1 = len_cur - 1
      len_p1 = len_cur + 1
      # hists_len_cur = hists_len_p1
      # hists_len_cur = Histogram.where(length: len_cur).all
      # hists_len_p1 = Histogram.where(length: len_p1).all
      hists_len_cur = @hists_per_len[len_cur]
      hists_len_p1 = @hists_per_len[len_p1]
      unless hists_len_cur.blank?
        # hists_len_cur.each do |hist_from|
        #   (hists_len_cur - [hist_from]).each do |hist_to|
        #     are_friends = Histogram.friends_hist_type(eval(hist_from.hist), eval(hist_to.hist)) == 2
        #     connect_hist_friends(hist_from, hist_to) if are_friends
        #   end
        # end
        hist_from_from(hists_len_cur)
        unless hists_len_p1.blank?
          # hists_len_cur.each do |hist_from|
          #   hists_len_p1.each do |hist_to|
          #     are_friends = Histogram.friends_hist_type(eval(hist_from.hist), eval(hist_to.hist)) == 1
          #     connect_hist_friends(hist_from, hist_to) if are_friends
          #   end
          # end
          hist_from_to(hists_len_cur, hists_len_p1)
        end
      end
    end
  end

  def hist_from_from(hists_len_cur) # (from_hists, from_hist_i, from_words)
    hists_len_cur.each_with_index do |hist_from, hist_from_i|
      # (hists_len_cur - [hist_from]).each do |hist_to|
      (hist_from_i...hists_len_cur.length).each do |i|
        hist_to = hists_len_cur[i]
        are_friends = Histogram.friends_hist_type(eval(hist_from.hist), eval(hist_to.hist)) == 2
        connect_hist_friends(hist_from, hist_to) if are_friends
      end
    end
  end

  def hist_from_to(hists_len_cur, hists_len_p1) # (from_hist, from_words)
    hists_len_cur.each do |hist_from|
      hists_len_p1.each do |hist_to|
        are_friends = Histogram.friends_hist_type(eval(hist_from.hist), eval(hist_to.hist)) == 1
        connect_hist_friends(hist_from, hist_to) if are_friends
      end
    end
  end

  def connect_hist_friends(hist_from, hist_to)
    connected = HistFriend.where(hist_from_id: hist_from.id, hist_to_id: hist_to.id)
    unless connected.length > 0
      hf = HistFriend.create(hist_from_id: hist_from.id, hist_to_id: hist_to.id, from_length: hist_from.length, to_length: hist_to.length, comment: 'from-to')
      # hf.comment = 'from-to'
      # hf.save

      hf = HistFriend.create(hist_from_id: hist_to.id, hist_to_id: hist_from.id, from_length: hist_from.length, to_length: hist_to.length, comment: 'to-from')
      # hf.comment = 'to-from'
      # hf.save
    end
  end

  def find_word_friends
    word_lens = WordLength.includes(:histograms).includes(:words).order('word_lengths.length')
    word_lens.each do |word_length|
      from_hists = word_length.histograms
      from_hists.each_with_index do |from_hist, from_hist_i|
        from_words = from_hist.words
        # (from_hists - [from_hist]).each do |to_hist|
        #   to_words = to_hist.words
        #   check_for_word_friends(from_words, to_words, 'from-from')
        # end
        from_from(from_hists, from_hist_i, from_words)

        # hist_to_friends = HistFriend.where(hist_from_id: from_hist.id)
        # hist_to_friends.each do |hist_to_friend|
        #   to_hist = hist_to_friend.hist_to
        #   to_words = to_hist.words
        #   check_for_word_friends(from_words, to_words, 'from-to')
        # end
        from_to(from_hist, from_words)

      end
    end
  end

  def from_from(from_hists, from_hist_i, from_words)
    # Compare words of a histogram with words of other histograms of the same length
    # (i.e.: look for word friends where there is a 'replace' of a character)
    # def from_from_triangular(from_hists, from_hist, from_hist_i, from_words)
    # (from_hist_i+1...from_hists.length).each do |i|
    (from_hist_i...from_hists.length).each do |i|
      to_hist = from_hists[i]
      to_words = to_hist.words
      check_for_word_friends(from_words, to_words, 'from-from')
    end
  end

  def from_to(from_hist, from_words)
    # Compare words of a histogram with words of 'hist_friends' of that histogram
    # (i.e.: look for word friends where there is a 'add or remove' of a character)
    # hist_to_friends = HistFriend.where(hist_from_id: from_hist.id, to_length: [from_hist.length - 1, from_hist.length + 1])
    # hist_to_friends = HistFriend.where(hist_from_id: from_hist.id, to_length: [from_hist.length - 1, from_hist.length, from_hist.length + 1])
    # hist_to_friends = HistFriend.where(hist_from_id: from_hist.id, to_length: [from_hist.length + 1])
    hist_to_friends = HistFriend.where(hist_from_id: from_hist.id)
    hist_to_friends.each do |hist_to_friend|
      to_hist = hist_to_friend.hist_to
      to_words = to_hist.words
      check_for_word_friends(from_words, to_words, 'from-to')
    end
  end

  def check_for_word_friends(from_words, to_words, comment)
    to_adds = []
    from_words.each do |from_word|
      suspect_words = (to_words || []) - (@cache_known_friends[from_word.name] || []) - (@cache_known_NOT_friends[from_word.name] || [])
      suspect_words.each do |to_word|
        to_add = {word_from_id: from_word.id, word_to_id: to_word.id}
        to_add_rev = {word_from_id: to_word.id, word_to_id: from_word.id}
        # to_adds << to_add if Word.friends?(from_word.name, to_word.name) && !to_adds.include?(to_add)
        # to_adds << to_add if Word.friends_in_mem?(from_word.name, to_word.name) && !to_adds.include?(to_add)
        if Word.friends_in_mem?(from_word.name, to_word.name) && !(to_adds.include?(to_add) && to_adds.include?(to_add_rev))
          to_adds << to_add
          to_adds << to_add_rev
          @cache_known_friends[from_word.name] ||= []
          @cache_known_friends[from_word.name] << to_word.name
          @cache_known_friends[to_word.name] ||= []
          @cache_known_friends[to_word.name] << from_word.name
        else
          @cache_known_NOT_friends = {}
          @cache_known_NOT_friends[from_word.name] ||= []
          @cache_known_NOT_friends[from_word.name] << to_word.name
          @cache_known_NOT_friends[to_word.name] ||= []
          @cache_known_NOT_friends[to_word.name] << from_word.name
        end

      end
    end
    WordFriend.bulk_insert do |worker|
      to_adds.each do |to_add|
        worker.add(to_add)
      end
    end
  end
end
=begin

Time (and estimated) for up to ~80 words

(assuming a power curve)

time(hrs)

# words

=end






