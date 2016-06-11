(push :TK8.4 *features*)
(defpackage #:common-vote
  (:use :cl)
  (:use :ltk)
  (:export :cast-votes);TODO
  (:export :count-votes);TODO
  (:export :clear-ballot);done
  (:export :configure-ballot);done
  (:export :print-ballot);done
  (:export :test));done cross compile? built in test framework
(in-package :common-vote);if something doesn't work, declare the package!
;this particular macro should go in dorian utils
(defmacro doc (function) `(documentation ,function `function))
;global vars would go here
(defvar *ballot* nil);the list of things you can vote on, possibly including a screenshot
(defvar *votes* ())
(defvar *labels* ())
(defvar *master-tally* ())
(defvar *number-words* (list "First" "Second" "Third" "Fourth" "Fifth" "Sixth" "Seventh" "Eighth" "Ninth" "Tenth" "Eleventh" "Twelth" "Thirteenth"
                             "Fourteenth" "Fifteenth" "Sixteenth" "Seventeeth" "Eighteenth" "Nineteeth" "Twentyith" "Twenty-First" "Twenty-second"))
(defvar *canidates* ()) 
(defvar *results* ())
(defvar *tmp* ())
(defun count-votes (&optional how-many-winners) 
  (setf *results* ())
  (dolist (q *ballot*) (pushnew (getf q :team-name) *canidates*))
  (dolist (w *canidates*)
    (setf *tmp* ())
    (dolist (q *master-tally*) 
      (when (equalp (car q) w) (push (car q) *tmp*)))
    (push w *tmp*)
    (push (reverse *tmp*) *results*))
  (sort *results* #'(lambda (a b) (> (list-length a) (list-length b))))(display-winner))

(defun display-winner () 
  (format t "The winner is: ~a With ~a votes! ~%" (car (car *results*)) (- (list-length (car *results*)) 1))
  (format t "All contestants in order: ~%")
  (dolist (r *results*) (format t "~a with ~a votes~%" (car r) (- (list-length r) 1)))
  )

(defun configure-ballot ()
  "loop through prompt-for-ballot untill user is satisfied, either adding to or relacing existing config depending on params"
  (loop (push (prompt-for-ballot) *ballot*)
        (if (not (y-or-n-p "Another? [y/n]: ")) (return)))
  (print-ballot)
  (save-ballot))

(defun print-ballot ()
  ;dump the contents of the ballot for inspection
  (dolist (cd *ballot*)
    (format t "~{~a:~10t~a~%~}~%" cd)))

(defun save-ballot()
  ;saves the ballot to disk. RIght now that means ~/quicklisp/local-projects/common-vote/.voterc
  (with-open-file (out "~/quicklisp/local-projects/common-vote/.voterc"
                       :direction :output
                       :if-exists :supersede)
    (with-standard-io-syntax
      (print *ballot* out))))
(defun save-tally();I might want to make these save functions into a generic one
  (with-open-file (out "~/quicklisp/local-projects/common-vote/tally"
                       :direction :output
                       :if-exists :supersede)
    (with-standard-io-syntax
      (print *master-tally* out))))

(defun load-ballot ()
  ;load the existing ballot config from disk
  (with-open-file (in "~/quicklisp/local-projects/common-vote/.voterc" :if-does-not-exist :create)
    (with-standard-io-syntax
      (setf *ballot* (read in nil))))
  (with-open-file (in "~/quicklisp/local-projects/common-vote/tally" :if-does-not-exist :create)
    (with-standard-io-syntax
      (setf *master-tally* (read in nil))))
  )

(defun clear-ballot ()
  (setf *ballot* "")
  (setf *master-tally* ());it doesn't make sense to keep votes for a deleted ballot
  (format t "ballot cleared. Please record a new one or re-load the existing one"))

(defun prompt-for-ballot ()
  ;specific prompt questions for a single ballot entry
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
;end ballot twiddling
;begin gui operations

(defun gui ()
  (font-create "herb" :size 50)
  (let* ((top-frame (make-instance `frame))
         ;         (herb (font-create "herb"
         ;         (name &key family size weight slant underline overstrike)
         (left-frame (make-instance `frame :master top-frame))
         (right-frame (make-instance `frame :master top-frame))
         (undo-vote (make-instance `button :master right-frame :text "Undo a vote" :command (lambda () (pop *votes*) (destroy (pop *labels*)))))
         (commit-vote (make-instance `button :master right-frame :text "Commit your votes" :command
                                     (lambda () (push (reverse *votes*) *master-tally*) (setf *votes* ()) (dolist (x *labels*) (destroy x)) (setf *labels* ()) (save-tally))))
         (instructions (make-instance `label :master right-frame :text "this is a detailed explaination of voting")))
    (pack top-frame)
    (pack left-frame  :side :left )
    (pack undo-vote :side :top)
    (pack commit-vote :side :top)
    (pack instructions :side :top)
    (pack right-frame :side :right)
    (dolist (entry *ballot*)
      (gui-entry entry left-frame right-frame))
    (add);call an empty function that can have content added to it
    ))

(defun gui-entry (entry master right)
  (let* ((top (make-instance `frame :master master))
         (button (make-instance `button :master top :text (getf entry :name) :command
                                (lambda () (record-vote (getf entry :team-name) right))))
         (image (make-image))
         (canvas (make-instance `canvas :width 80 :height 50 :master top))
         (text (make-instance `label :font "Helvetica 10 bold" :master top :text (getf entry :description))))
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
      (pack vote-indicator :side :bottom)(push vote-indicator *labels*)))
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
(load-ballot);we probably always want to load this file if it exists
;(test);automated testing!
;consider putting a graphical prompt to check if you would like to cast or count?
