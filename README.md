# Levenshtein Social Network

* Calculate the 'social network' quantity for a group of words based on their Levenshtein Distance.
* See [RULES.md](doc/RULES.md).

### This approach utilizes:
 * adjustable # of words to process (currently via editing the value for `max_words` (or `max_words_sizes`) in `db/seeds.rb` or by creating a `Loader` with applicable params.)
 * 'raw' words vs (filtered) 'words' (i.e.: some characters are ignored, such as '-', so "a-b" would be treated as if it is "ab") 
 * word lengths
 * the histogram of letters of each word
 * histogram 'friends' (i.e.: exactly 1 letter is different, either via 'add a letter', 'remove a letter', or 'change a letter')
 * word 'friends' (i.e.: likewise, filtered by various combinations of that word's histogram and that histogram's 'friends')
 * social network (i.e.: a word's social network is all of the words that it can get to via it's friends' and their 'friends', etc.)

#### For example, given the following word list:

```
abc
abcd
abd
ab'd
abcde
xyz
x-y z
```

#### We'd end up with:

| word | qty in soc network | friends | soc network
|---|---|---|---
| abc | 3 | "abcd", "abd" (aka "ab'd") | "abcd", "abd", "abcde"
| abcd | 3 | "abc", "abd" (aka "ab'd") | "abc", "abd", "abcde"
| abd | 3 | "abc", "abcd" | "abc", "abcd", "abcde"
| ab'd | 3 | "abc", "abcd" | "abc", "abcd", "abcde"
| abcde | 3 | "abcd" | "abc", "abcd", "abd"
| xyz | 0 | (none) | (none) |
| x-y z | 0 | (none) | (none) |

* See also the `report*.txt` files for more sample runs (of various `max_words`) against [doc/input](doc/input).

## Re-Seed the data 

```bash
sh ./reseed.sh

# time bundle exec rails db:reset

time sh ./reseed.sh

```

## Track Progress:

```bash
RAILS_ENV=production bundle exec rails console
# then ...
# {RawWord: RawWord.count, Histogram: Histogram.count, HistFriend: HistFriend.count, WordFriend: WordFriend.count, SocialNode: SocialNode.count}
# {RawWord: RawWord.count, Word: Word.count, Histogram: Histogram.count, HistFriend: HistFriend.count, WordFriend: WordFriend.count, WordFriend_max_word_from_id: WordFriend.maximum(:word_from_id), SocialNode: SocialNode.count, SocialNode_max_word_orig_id: SocialNode.maximum(:word_orig_id)}

{RawWord: RawWord.count, Word: Word.count, Histogram: Histogram.count, HistFriend: HistFriend.count, HistFriend_max: HistFriend.maximum(:hist_from_id), WordFriend: WordFriend.count, WordFriend_max_word_from_id: WordFriend.maximum(:word_from_id), SocialNode: SocialNode.count, SocialNode_max_word_orig_id: SocialNode.maximum(:word_orig_id)}

```

## Run the server 

```bash
RAILS_ENV=production bundle exec rails s
```

## Test

```sh
sh ./retest.sh
```

