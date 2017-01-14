(defpackage #:common-vote
  (:use :cl)
  (:use :defrest)
  (:use :sb-ext)
  (:export :run)
  (:export :test))
(in-package :common-vote)
(defvar *tally* ());all votes
(defvar *dispatch-table* (list (create-rest-table-dispatcher)));all routes
(defvar *cans* ())
(defvar *imgs* ())

;;;;user-level functions
(defun run () (reset-votes *tally*) (elect *tally* ()))
;;;;API-level functions
;;get the ui
(defrest:defrest "/vote" :GET ()
  (let ((resp (format nil "<p>Plz 2 vot</p> <p><form method='get' action='commit'><input type='hidden' name='vote' value='~a'><input type='submit' value='Submit your vote'></form></p>" (hunchentoot:get-parameter "vote"))))
    (dolist (can *cans*) (unless (search can (hunchentoot:get-parameter "vote")) (setf resp (concatenate 'string resp (format nil
      "<p><form method='get'><input name='vote' type='submit' value='~a ~a,'></form> <image width='200' height='200' src='~a'></p>" (or (hunchentoot:get-parameter "vote") "") can (cdr (assoc can *imgs* :test #'equalp))))))) resp))

(defrest:defrest "/save" :GET ()
  (route-add-vote (parse (hunchentoot:get-parameter "vote")))
  (format nil "~a <script type='text/javascript'> window.location.href = 'http://localhost:8080/vote' </script>" (parse (hunchentoot:get-parameter "vote"))))
;"<html>
;<head>
;</head>

;<script type='text/javascript'>
;//window.location.href = 'http://localhost:8080/vote'
;</script>
;
;<body><p>hey</p>
;
;</body>
;" )

(defrest:defrest "/commit" :GET ()
(format nil
"<html>
<head>
</head>

<script>

var r = confirm('Press a button!\nEither OK or Cancel.\nThe button you pressed will be displayed in the result window.');
    if (r == true) {
    txt = 'You pressed OK!';
window.location.href = 'http://localhost:8080/save?vote=~a'
    } else {
    txt = 'You pressed Cancel!';
window.location.href = 'http://xkcd.com/vote'
    }


</script>

<body><p>confirm</p></body>
"
(hunchentoot:get-parameter "vote")))

(defrest:defrest "/signup" :GET ()"
		 <form method='post'>
		 <input type='text' name='signup' value='Your team name here'>
		 <input type='text' name='image' value='Image link here'>
		 <input type='submit'>
		 </form>
		 ")
(defrest:defrest "/signup" :POST ()
		 (pushnew (hunchentoot:post-parameter "signup") *cans*)
		 (pushnew (cons (hunchentoot:post-parameter "signup") (hunchentoot:post-parameter "image")) *imgs*)
		 (concatenate 'string "<p>Thanks a bunch " (hunchentoot:post-parameter "signup") "!</p>"))

;;post the vote

;;book keeping
(defvar *server* (defrest:start (make-instance 'defrest:easy-acceptor :port 8080)))
(push (create-rest-table-dispatcher) hunchentoot:*dispatch-table*)

;;;;support functions
(defun elect (votes eliminated)
  (dolist (vote votes) (pop-if vote eliminated))
  (let ((ls (count-list (remove-if #'(lambda (x) (equalp x "NIL")) (remove nil (mapcar #'(lambda (x) (list-exec x :get-top))votes))))))
    (visual ls)
    (when (>= (reduce #'max (mapcar #'cdr ls)) (/ (reduce #'+ (mapcar #'cdr ls)) 2))
      (return-from elect (car (rassoc (reduce #'max (mapcar #'cdr ls)) ls))))
    (elect votes (push (car (rassoc (reduce #'min (mapcar #'cdr ls)) ls)) eliminated))))

(defun parse (a)
  (split-by #\, (string-trim "," a)))

(defun reset-votes (votes) 
  (dolist (vote votes) (list-exec vote :reset)))

(defun create-vote (list-of-choices)
  (let ((data list-of-choices) (counter 0))
    (return-from create-vote
		 (list :get-top (lambda () (string-trim " " (nth counter data))) :pop (lambda () (setf counter (+ 1 counter)) (nth counter data)) :reset (lambda () (setf counter 0)(nth counter data))))))

(defun pop-if (vote elim)
  (dolist (e elim)
    (when (equal e (list-exec vote :get-top)) (list-exec vote :pop) (pop-if vote elim))))

(defun count-list (ls)
  "return an alist, sorted by value, such that the key is the canidate and the value is their votecount."
  (let ((ls-unique ()))
    (dolist (l ls) (pushnew l ls-unique :test #'equalp))
    (let ((numbers ()))
      (setf numbers (mapcar #'(lambda (x) (let ((sum 0)) (dolist (l ls) (when (equalp l x) (setf sum (+ 1 sum)))) sum)) ls-unique))

      (return-from count-list (reverse (pairlis ls-unique numbers))))))

(defun route-add-vote (list-of-choices)
  (push (create-vote list-of-choices) *tally*))

(defun visual (lis)
  (let ((str "########################################################################################################################################################################################################"))
    (dolist (ls lis) (format t "~a:~a~%" (car ls) (subseq str 0 (cdr ls)))))
  (format t "~%"))

;;;;promising utilities
(defun list-exec (ls ex &optional (n -1))
  "takes a plist and a :property-name and executes the funcion at that location. Optionally operates on the :property of a list at nth of the given list"
  (unless (= -1 n) (setf ls (nth n ls)))
  (funcall (getf ls ex)))

(defun split-by (char string);make general
    (loop for i = 0 then (1+ j)
          as j = (position #\, string :start i)
          collect (subseq string i j)
          while j))

;;;;test suit
(defun test ()
  ;;effect state for testing
  (route-add-vote (list "a" "b" "c" "d"))
  (route-add-vote (list "a" "b" "c" "d"))
  (route-add-vote (list "a" "b" "c" "d"))
  (route-add-vote (list "b" "c" "d"))
  (route-add-vote (list "c" "d"))
  (route-add-vote (list "c" "d"))
  (route-add-vote (list "c" "d"))
  (push "a" *cans*)
  (push "b" *cans*)
  (push "c" *cans*)
  (push "d" *cans*)
  (push "e" *cans*)
  (assert (equalp (run) "c"))
  (route-add-vote (list "a"))
  (run)
  (assert (equalp (run) "a"))
  (setf *tally* ()))
