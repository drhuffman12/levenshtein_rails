json.extract! raw_word, :id, :name, :is_test_case, :word_id, :created_at, :updated_at
json.url raw_word_url(raw_word, format: :json)