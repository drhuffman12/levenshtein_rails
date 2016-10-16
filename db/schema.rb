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

ActiveRecord::Schema.define(version: 20161016063221) do

  create_table "hist_friends", force: :cascade do |t|
    t.integer  "hist_from_id"
    t.integer  "hist_to_id"
    t.text     "traced_by"
    t.string   "traced_last_by"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "from_length"
    t.integer  "to_length"
    t.string   "comment"
    t.index ["hist_from_id"], name: "index_hist_friends_on_hist_from_id"
    t.index ["hist_to_id"], name: "index_hist_friends_on_hist_to_id"
  end

  create_table "histograms", force: :cascade do |t|
    t.text     "hist"
    t.integer  "length"
    t.integer  "word_length_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["word_length_id"], name: "index_histograms_on_word_length_id"
  end

  create_table "social_nodes", force: :cascade do |t|
    t.integer  "word_orig_id"
    t.integer  "word_from_id"
    t.integer  "word_to_id"
    t.integer  "qty_steps"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["word_from_id"], name: "index_social_nodes_on_word_from_id"
    t.index ["word_orig_id"], name: "index_social_nodes_on_word_orig_id"
    t.index ["word_to_id"], name: "index_social_nodes_on_word_to_id"
  end

  create_table "word_friends", force: :cascade do |t|
    t.integer  "word_from_id"
    t.integer  "word_to_id"
    t.text     "traced_by"
    t.string   "traced_last_by"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "from_length"
    t.integer  "to_length"
    t.string   "comment"
    t.index ["word_from_id"], name: "index_word_friends_on_word_from_id"
    t.index ["word_to_id"], name: "index_word_friends_on_word_to_id"
  end

  create_table "word_lengths", force: :cascade do |t|
    t.integer  "length"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "words", force: :cascade do |t|
    t.string   "name"
    t.integer  "length"
    t.integer  "word_length_id"
    t.integer  "histogram_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["histogram_id"], name: "index_words_on_histogram_id"
    t.index ["word_length_id"], name: "index_words_on_word_length_id"
  end

end
