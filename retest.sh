#!/usr/bin/env sh
bin/rails db:environment:set RAILS_ENV=test
RAILS_ENV=test bundle exec rails db:drop
RAILS_ENV=test bundle exec rails db:create
RAILS_ENV=test bundle exec rails db:migrate
# RAILS_ENV=test bundle exec rails db:seed
bundle exec rspec spec/models/concerns/loader_spec.rb -f h -o coverage/rspec.html
