(defvar *db* nil)

(defun make-cd (title artist rating ripped)
  (list :title title :artist artist :rating rating :ripped ripped))

(defun add-record (cd) (push cd *db*))

(defun dump-db ()
  (dolist (cd *db*)
    (format t "~{~a:~10t~a~%~}~%" cd)))

(defun prompt-read (prompt)
  (format *query-io* "~a: " prompt)
  (force-output *query-io*)
  (read-line *query-io*))

(defun prompt-for-cd ()
  "user interaction gets cd properties and feeds them into make-cd"
  (make-cd
   (prompt-read "Title")
   (prompt-read "Artist")
   (or (parse-integer (prompt-read "Rating") :junk-allowed t) 0)
   (y-or-n-p "Ripped [y/n]: ")))

(defun add-cds ()
  "make-cd using prompt-for-cd, then pushes cd to *db* with add-record"
  (loop (add-record (prompt-for-cd))
     (if (not (y-or-n-p "Another? [y/n]: ")) (return))))

(defun save-db (filename)
  (with-open-file (out filename
                       :direction :output
                       :if-exists :supersede)
    (with-standard-io-syntax
      (print *db* out))))

(defun load-db (filename)
  (with-open-file (in filename)
    (with-standard-io-syntax
      (setf *db* (read in)))))

(defun clear-db () (setq *db* nil))

(defun select-by-artist (artist)
  "Early select function, we want to abstract the selector. See below"
  (remove-if-not
   #'(lambda (cd) (equal artist (getf cd :artist)))
   *db*))

(defun select (selector-fn)
  "Returns *db* rows that match selector-fn"
  (remove-if-not selector-fn *db*))

(defun artist-selector (artist)
  #'(lambda (cd) (equal (getf cd :artist) artist)))

(defun title-selector (title)
  #'(lambda (cd) (equal (getf cd :title) title)))

(defun make-comparison-expr (field value)
  `(equal (getf cd ,field) ,value))

(defun make-comparison-list (fields)
  (loop while fields
        collecting (make-comparison-expr (pop fields) (pop fields))))

;; Original version of where function
;(defun where (&key title artist rating (ripped nil ripped-p))
;  #'(lambda (cd)
;      (and
;       (if title    (equal (getf cd :title)  title)  t)
;       (if artist   (equal (getf cd :artist) artist) t)
;       (if rating   (equal (getf cd :rating) rating) t)
;       (if ripped-p (equal (getf cd :ripped) ripped) t))))

(defmacro where (&rest clauses)
  `#'(lambda (cd) (and ,@(make-comparison-list clauses))))

(defun update (selector-fn &key title artist rating (ripped nil ripped-p))
  (setf *db*
        (mapcar
         #'(lambda (row)
             (when ((funcall) selector-fn row)
               (if title    (setf (getf row :title) title))
               (if artist   (setf (getf row :artist) artist))
               (if rating   (setf (getf row :rating) rating))
               (if ripped-p (setf (getf row :ripped) ripped)))
             row) *db*)))

(defun delete-rows (selector-fn)
  (setf *db* (remove-if selector-fn *db*)))
