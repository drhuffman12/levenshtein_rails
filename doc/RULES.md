# RULES

TODO (submit code by Sept 4)
----

See:
http://www.meetup.com/CoderNight/events/233221873/

CoderNight September 2016

    Tell a friend Share 

    Wednesday, September 7, 2016

    7:00 PM
    Malwarebytes Office

    410 Park Place Blvd, Clearwater, FL (map)

    Suite 200. We'll get some signs up this time

    Let's meetup again in September.

    This month, we're going to work on a fun problem proposed by Robert Bieber. 

    https://www.codeeval.com/open_challenges/58/

    "Two words are friends if they have a Levenshtein distance of 1 (For details see Levenshtein distance). That is, you can add, remove, or substitute exactly one letter in word X to create word Y. A word’s social network consists of all of its friends, plus all of their friends, and all of their friends’ friends, and so on. Write a program to tell us how big the social network for the given word is, using our word list."

    Here's a file to run against if you want to work on this offline instead of using their editor.

    Sample input file
    https://dl.dropboxusercontent.com/u/6768419/input

    I'd like to get submissions by Sept 4 in order to give people time to look and prepare feedback. As usual, email me (james.deville at gmail.com) or pm me on Slack to submit


----

    https://www.codeeval.com/open_challenges/58/

Levenshtein Distance
Sponsoring Company:

Challenge Description:

Two words are friends if they have a Levenshtein distance of 1 (For details see Levenshtein distance). That is, you can add, remove, or substitute exactly one letter in word X to create word Y. A word’s social network consists of all of its friends, plus all of their friends, and all of their friends’ friends, and so on. Write a program to tell us how big the social network for the given word is, using our word list.
Input sample:

The first argument will be a path to a filename, containing words, and the word list to search in. The first N lines of the file will contain test cases, they will be terminated by string 'END OF INPUT'. After that there will be a list of words one per line. E.g
Output sample:

```
recursiveness
elastic
macrographies
END OF INPUT
aa
aahed
aahs
aalii
...
...
zymoses
zymosimeters
```

For each test case print out how big the social network for the word is. In sample the social network for the word 'elastic' is 3 and for the word 'recursiveness' is 1. E.g.

```
1
3
1
```

    Constraints:
    Number of test cases N in range(15, 30)
    The word list always will be the same and it's length will be around 10000 words

Login to submit solution

