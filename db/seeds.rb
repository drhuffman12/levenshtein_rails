require 'benchmark'
require 'ruby-prof'

input_file = './doc/input'
max_words = 83
# max_words = 83*2
# max_words = 830
# max_words = 8300
# max_words = 83000
# max_words_sizes = [83,830,8300,83000]
only_test = true
profile = true # for generating CacheGrind performance data

def print_prof_rpt_graph(results, max_words)
  file_graph = File.open("log/profiler.max_words_#{max_words}.GraphPrinter.out_#{Time.now.strftime('%Y-%m-%d_%H-%M-%S')}",'w')
  RubyProf::GraphPrinter.new(results).print(file_graph, {})
end

def print_prof_rpt_call_tree(results, max_words)
  RubyProf::CallTreePrinter.new(results).print
end

loader = Loader.new(input_file, max_words, only_test)
Benchmark.bm do |x|
  # max_words_sizes.each do |max_words|
      results = nil
      x.report("max_words: #{max_words}") {
        RubyProf.start if profile
        loader.run
        results = RubyProf.stop if profile
      }

      # generate CacheGrind performance data
      if profile
        print_prof_rpt_graph(results, max_words)
        print_prof_rpt_call_tree(results, max_words)
      end
  # end
end

loader.report
loader.report_friends_per_word
