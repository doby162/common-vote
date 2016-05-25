(defpackage #:common-vote
  (:use :cl);Why yes I WOULD like to use common lisp
  (:export :cast-votes);TODO
  (:export :count-votes);TODO
  (:export :clear-ballet);done
  (:export :configure-ballet);done
  (:export :print-ballet);done
  (:export :test));done
(in-package :common-vote);if something doesn't work, declare the package!

;global vars would go here
(defparameter *random-color* sdl:*white*);used by test-sdl
(defvar *ballet* nil);the list of things you can vote on, possibly including a screenshot

(defun configure-ballet ()
;loop through prompt-for-ballet untill user is satisfied, either adding to or relacing existing config depending on params
	(loop (push (prompt-for-ballet) *ballet*)
	 (if (not (y-or-n-p "Another? [y/n]: ")) (return)))

	(print-ballet)
	(save-ballet))

(defun print-ballet ()
;dump the contents of the ballet for inspection
  (dolist (cd *ballet*)
    (format t "~{~a:~10t~a~%~}~%" cd)))
(defun save-ballet()
;saves the ballet to disk. RIght now that means ~/quicklisp/local-projects/common-vote/.voterc
	(with-open-file (out "~/quicklisp/local-projects/common-vote/.voterc"
                   :direction :output
                   :if-exists :supersede)
    (with-standard-io-syntax
      (print *ballet* out)))

)
(defun load-ballet ()
;load the existing ballet config from disk
  (with-open-file (in "~/quicklisp/local-projects/common-vote/.voterc" :if-does-not-exist :create)
    (with-standard-io-syntax
      (setf *ballet* (read in nil)))))

(defun clear-ballet ()
	(setf *ballet* "")
	(format t "ballet cleared. Please record a new one or re-load the existing one"))

(defun prompt-for-ballet ()
;specific prompt questions for a single ballet entry
  (list
   :Name
   (prompt-read "Name")
   :Description
   (prompt-read "Description")
   :Team-name
   (prompt-read "Team-name")
   :Path-to-screenshot
   (prompt-read "Path-to-screenshot")))

(defun prompt-read (prompt)
;general command line prompt function
  (format *query-io* "~a: " prompt)
  (force-output *query-io*)
  (read-line *query-io*))

(defun test (); any tests should go here, and be run to make sure a new pi is working
	(format t "~%~a~%" (test-load))
	(test-sdl))

(defun test-sdl ()
  (sdl:with-init ()
    (sdl:window 200 200 :title-caption "Move a rectangle using the mouse")
    (setf (sdl:frame-rate) 60)

    (sdl:with-events ()
      (:quit-event () t)
      (:key-down-event ()
       (sdl:push-quit-event))
      (:idle ()
       ;; Change the color of the box if the left mouse button is depressed
       (when (sdl:mouse-left-p)
         (setf *random-color* (sdl:color :r (random 255) :g (random 255) :b (random 255))))

       ;; Clear the display each game loop
       (sdl:clear-display sdl:*black*)

       ;; Draw the box having a center at the mouse x/y coordinates.
       (sdl:draw-box (sdl:rectangle-from-midpoint-* (sdl:mouse-x) (sdl:mouse-y) 20 20)
                     :color *random-color*)

       ;; Redraw the display
       (sdl:update-display)))))

(defun test-load ()
;output text if loading of this file has worked
	(format t "common-vote has been quickloaded"))

(defun cast-votes()
;display clicky UI and record votes to a file
)




(load-ballet);we probably always want to load this file if it exists
(test);automated testing!
;consider putting a graphical prompt to check if you would like to cast or count?
;interesting. format doesn't output anything when called this way


