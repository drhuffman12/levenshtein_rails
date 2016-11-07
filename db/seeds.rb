require 'benchmark'
require 'ruby-prof'
require './lib/loader'

# max_words = 100000
# group_count = 10000

input_file = './doc/input'
preclean = true
# max_words_sizes = [10, 100, 1000, 10000, 100000]
# max_words_sizes = [10, 100, 1000, 10000]
# max_words_sizes = [10, 100, 1000]
# max_words_sizes = [10, 100]
# max_words_sizes = [250]
# max_words_sizes = [1000]
# max_words_sizes = [83]
max_words_sizes = [83*2]
# max_words_sizes = [830]
# max_words_sizes = [8300]
# max_words_sizes = [83000]
# max_words_sizes = []
# max_words_sizes = [50]
# max_words_sizes = [10]
# max_words_sizes = [16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768, 65536, 131072]
# max_words_sizes = [8, 16, 32, 64]
# max_words_sizes = [8, 16]
# max_words_sizes = [16, 32]
# max_words_sizes = [16]
# max_words_sizes = [32]
# max_words_sizes = [32]
# max_words_sizes = [8]
# step_sizes = [100, 10, 1]
# step_sizes = [4, 2, 1]
# step_sizes = [8, 4, 2, 1]
# step_sizes = [1]
# repeats = 3
# repeats = 2
only_test = true
profile = true
# only_test = false
i = 0

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
    # step_sizes.each do |step|
    #   repeats.times.each do |i|
    # group_count = 1
    results = nil
    x.report("max_words: #{max_words}, i: #{i}") { # , group_count: #{group_count}, step: #{step}
      RubyProf.start if profile
      Loader.new(input_file, max_words, preclean, only_test).run # , group_count, step
      results = RubyProf.stop if profile
    }
    if profile
      print_prof_rpt_graph(results, max_words)
      print_prof_rpt_call_tree(results, max_words)
    end
    # end
    # end
  end
end

def report(max_words_sizes)
  File.open("report.#{max_words_sizes.last}.txt", 'w') do |f|
    RawWord.all.each do |rw|
      line = rw.name + ',' + (rw.word && rw.word.soc_net_size ? rw.word.soc_net_size : 0).to_s + "\n"
      # puts line
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

