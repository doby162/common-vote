(defpackage #:common-vote
  (:use :cl)
  (:use :ltk)
  (:export :cast-votes);TODO
  (:export :count-votes);TODO
  (:export :clear-ballet);done
  (:export :configure-ballet);done
  (:export :print-ballet);done
  (:export :test));done
(in-package :common-vote);if something doesn't work, declare the package!
;this particular macro should go in dorian utils
(defmacro doc (function) `(documentation ,function `function))
;global vars would go here
(defvar *ballet* nil);the list of things you can vote on, possibly including a screenshot
(defvar *votes* ())
(defvar *number-words* (list "First" "Second" "Third" "Fourth" "Fifth" "Sixth" "Seventh" "Eighth" "Ninth" "Tenth" "Eleventh" "Twelth" "Thirteenth"
			     "Fourteenth" "Fifteenth" "Sixteenth" "Seventeeth" "Eighteenth" "Nineteeth" "Twentyith" "Twenty-First" "Twenty-second"))

(defun configure-ballet ()
  "loop through prompt-for-ballet untill user is satisfied, either adding to or relacing existing config depending on params"
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
      (print *ballet* out))))

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
  (ltk::ltk-eyes))

(defun test-load ()
  ;output text if loading of this file has worked
  (format t "common-vote has been quickloaded"))
;end ballet twiddling
;begin gui operations

(defun gui ()
  (let* ((top-frame (make-instance `frame))
	 (left-frame (make-instance `frame :master top-frame))
	 (right-frame (make-instance `frame :master top-frame))
	 (undo-vote (make-instance `button :master right-frame :text "Undo a vote" :command (lambda () (pop *votes*))))
	 (instructions (make-instance `label :master right-frame :text "this is a detailed explaination of voting")))
    (pack top-frame)
    (pack left-frame  :side :left )
    (pack undo-vote :side :top)
    (pack instructions :side :top)
    (pack right-frame :side :right)
    (dolist (entry *ballet*)
      (gui-entry entry left-frame right-frame))
    (add);call an empty function that can have content added to it
    ))

(defun gui-entry (entry master right)
  (let* ((top (make-instance `frame :master master))
	 (button (make-instance `button :master top :text (getf entry :name) :command
				(lambda () (record-vote (getf entry :team-name) right))))
	 (image (make-image))
	 (canvas (make-instance `canvas :width 80 :height 50 :master top))
	 (text (make-instance `label :master top :text (getf entry :description))))
    (pack top :side :bottom)
    (pack button :side :top)
    (pack text :side :bottom)
    (image-load image (getf entry :path-to-screenshot))
    (create-image canvas 0 0 :image image)
    (pack canvas :side :bottom)
    ))
(defun record-vote (team master)
  (unless (eq *votes* (pushnew team *votes*))
    (let ((vote-indicator (make-instance `label :master master :text (format nil "~a vote is for ~a~%" (nth (- (length *votes*) 1) *number-words*) (car *votes*)))))
      (pack vote-indicator :side :bottom)))
  (format t "~%The current tally is:")
  (dolist (vote *votes*) (format t "~a~%" vote)))

(defun play () 
  (start-wish)
  (gui))
(defun add () );empty function to be redefined at run time

(defun cast-votes ()
  (with-ltk ()
	    (gui)))

;here we have the startup proceedure
(load-ballet);we probably always want to load this file if it exists
(test);automated testing!
;consider putting a graphical prompt to check if you would like to cast or count?
