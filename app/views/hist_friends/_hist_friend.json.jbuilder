json.extract! hist_friend, :id, :hist_from_id, :hist_to_id, :traced_by, :traced_last_by, :created_at, :updated_at
json.url hist_friend_url(hist_friend, format: :json)