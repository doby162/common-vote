Common-vote is a web based vote collection system intended to be run from Steel Bank Common Lisp on a processor capable of multithreading.

Common-vote is specifically intended to operate via single transferable vote, which is, in my mind, substantially more democratic than
first past the post voting, especially in small local events where a large number of the voters have a candidate in the election.

Imagine a first past the post election with four candidates (each a piece of software developed by 4 programmers).
The voting public in this case consists of those 16 programmers plus Rachel's friend. In this election, all programmers vote for their own
project, except Rachel's friend, who votes for Rachel's project. Rachel's team wins. 

Now imagine the same vote but everyone lists their top picks from favorite to least. In this scenario, everyone still votes for their
own project first, but since Zob the alien's project is clearly superior, it gets everyone's second choice vote and wins.

This works by checking if any candidate has a majority of the votes. If no one has more than half of the votes, the program will remove the candidate with the least number
of votes and redistribute their votes to the  second-choice candidates. This cycle repeats until a candidate has a majority.
This insures that the voting public can vote for an unpopular project without hurting the chances of their favorite popular project,
and that people with an existing stake in an election can vote for themselves AND the best of their competition.

Common-vote is not intended for any matters where security is important, it would be relatively easy for an individual to cast
multiple votes if they were not supervised.

The url for the current testing version of common vote is michael-dorian.space:8182/vote for voting,
michael-dorian.space:8182/signup for adding candidates, and michael-dorian.space:8182/run to check the winner.
