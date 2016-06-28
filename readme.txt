So currently the build process goes as follows:

An internet connection is required for this process, however the installed software will not require one

on the raspberry pi, download or receive the sbcl version for armhf. If you are useing any other hardware, there should be sbcl implimentations available

tar -xvjf sbcl-1.2.14-armhf-linux-binary.tar.bz2

sudo bash sbcl-1.2.14-arm-linux/install.sh

install quicklisp, remembering to add to init file

navigate to quicklisp/local-projects, and clone the project from github

to launch the program type:
sbcl --eval "(ql:quickload :common-vote) or
sbcl --eval "(progn (asdf:operate \`asdf:load-op \`common-vote) (in-package :common-vote))" (prefered)

please note that these instructions and source code areintended for rasperry pi 2. The original pi might work if you used armel, but I can't be sure of that currently. Honestly, any platform that can run steel bank common lisp in a graphical environment should be fine.


usage: Currently the weak points are the ui being a little meh, and the fact that some files have to be manually combined in order to use the results from multiple voting booths, but those shoul be taken care of soon.

to view ussage information while the program in running, type (help) or (common-vote:help)
to configure the .voterc file, type (configure-ballot) (or common-vote:configure-ballot) and follow the prompts

to then run the graphical portion, type (cast-votes) and to count all votes currently loaded into the current vote-machine type (count-votes)
currently, the algorithm only gives first place with accuracy, and only lists the next place as a way of checking for ties.

