# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161105201128) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "hist_friends", force: :cascade do |t|
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.text     "traced_by"
    t.string   "traced_last_by"
    t.integer  "hist_from_id"
    t.integer  "hist_to_id"
    t.integer  "from_length"
    t.integer  "to_length"
    t.string   "comment"
    t.index ["hist_from_id"], name: "index_hist_friends_on_hist_from_id", using: :btree
    t.index ["hist_to_id"], name: "index_hist_friends_on_hist_to_id", using: :btree
  end

  create_table "histograms", force: :cascade do |t|
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.text     "hist"
    t.integer  "length"
    t.integer  "word_length_id"
    t.index ["word_length_id"], name: "index_histograms_on_word_length_id", using: :btree
  end

  create_table "raw_words", force: :cascade do |t|
    t.string   "name"
    t.string   "is_test_case"
    t.integer  "word_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["word_id"], name: "index_raw_words_on_word_id", using: :btree
  end

  create_table "social_nodes", force: :cascade do |t|
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "qty_steps"
    t.integer  "word_orig_id"
    t.integer  "word_from_id"
    t.integer  "word_to_id"
    t.index ["word_from_id"], name: "index_social_nodes_on_word_from_id", using: :btree
    t.index ["word_orig_id"], name: "index_social_nodes_on_word_orig_id", using: :btree
    t.index ["word_to_id"], name: "index_social_nodes_on_word_to_id", using: :btree
  end

  create_table "word_friends", force: :cascade do |t|
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.text     "traced_by"
    t.string   "traced_last_by"
    t.integer  "word_from_id"
    t.integer  "word_to_id"
    t.integer  "from_length"
    t.integer  "to_length"
    t.string   "comment"
    t.index ["word_from_id"], name: "index_word_friends_on_word_from_id", using: :btree
    t.index ["word_to_id"], name: "index_word_friends_on_word_to_id", using: :btree
  end

  create_table "word_lengths", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "length"
  end

  create_table "words", force: :cascade do |t|
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "name"
    t.integer  "length"
    t.integer  "word_length_id"
    t.integer  "histogram_id"
    t.string   "traversed_ids"
    t.string   "is_test_case"
    t.integer  "soc_net_size"
    t.index ["histogram_id"], name: "index_words_on_histogram_id", using: :btree
    t.index ["word_length_id"], name: "index_words_on_word_length_id", using: :btree
  end

  add_foreign_key "hist_friends", "histograms", column: "hist_from_id"
  add_foreign_key "hist_friends", "histograms", column: "hist_to_id"
  add_foreign_key "histograms", "word_lengths"
  add_foreign_key "raw_words", "words"
  add_foreign_key "social_nodes", "words", column: "word_from_id"
  add_foreign_key "social_nodes", "words", column: "word_orig_id"
  add_foreign_key "social_nodes", "words", column: "word_to_id"
  add_foreign_key "word_friends", "words", column: "word_from_id"
  add_foreign_key "word_friends", "words", column: "word_to_id"
  add_foreign_key "words", "histograms"
  add_foreign_key "words", "word_lengths"
end
