#!/usr/bin/env sh
#bundle exec rails db:drop
#bundle exec rails db:create
#bundle exec rails db:migrate

##bin/rails db:environment:set RAILS_ENV=development
#bundle exec rails db:environment:set RAILS_ENV=development
#bundle exec rails db:drop db:create db:migrate --trace

bundle exec rails db:environment:set RAILS_ENV=development db:drop db:create db:migrate --trace

bundle exec rails db:seed
