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
  Rake::Task['db:reset'].invoke
end

def read_given_input_file
  i = 0
  File.read('./doc/input').each_line do |name|
    i += 1

    # TODO: add field for orig_name OR usable_name to Word
    # Word.create(name: name) if i < 20
    Word.create(name: Word.to_usable(name)) if i < 20
  end
end

# 'run':
teardown
read_given_input_file
