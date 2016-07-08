(defpackage #:common-vote
  (:use :cl)
  (:use :ltk)
  (:use :sb-ext)
  (:export :help);
  (:export :cast-votes);
  (:export :count-votes);
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
(setf *random-state* (make-random-state t))
(defvar *canidates* ()) 
(defvar *results* ())
(defvar *tmp* ())
(defvar *low* ())
(defun main ()
  (help)
  (loop (print (eval (read))))
  (sb-ext:exit))

(defun help() 
  (format t "Hello! This help function provides an overveiw of how to use common vote for your raspberry pi voting booth.~%")
  (format t "To get more data on a specific function, type (doc `name-of-function)~%")
  (format t "The functions for setup include: configure-ballot, print-ballot, clear-ballot, test, help, and incorporate~%")
  (format t "The functions for casting and counting votes include: cast-votes, count-votes~%")
  (format t "when you are done, type exit to close this program. Or just close the window it's in, doesn't matter to me.~%"))
(defun count-votes (&optional how-many-winners) 
  "counts votes. Note that this function does not modify any files, so a recount can be done by re-starting this code"
  (setf *results* ())
  (dolist (q *ballot*) (pushnew (getf q :team-name) *canidates*))
  (dolist (w *canidates*)
    (setf *tmp* ())
    (dolist (q *master-tally*) 
      (when (equalp (car q) w) (push (car q) *tmp*)))
    (push w *tmp*)
    (push (reverse *tmp*) *results*))
  (sort *results* #'(lambda (a b) (> (list-length a) (list-length b)))) (setf *low* (last *results*)) (eliminate))

(defun eliminate ()
  (when (>= (- (list-length (first *results*)) 1) (/ (list-length *master-tally*) 2))
    (display-winner)
    (return-from eliminate 0))
  (let ((x (car (car (last *results*))))) 
;    (dolist (y *master-tally*) (when (equalp (first y) x) (format t "~a~%" y) (pop y) (format t "~a~%" y)))))
    (dotimes (i (list-length *master-tally*)) (when (equalp (first (nth i *master-tally*)) x) (pop (nth i *master-tally*))))) (count-votes))

(defun display-winner () 
  (format t "The winner is: ~a With ~a votes! ~%" (car (car *results*)) (- (list-length (car *results*)) 1))
  (format t "All contestants in order: ~%")
  (dolist (r *results*) (format t "~a with ~a votes~%" (car r) (- (list-length r) 1))))

(defun configure-ballot ()
  "loop through a prompt until all entires are entered. This adds to the existing ballot and saves. Also see: clear-ballot"
  (loop (push (prompt-for-ballot) *ballot*)
        (if (not (y-or-n-p "Another? [y/n]: ")) (return)))
  (print-ballot)
  (save-ballot))

(defun print-ballot ()
  "dump the contents of the ballot for inspection"
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
  "load the existing ballot config from disk"
  (with-open-file (in "~/quicklisp/local-projects/common-vote/.voterc" :if-does-not-exist :create)
    (with-standard-io-syntax
      (setf *ballot* (read in nil))))
  (with-open-file (in "~/quicklisp/local-projects/common-vote/tally" :if-does-not-exist :create)
    (with-standard-io-syntax
      (setf *master-tally* (read in nil))))
  )
(defun incorporate (path)
  "Loads an additional tally file, given a file name, and adds it to the existing one without changing the file"
  (with-open-file (in path :if-does-not-exist nil)
    (with-standard-io-syntax
      (setf *aux* (read in nil))))
  (when (not *aux*) (format t "Failed to load file"))
  (dolist (item *aux*) (push  (pop *aux*) *master-tally*))
  (setf *aux* nil))

(defun clear-ballot ()
  "clears the ballot for configure-ballot. does not overwrite ballot on disk unless used with configure-ballot"
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
  "tests some things"
  (format t "~%~a~%" (test-load))
  (ltk::ltk-eyes))

(defun test-load ()
  ;output text if loading of this file has worked
  (format t "common-vote has been quickloaded"))
;end ballot twiddling
;begin gui operations
(defun shuff (lis) (sort lis #'(lambda (x y) (eq 1 (random 2)))));destructive!

(defun gui ()
  (setf *ballot* (shuff *ballot*))
  (let* ((top-frame (make-instance `frame))
         (left-frame (make-instance `frame :master top-frame))
         (right-frame (make-instance `frame :master top-frame))
         (undo-vote (make-instance `button :master right-frame :text "Undo a vote" :command (lambda () (pop *votes*) (destroy (pop *labels*)))))
         (commit-vote (make-instance `button :master right-frame :text "Commit your votes" :command
                                     (unless (eq *votes* ())
                                       (lambda () (push (reverse *votes*) *master-tally*)
                                         (setf *votes* ()) (dolist (x *labels*) (destroy x)) (setf *labels* ()) (save-tally)))))
         (instructions (make-instance `label :master right-frame :text
"Hello voter!
Please click on the names of your favorite games
in order from most to least favrite.
As you click on more games, a list of these games,
in order, will form on the right side of the application.
If you change your mind or make a mistake, hitting
\"undo vote\" will remove items from the list, most
recent to most distant. When you are done with your
list, which may be any length, please click submit \"vote\".
Being ranked last is a higher rank than not being ranked at all.")))
    (pack top-frame)
    (pack left-frame  :side :left )
    (pack undo-vote :side :top)
    (pack commit-vote :side :top)
    (pack instructions :side :top)
    (pack right-frame :side :right)
    (let ((len (list-length *ballot*)) (i 0))
      (dotimes (loops (ceiling (/ len 5)))
        (let ((iframe (make-instance `frame :master left-frame)))
          (dotimes (i 5) 
            (when (> (list-length *ballot*) (+ i (* 5 loops)))
              (gui-entry (nth (+ i (* 5 loops)) *ballot*) iframe right-frame))
              (pack iframe :side :right)))))))

(defun gui-entry (entry master right)
  (let* ((top (make-instance `frame :master master))
         (button (make-instance `button :master top :text (getf entry :name) :command
                                (lambda () (record-vote (getf entry :team-name) right))))
         (image (make-image))
         (canvas (make-instance `canvas :width 250 :height 200 :master top))
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
      (pack vote-indicator :side :top)(push vote-indicator *labels*)))
  (format t "~%The current tally is:")
  (dolist (vote *votes*) (format t "~a~%" vote)))

(defun play () 
  (start-wish)
  (gui))
(defun add () );empty function to be redefined at run time

(defun cast-votes ()
  "launches the graphical user interface and records votes. This adds to the existing vote count, the vote count is reset by configure-ballot"
  (with-ltk ()
            (gui)))

;here we have the startup proceedure
(load-ballot);we probably always want to load this file if it exists
;(test);automated testing!
;consider putting a graphical prompt to check if you would like to cast or count?
;(main)
