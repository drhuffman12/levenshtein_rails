require 'benchmark'
require 'ruby-prof'

input_file = './doc/input'
max_words_sizes = [83]
# max_words_sizes = [83*2]
# max_words_sizes = [830]
# max_words_sizes = [8300]
# max_words_sizes = [83000]
only_test = true
profile = true

class RubyProf::CallTreePrinter_TODO
  
=begin
  # AbstractPrinter:
  def print(output = STDOUT, options = {})
    @output = output
    setup_options(options)
    print_threads
  end
  
  # CallTreePrinter:
  def print(options = {})
    setup_options(options)
    determine_event_specification_and_value_scale
    print_threads
  end
=end
  def print(output = STDOUT, options = {})
    @output = output
    setup_options(options)
    determine_event_specification_and_value_scale
    print_threads
  end
end

def print_prof_rpt_graph(results, max_words)
  file_graph = File.open("log/profiler.max_words_#{max_words}.GraphPrinter.out_#{Time.now.strftime('%Y-%m-%d_%H-%M-%S')}",'w')
  # printer = RubyProf::GraphPrinter.new(result).print(STDOUT, {})
  printer = RubyProf::GraphPrinter.new(results).print(file_graph, {})          
end

def print_prof_rpt_call_tree(results, max_words)
  RubyProf::CallTreePrinter.new(results).print
  # file_call_tree = File.open("log/# profiler.max_words_#{max_words}.CallTreePrinter.out",'w')
  # RubyProf::CallTreePrinter.new(results).print(file_call_tree)
  # File.open "log/profiler.max_words_#{max_words}.CallTreePrinter.out_#{Time.now.strftime('%Y-%m-%d_%H-%M-%S')}", 'w' do |file|
  #   # RubyProf::CallTreePrinter.new(results).print(STDOUT, {})
  #   # RubyProf::CallTreePrinter.new(results).print(file, {})
  # end
end

Benchmark.bm do |x|
  max_words_sizes.each do |max_words|
    results = nil
    x.report("max_words: #{max_words}") {
      RubyProf.start if profile
      Loader.new(input_file, max_words, only_test).run
      results = RubyProf.stop if profile
    }
    if profile
      print_prof_rpt_graph(results, max_words)
      print_prof_rpt_call_tree(results, max_words)
    end
  end
end

def report(max_words_sizes)
  File.open("report.#{max_words_sizes.last}.txt", 'w') do |f|
    RawWord.all.each do |rw|
      line = rw.name + ',' + (rw.word.soc_net_size || 0).to_s + "\n"
      puts line
      f.write(line)
    end
  end
end

report(max_words_sizes)

def report_friends_per_word(max_words_sizes)
  wfis = WordFriend.group(:word_from_id).count(:word_to_id)
  data = wfis.values
  hist = Hash[*data.group_by{ |v| v }.flat_map{ |k, v| [k, v.size] }].sort_by{|k,v| k}
  File.open("report_friends_per_word.#{max_words_sizes.last}.txt", 'w') do |f|
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

report_friends_per_word(max_words_sizes)

=begin
Benchmark.bm do |x|
  x.report("all") { Word.all.pluck(:id) }
  x.report("select") { Word.select(:id).pluck(:id) }
end


Benchmark.bm(100) do |x|
  puts
  x.report("all") { Word.all.pluck(:id);puts;nil }
  x.report("select") { Word.select(:id).pluck(:id);puts;nil }
  puts
end;nil

=end

