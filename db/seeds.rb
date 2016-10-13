require 'benchmark'

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# def interesting_tables
#   ActiveRecord::Base.connection.tables.sort.reject do |tbl|
#     ['schema_migrations', 'sessions', 'public_exceptions'].include?(tbl)
#   end
# end
#
# interesting_tables.each do |tbl_name|
#   tbl_name. .delete_all
# end

def teardown
  puts "\n#{self.class.name}##{__method__}"
  Rake::Task['db:reset'].invoke
  # Rake::Task['db:drop'].invoke
  # Rake::Task['db:migrate'].invoke
end

# TODO: refactor to do sql commits in batches.
# See:
#   * http://api.rubyonrails.org/classes/ActiveRecord/Batches.html
#   * http://weblog.jamisbuck.org/2015/10/10/bulk-inserts-in-activerecord.html

## v1:
def read_given_input_file(max_words, group_count)
  puts "\n#{self.class.name}##{__method__} -> max_words: #{max_words}, group_count: #{group_count}"
  i = 0
  # max_words = ENV['max_words'] ? ENV['max_words'].to_i || 20 : nil

  # # max_words = 100000
  # # group_count = 1000
  # max_words = 16
  # group_count = 4

  # puts
  # puts [i, Time.now].inspect
  # puts
  File.read('./doc/input').each_line do |name|
    i += 1

    # TODO: add field for orig_name OR usable_name to Word
    unless (max_words && i > max_words)
      if i % group_count == 0
        puts
        puts [i, Time.now].inspect
        puts
      end
      Word.create(name: name)
    end
    # Word.create(name: Word.to_usable(name)) # if i < 20
  end
end

# def connect_hist_friends(hist_from_id, hist_to_id)
#   hf = HistFriend.new
#   hf.hist_from_id = hist_from_id
#   hf.hist_to_id = hist_to_id
#   hf.save
#
#   hf = HistFriend.new
#   hf.hist_from_id = hist_to_id
#   hf.hist_to_id = hist_from_id
#   hf.save
# end

def connect_hist_friends(hist_from, hist_to)
  hf = HistFriend.new
  hf.hist_from = hist_from
  hf.hist_to = hist_to
  hf.save

  hf = HistFriend.new
  hf.hist_from = hist_to
  hf.hist_to = hist_from
  hf.save
end

def find_hist_friends
  puts "\n#{self.class.name}##{__method__}"
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

## v2:
def read_given_input_file_v2(max_words, group_count)
  puts "\n#{self.class.name}##{__method__} -> max_words: #{max_words}, group_count: #{group_count}"
  i = 0
  # max_words = ENV['max_words'] ? ENV['max_words'].to_i || 20 : nil

  # max_words = 100000
  # group_count = 1000
  # # max_words = 16
  # # group_count = 4

  # puts
  # puts [i, Time.now].inspect
  # puts
  rec_attrs = []
  File.read('./doc/input').each_line do |name|
    i += 1

    # TODO: add field for orig_name OR usable_name to Word
    unless (max_words && i > max_words)
      if i % group_count == 0
        puts
        puts [i, Time.now].inspect
        puts
      end
      # Word.create(name: name)
      rec_attrs << {name: name}
    end
  end
  Word.bulk_insert(set_size: group_count) do |worker|
    rec_attrs.each do |attrs|
      worker.add(attrs)
    end
  end

  # force AR before_save call-backs
  # Word.in_batches.each_record(&:touch)
  Word.find_in_batches(batch_size: group_count).with_index do |word, batch|
    puts "\nProcessing batch ##{batch}: word.each(&:reset_length)"
    word.each(&:reset_length)
    # word.each(&:touch)
    word.each(&:save)
  end

end

def connect_hist_friends_v2(hist_from, hist_to)
  rec_attrs = [{hist_from: hist_from, hist_to: hist_to}, {hist_from: hist_to, hist_to: hist_from}]
  HistFriend.bulk_insert(set_size: group_count) do |worker|
    rec_attrs.each do |attrs|
      worker.add(attrs)
    end
  end
end

def find_hist_friends_v2
  puts "\n#{self.class.name}##{__method__}"
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
          # connect_hist_friends_v2(hist_from.id, hist_to.id) if are_friends
        end
      end
      unless hists_len_p1.empty?
        hists_len_cur.each do |hist_from|
          hists_len_p1.each do |hist_to|
            are_friends = Histogram.friends_hist_type(eval(hist_from.hist), eval(hist_to.hist)) == 1
            connect_hist_friends(hist_from, hist_to) if are_friends
            # connect_hist_friends_v2(hist_from.id, hist_to.id) if are_friends
          end
        end
      end
    end
  end
end

teardown
Benchmark.bm do |x|
  x.report('solo .. read_given_input_file') {
    read_given_input_file(max_words, group_count)
  }
  x.report('solo .. find_hist_friends') {
    find_hist_friends
  }
end
# puts

# 'run':
# # puts
# # puts Benchmark.measure {
#   teardown
#   read_given_input_file
#   find_hist_friends
# }
# # puts
#
# # puts
# # puts Benchmark.measure {
#   teardown
#   read_given_input_file_v2
#   find_hist_friends_v2
# }
# # puts


# puts

# # max_words = 100000
# # group_count = 1000
# max_words = 1000
# group_count = 100
# # # max_words = 16
# # # group_count = 4

# Benchmark.bm do |x|
#   teardown
#   x.report('bulk .. read_given_input_file_v2') {
#     read_given_input_file_v2(max_words, group_count)
#   }
#   x.report('bulk .. find_hist_friends_v2') {
#     find_hist_friends_v2
#   }
#
#   teardown
#   x.report('solo .. read_given_input_file') {
#     read_given_input_file(max_words, group_count)
#   }
#   x.report('solo .. find_hist_friends') {
#     find_hist_friends
#   }
# end

# # group_count = 1000
# Benchmark.bm do |x|
#   teardown
#   x.report('solo .. read_given_input_file') {
#     read_given_input_file(max_words, group_count)
#   }
#   x.report('solo .. find_hist_friends') {
#     find_hist_friends
#   }
#
#   teardown
#   x.report('bulk .. read_given_input_file_v2') {
#     read_given_input_file_v2(max_words, group_count)
#   }
#   x.report('bulk .. find_hist_friends_v2') {
#     find_hist_friends_v2
#   }
# end

max_words = 100000
group_count = 10000

# teardown
# Benchmark.bm do |x|
#   x.report('bulk .. read_given_input_file_v2') {
#     read_given_input_file_v2(max_words, group_count)
#   }
#   x.report('bulk .. find_hist_friends_v2') {
#     find_hist_friends_v2
#   }
# end
