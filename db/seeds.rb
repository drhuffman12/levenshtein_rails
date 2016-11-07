require 'benchmark'
require 'ruby-prof'

input_file = './doc/input'
max_words = 83
# max_words = 83*2
# max_words = 830
# max_words = 8300
# max_words = 83000
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

loader = Loader.new(input_file, max_words, only_test)
Benchmark.bm do |x|
  # max_words_sizes.each do |max_words|
  #   results = nil
  #   x.report("max_words: #{max_words}") {
  #     RubyProf.start if profile
  #     loader.run
  #     results = RubyProf.stop if profile
  #   }
  #   if profile
  #     print_prof_rpt_graph(results, max_words)
  #     print_prof_rpt_call_tree(results, max_words)
  #   end
  # end

  results = nil
  x.report("max_words: #{max_words}") {
    RubyProf.start if profile
    loader.run
    results = RubyProf.stop if profile
  }
  if profile
    print_prof_rpt_graph(results, max_words)
    print_prof_rpt_call_tree(results, max_words)
  end
end

loader.report # (max_words)
loader.report_friends_per_word # (max_words)

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

