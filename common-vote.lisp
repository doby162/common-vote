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
(defvar *int* 0)

;;;;user-level functions
(defun run () (reset-votes *tally*) (elect *tally* ()))
;;;;API-level functions
;;get the ui
(defrest:defrest "/vote" :GET ()
  (let ((resp (format nil "<p>Please select your favorite game of the available choices</p><h2>You may rank as many games as you like, in order from most to least favourite.</h2>
                      <p>Currently, you have selected <br>~a<br> as your choices, in that order</p>
                      <p><form method='get' action='commit'><input type='hidden' name='vote' value='~a'><input type='submit' value='Submit your vote'></form></p>
<a href='/vote'>Reset your vote</a>"
                      (html-list (hunchentoot:get-parameter "vote"))(hunchentoot:get-parameter "vote"))))
    (dolist (can *cans*) (unless (search can (hunchentoot:get-parameter "vote")) (setf resp (concatenate 'string resp (format nil
      "<hr></hr><div><p><form method='get'><input name='vote' type='hidden' value='~a ~a,'><input name='last' type='submit' value='~a'></form><image width='200' height='200' src='~a'></p></div>"
      (or (hunchentoot:get-parameter "vote") "") can can (cdr (assoc can *imgs* :test #'equalp))))))) resp))

(defrest:defrest "/save" :GET ()
  (format nil "<img src='http://www.commentsdb.com/wp-content/uploads/2015/07/Congratulations-You-Did-It-Graphic.jpg'> <script type='text/javascript'>
          setTimeout(function(){window.location.href = '/vote';}, 5000); </script>"))

(defrest:defrest "/sav" :GET ()
  (route-add-vote (parse (hunchentoot:get-parameter "vote")))
  (format nil "<script type='text/javascript'> window.location.href = '/save';</script>"))

(defrest:defrest "/commit" :GET ()
(format nil
"<html>
<head>
</head>

<script>

var r = confirm('You have chosen to vote for the following teams: ~a in that order. Is this correct?');
    if (r == true) {
    txt = 'You pressed OK!';
window.location.href = '/sav?vote=~a'
    } else {
    txt = 'You pressed Cancel!';
window.location.href = '/vote?vote=~a'
    }


</script>

<body><p>confirm</p></body>
"
(hunchentoot:get-parameter "vote")(hunchentoot:get-parameter "vote")(hunchentoot:get-parameter "vote")))

(defrest:defrest "/signup" :GET ()"
		 <form method='post'>
		 <p>Screenshot for your game * We suggest using one that showcases familiar gameplay or recognizable characters, instead of title screens or logos. * Use a direct, public image link - for example [http://i.imgur.com/b3yD9SR.png]</p>
		 <input type='text' name='signup' value='Team name : Game name'>
		 <input type='text' name='image' value='Image link here'>
		 <input type='submit'>
		 </form>
		 ")
(defrest:defrest "/signup" :POST ()
		 (pushnew (hunchentoot:post-parameter "signup") *cans*)
		 (pushnew (cons (hunchentoot:post-parameter "signup") (hunchentoot:post-parameter "image")) *imgs*)
		 (concatenate 'string "<p>Thanks a bunch " (hunchentoot:post-parameter "signup") "!</p>"))

(defrest:defrest "/run" :GET () (format nil "<p>~a is the winner!</p>" (run)))

;;post the vote

;;book keeping
(defun serve () 
(defvar *server* (defrest:start (make-instance 'defrest:easy-acceptor :port 8182)))
(push (create-rest-table-dispatcher) hunchentoot:*dispatch-table*)
(read)
)

;;;;support functions
(defun elect (votes eliminated)
  (dolist (vote votes) (pop-if vote eliminated))
  (let ((ls (count-list (remove-if #'(lambda (x) (equalp x "NIL")) (remove nil (mapcar #'(lambda (x) (list-exec x :get-top))votes))))))
    (visual ls)
    (when (>= (reduce #'max (mapcar #'cdr ls)) (/ (reduce #'+ (mapcar #'cdr ls)) 2))
      (return-from elect (car (rassoc (reduce #'max (mapcar #'cdr ls)) ls))))
    (elect votes (push (car (rassoc (reduce #'min (mapcar #'cdr ls)) ls)) eliminated))))

(defun html-elect (votes eliminated str)
  (dolist (vote votes) (pop-if vote eliminated))
  (let ((ls (count-list (remove-if #'(lambda (x) (equalp x "NIL")) (remove nil (mapcar #'(lambda (x) (list-exec x :get-top))votes))))))
    (setf str (concatenate 'string str (html-visual ls)))
    (when (>= (reduce #'max (mapcar #'cdr ls)) (/ (reduce #'+ (mapcar #'cdr ls)) 2))
      (return-from html-elect (car (rassoc (reduce #'max (mapcar #'cdr ls)) ls))))
    (html-elect votes (push (car (rassoc (reduce #'min (mapcar #'cdr ls)) ls)) eliminated) str)str))

(defun parse (a)
  (split-by #\, (string-trim "," a)))

(defun html-list (a)
  (let ((b ""))
    (dolist (ls (parse a)) (setf b (concatenate 'string b (format nil "<br>~a<br>" ls))))b))

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

(defun html-visual (lis)
  (let ((str "########################################################################################################################################################################################################")(blank "")) 
   (dolist (ls lis) (setf blank (concatenate 'string blank (format nil "~a:~a~%" (car ls) (subseq str 0 (cdr ls))))))
  (setf blank (concatenate 'string blank (format nil "~%")))blank))

(defun align ()
  (setf *int* (+ *int* 1))
  (nth (mod *int* 2) '("white" "grey")))

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
  (pushnew (cons "a" "http://imgs.xkcd.com/comics/trash.png") *imgs*)
  (push "b" *cans*)
  (pushnew (cons "b" "http://imgs.xkcd.com/comics/time_capsule.png") *imgs*)
  (push "c" *cans*)
  (pushnew (cons "c" "http://imgs.xkcd.com/comics/feathers.png") *imgs*)
  (push "d" *cans*)
  (pushnew (cons "d" "http://imgs.xkcd.com/comics/nostalgia.png") *imgs*)
  (push "e" *cans*)
  (pushnew (cons "e" "http://imgs.xkcd.com/comics/fermirotica.png") *imgs*)
  (assert (equalp (run) "c"))
  (route-add-vote (list "a"))
  (run)
  (assert (equalp (run) "a"))
  (setf *tally* ()))


;(test)
