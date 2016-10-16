require 'benchmark'

# max_words = 100000
# group_count = 10000

input_file = './doc/input'
preclean = true
# max_words_sizes = [10, 100, 1000, 10000, 100000]
# max_words_sizes = [10, 100, 1000, 10000]
# max_words_sizes = [10, 100, 1000]
# max_words_sizes = [10, 100]
# max_words_sizes = [16, 32, 64, 128]
max_words_sizes = [16, 32, 64]
# max_words_sizes = [16, 32]
# step_sizes = [100, 10, 1]
step_sizes = [4, 2, 1]
# step_sizes = [8, 4, 2, 1]
# repeats = 3
repeats = 1
Benchmark.bm do |x|
  max_words_sizes.each do |max_words|
    step_sizes.each do |step|
      repeats.times.each do |i|
        # group_count = 1
        x.report("max_words: #{max_words}, step: #{step}, i: #{i}") { # , group_count: #{group_count}
          Loader.new(input_file, max_words, step, preclean).run # , group_count
        }
      end
    end
  end
end
