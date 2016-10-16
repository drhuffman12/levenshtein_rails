require 'benchmark'

# max_words = 100000
# group_count = 10000

input_file = './doc/input'
preclean = true
max_words_sizes = [10, 100, 1000, 10000, 100000]
# max_words_sizes = [10, 100, 1000, 10000]
# max_words_sizes = [10, 100, 1000]
# max_words_sizes = [10, 100]
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
# only_test = false
i = 0
Benchmark.bm do |x|
  max_words_sizes.each do |max_words|
    # step_sizes.each do |step|
    #   repeats.times.each do |i|
        # group_count = 1
        x.report("max_words: #{max_words}, i: #{i}") { # , group_count: #{group_count}, step: #{step}
          Loader.new(input_file, max_words, preclean, only_test).run # , group_count, step
        }
      # end
    # end
  end
end
