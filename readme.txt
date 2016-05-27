So currently the build process goes as follows:

An internet connection is required for this process, however the installed software will not require one

on the raspberry pi, download or receive the sbcl version for armhf. If you are useing any other hardware, there should be sbcl implimentations available

tar -xvjf sbcl-1.2.14-armhf-linux-binary.tar.bz2

sudo bash sbcl-1.2.14-arm-linux/install.sh

install quicklisp, remembering to add to init file

navigate to quicklisp/local-projects, and clone the project from github

sbcl --eval "(ql:quickload :common-vote)

please note that these instructions and source code areintended for rasperry pi 2. The original pi might work if you used armel, but I can't be sure of that currently. Honestly, any platform that can run steel bank common lisp in a graphical environment should be fine.



sudo apt-get install libqt4-dev libsmokeqtgui4-3 libsmokeqt4-dev    <very important

 sudo apt-get install cmake
 sudo apt-get install g++


as things stand the instal proceedure is going to turn out to be irrelevent. Weather I send out a binary or source, it seems to work with the default install of raspbian

TODO:

Ok, so currently I am aiming ot get this finished and uploaded by june 15th. By then, the folowing features need to be implemented:

users need to be able to easily specify what teams will be on the ballet. Either with a command line interface or a dot file. An arbitrary number of teams will be supported
	screen shots included?
	If there are screen shots the application might need to be able to scroll to allow them all.

The list of teams needs to be graphically represented and clickable

Votes must be saved in a format which is lisp-parsable and appendable, easily. Plist probably

Votes must be sorted with arbitrary parameters, such as number of winners
