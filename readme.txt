So currently the build process goes as follows:

An internet connection is required for this process, however the installed software will not require one

on the raspberry pi, download or receive the sbcl version for armhf.

tar -xvjf sbcl-1.2.14-armhf-linux-binary.tar.bz2

sudo bash sbcl-1.2.14-arm-linux/install.sh

install quicklisp, remembering to add to init file

navigate to quicklisp/local-projects, and clone the project from github

sbcl --eval "(ql:quickload :common-vote)

please note that these instructions and source code areintended for rasperry pi 2. The original pi might work if you used armel, but I can't be sure of that currently. Honestly, any platform that can run steel bank common lisp in a graphical environment should be fine.
