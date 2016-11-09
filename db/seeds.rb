require 'benchmark'
require 'ruby-prof'

input_file = './doc/input'
only_test = true
profile = true # for generating CacheGrind performance data

# max_words = 83
# max_words = 83*2
# max_words = 830
# max_words = 8300
# max_words = 83000
# max_words_sizes = [83,830,8300,83000]
# max_words_sizes = [10,21,42,83,83*2]
# max_words_sizes = [83*4]
# max_words_sizes = [10,21,42,83,83*2,83*4,83*8,83*16]
# max_words_sizes = [83*32,83*64,83*128,83*256]
max_words_sizes = [10,21,42,83,83*2,83*4,83*8,83*16,83*32,83*64,83*128,83*256]
# max_words = 83*512
# max_words = 83*1024
# max_words_sizes = [83*32,83*64,83*128,83*256,83*512,83*1024]
# max_words_sizes = [83*8,83*16]
# max_words_sizes = [83,83*4,83*16,83*64]

def print_prof_rpt_graph(results, max_words)
  file_graph = File.open("log/profiler.max_words_#{max_words}.GraphPrinter.out_#{Time.now.strftime('%Y-%m-%d_%H-%M-%S')}",'w')
  RubyProf::GraphPrinter.new(results).print(file_graph, {})
end

def print_prof_rpt_call_tree(results, max_words)
  RubyProf::CallTreePrinter.new(results).print
end

Benchmark.bm do |x|
  (max_words_sizes || [max_words]).each do |mw|
    results = nil
    x.report("max_words: #{mw}") {
      RubyProf.start if profile

      msg = "\n" + ("v"*80) + "\n"
      puts msg
      Rails.logger.info msg

      loader = Loader.new(input_file, mw, only_test)
      loader.run
      loader.report
      loader.report_friends_per_word

      msg = "\n" + ("-"*80) + "\n"
      puts msg
      Rails.logger.info msg


      results = RubyProf.stop if profile
    }

    # generate CacheGrind performance data
    if profile
      print_prof_rpt_graph(results, mw)
      print_prof_rpt_call_tree(results, mw)
    end
  end
end
