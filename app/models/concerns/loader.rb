
class Loader
  def initialize(input_file, max_words, only_test = false)
    @input_file  = input_file
    @max_words   = max_words
    @only_test   = only_test
  end

  def run
    read_input_file
    find_hist_friends

    find_word_friends
    # WordFriendBuilder.new.run

    SocNetBuilder.new.run
  end

  def report # (max_words)
    File.open("report.#{@max_words}.txt", 'w') do |f|
      content = report_content
      puts content
      f.write(content)
      # RawWord.all.each do |rw|
      # line = rw.name + ',' + (rw.word.soc_net_size || 0).to_s + "\n"
      # puts line
      # f.write(line)
      # end
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

  # def remove_records
  #   ActiveRecord::Base.connection.tables.map(&:classify).map{ |name|
  #     tbl_defined = Object.const_defined?(name)
  #     name.constantize if tbl_defined
  #   }.compact.each(&:delete_all)
  # end

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
    lens = WordLength.order(:length).pluck(:length)
    hists_len_p1 = Histogram.where(length: lens.first).all
    lens.each do |len_cur|
      # len_m1 = len_cur - 1
      len_p1 = len_cur + 1
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

  def find_word_friends
    word_lens = WordLength.includes(:histograms).includes(:words).order('word_lengths.length')
    word_lens.each do |word_length|
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
end
