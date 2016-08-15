Common-vote is a graphical vote collection system intended to be run on a raspbery pi or other computer with a keyboard, mouse and monitor.

Common-vote is specifically intended to operate via single transferable vote, which is, in my mind, substantially more democratic than
first past the post voting, especially in small local events where a large number of the voters have a canidate in the election.

Imagine a first past the post election with four canidates, each a pice of software developed by 4 programmers each.
The voting public in this case consists of thos 16 progammers plus Rachel's friend. In this election, all programmers vote for their own
project, except Rachel's friend, who votes for Rachel's project. Rachel's team wins. 

Now imagine the same vote but everyone lists their top picks from favorite to least. In this scenario, everyone still votes for their
own project first, but since Zob the alien's project is clearly superior, it get's everyone's second choice vote and wins.

This works by checking if any canidate has a majority if the votes, and if none is found, removing canidates with the least number
of votes an redistributing their votes to second-choice canidates. This cycle repeats untill a canidate has a majority.
This insures that the voting public can vote for an unpopular project without hurting the chances of their favorite popular project,
and that people with an existing stake in an election can vote for themselves AND the best of their competition.

Common-vote is operated from the command line and uses files on disk to keep count of votes between sessions, such that a vote need not be
completet without the program being closed and re-opened.

Common-vote is not intended for any matters where security is important, it would be relativly easy for an indivisual to cast
multiple votes or modify data if they were not supervised. That said, this software is easy to operate via a REPL for the admin and
via an LTK gui for the voter, and lends itself to backing up of data, and it's fairly fool proof, as long as the user doesn't unplug the
computer while it is running.

Currently the competition this software was intended for has concluded, and now the remaining issues regarding this program are mostley
ease of use related. Hopefully this software will be useful to anyone who wants to conduct a fair local event with prizes.
