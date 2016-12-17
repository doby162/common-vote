(defpackage #:common-vote
  (:use :cl)
  (:use :defrest)
  (:use :sb-ext)
  (:export :run)
  (:export :elect)
  (:export :test))
(in-package :common-vote)
(defvar *tally* ());all votes
(defvar *dispatch-table* (list (create-rest-table-dispatcher)));all routes

;;;;user-level functions
(defun elect (votes eliminated)
  (dolist (vote votes) (pop-if vote eliminated))
  (let ((ls (count-list (remove nil (mapcar #'(lambda (x) (list-exec x :get-top))votes)))))
    (visual ls)
    (when (>= (reduce #'max (mapcar #'cdr ls)) (/ (reduce #'+ (mapcar #'cdr ls)) 2))
      (return-from elect (car (rassoc (reduce #'max (mapcar #'cdr ls)) ls))))
    (elect votes (push (car (rassoc (reduce #'min (mapcar #'cdr ls)) ls)) eliminated))))
(defun run ())
;;;;API-level functions
;;get the ui
(defrest:defrest "/hello" :GET () "hello world!")

;;post the vote

;;book keeping
(defvar *server* (defrest:start (make-instance 'defrest:easy-acceptor :port 8080)))
(push (create-rest-table-dispatcher) hunchentoot:*dispatch-table*)

;;;;support functions
(defun create-vote (list-of-choices)
  (let ((data list-of-choices) (counter 0))
    (return-from create-vote
		 (list :get-top (lambda () (nth counter data)) :pop (lambda () (setf counter (+ 1 counter)) (nth counter data)) :reset (lambda () (setf counter 0)(nth counter data))))))

(defun pop-if (vote elim)
  (dolist (e elim)
    (when (equal e (list-exec vote :get-top)) (list-exec vote :pop) (pop-if vote elim))))

(defun count-list (ls)
  "return an alist, sorted by value, such that the key is the canidate and the value is their votecount."
  (let ((ls-unique ()))
    (dolist (l ls) (pushnew l ls-unique))
    (let ((ret ()) (numbers ()))
      (setf numbers (mapcar #'(lambda (x) (let ((sum 0)) (dolist (l ls) (when (eq l x) (setf sum (+ 1 sum)))) sum)) ls-unique))

      (return-from count-list (reverse (pairlis ls-unique numbers))))))
(defun route-add-vote (list-of-choices)
  (push (create-vote list-of-choices) *tally*))

(defun visual (lis)
  (let ((str "####################################################################################################"))
    (dolist (ls lis) (format t "~a:~a~%" (car ls) (subseq str 0 (cdr ls)))))
  (format t "~%"))

;;;;promising utilities
(defun list-exec (ls ex &optional (n -1))
  "takes a plist and a :property-name and executes the funcion at that location. Optionally operates on the :property of a list at nth of the given list"
  (unless (= -1 n) (setf ls (nth n ls)))
  (funcall (getf ls ex)))

;;;;test suit
(defun test ())
;;effect state for testing
(route-add-vote (list "a" "b" "c" "d"))
(route-add-vote (list "a" "b" "c" "d"))
(route-add-vote (list "a" "b" "c" "d"))
(route-add-vote (list "b" "c" "d"))
(route-add-vote (list "c" "d"))
(route-add-vote (list "c" "d"))
(route-add-vote (list "c" "d"))
