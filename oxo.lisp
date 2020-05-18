;;; spec -  play noughts and crosses against a human opponent

(defun make-board ()
  "create values for an empty board"
  (list 'board 0 0 0 0 0 0 0 0 0))

(defun convert-to-letter (v)
" 1 = nought, 10 = cross, 0 = empty"
  (cond
    ((equal v 1) "O")
    ((equal v 10) "X" )
    (t " ")))

(defun print-row (x y z)
  (format t "~& ~A | ~A | ~A"
          (convert-to-letter x)
          (convert-to-letter y)
          (convert-to-letter z)))

(defun print-board (board)
  (format t "~%")
  (print-row (nth 1 board) (nth 2 board) (nth 3 board))
  (format t "~&-----------")
  (print-row (nth 4 board) (nth 5 board) (nth 6 board))
  (format t "~&-----------")
  (print-row (nth 7 board) (nth 8 board) (nth 9 board))
  (format t "~%"))

(defun make-move (player pos board)
  "set a board cell to player's symbol and return mutated board"
  (setf (nth pos board) player)
  board)

(setf *computer* 10)
(setf *opponent* 1)

; need to represent possible winning moves: rows, columns, diagonals
(setf *triplets*
      '((1 2 3) (4 5 6) (7 8 9)
        (1 4 7) (2 5 8) (3 6 9)
        (1 5 9) (3 5 7)))

(defun sum-triplet (board triplet)
  (+ (nth (first triplet) board)
     (nth (second triplet) board)
     (nth (third triplet) board)))

(defun compute-sums (board)
  (mapcar #'(lambda (triplet)
              (sum-triplet board triplet))
          *triplets* ))

(defun winner-p (board)
  "compute the triples and look for 3 of the same symbol"
  (let ((sums (compute-sums board)))
    (or (member (* 3 *computer*) sums)
        (member (* 3 *opponent*) sums))))

(defun play-one-game ()
  (if (y-or-n-p "Would you like to go first?")
      (opponent-move (make-board))
      (computer-move (make-board))))

(defun opponent-move (board)
  (let* ((pos (read-a-legal-move board))
         (new-board (make-move
                     *opponent*
                     pos
                     board)))
    (print-board new-board)
    (cond ((winner-p new-board)
           (format t "~& You win!"))
          ((board-full-p new-board)
           (format t "~& Tied game"))
          (t (computer-move new-board)))))

(defun read-a-legal-move (board)
  (format t "~&Your move ")
  (let ((pos (read)))
    (cond ((not (and (integerp pos)
                     (<= 1 pos 9)))
           (format t "~& Illegal Move, must be int 1 to 9")
           (read-a-legal-move board))
          ((not (zerop (nth pos board)))
           (format t "~& that space has been taken")
           (read-a-legal-move board))
          (t pos))))

(defun board-full-p (board)
  (not (member 0 board)))

(defun computer-move (board)
  (let* ((best-move (choose-best-move board))
         (pos (first best-move))
         (strategy (second best-move))
         (new-board (make-move *computer* pos board)))
    (format t "~&My move: ~S" pos)
    (format t "~&My strategy: ~A~%" strategy)
    (print-board new-board)
    (cond ((winner-p new-board)
           (format t "~&I win!"))
          ((board-full-p board)
           (format t "~& Tie!"))
          (t (opponent-move new-board)))))

(defun choose-best-move (board)
  (random-move-strategy board))

(defun random-move-strategy (board)
  (list (pick-random-empty-position board)
        "random move"))

(defun pick-random-empty-position (board)
  (let ((pos (+ 1 (random 9))))
    (if (zerop (nth pos board))
        pos
        (pick-random-empty-position board))))
