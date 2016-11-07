Re-Seed the data 

```bash
# sh ./reseed.sh

time bundle exec rails db:reset
```

Track Progress:

```bash
RAILS_ENV=production bundle exec rails console
# then ...
# {RawWord: RawWord.count, Histogram: Histogram.count, HistFriend: HistFriend.count, WordFriend: WordFriend.count, SocialNode: SocialNode.count}
# {RawWord: RawWord.count, Word: Word.count, Histogram: Histogram.count, HistFriend: HistFriend.count, WordFriend: WordFriend.count, WordFriend_max_word_from_id: WordFriend.maximum(:word_from_id), SocialNode: SocialNode.count, SocialNode_max_word_orig_id: SocialNode.maximum(:word_orig_id)}
{RawWord: RawWord.count, Word: Word.count, Histogram: Histogram.count, HistFriend: HistFriend.count, HistFriend_max: HistFriend.maximum(:hist_from_id), WordFriend: WordFriend.count, WordFriend_max_word_from_id: WordFriend.maximum(:word_from_id), SocialNode: SocialNode.count, SocialNode_max_word_orig_id: SocialNode.maximum(:word_orig_id)}
```

Run the server 

```bash
RAILS_ENV=production bundle exec rails s
```

# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
