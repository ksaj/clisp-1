;;; Copyright (C) 2000 by Sam Steingold
;;; This file is a part of CLISP (http://clisp.cons.org), and, as such,
;;; is distributed under the GNU GPL (http://www.gnu.org/copyleft/gpl.html)

(in-package "LISP")

(export '(clhs *browsers* read-from-file browse-url))

(in-package "SYSTEM")

(defvar *clhs-table* nil)       ; the hash table

(defun clhs-file ()
  ; $(lisplibdir)/data/clhs.txt
  (merge-pathnames
   "clhs.txt"
   (let ((libdir (sys::lib-directory)))
     (make-pathname
      :host (pathname-host libdir)
      :device (pathname-device libdir)
      :directory #+unix (append (pathname-directory libdir) (list "data"))
                 #-unix (pathname-directory libdir)))))

(defvar *browsers*              ; alist of browsers & commands
  '((:netscape "/usr/local/bin/netscape" "-remote" "openURL(~a,new-window)")
    (:emacs-w3 "/usr/local/bin/gnudoit" "(w3-fetch \"~a\")")))

(defun read-from-file (file &key (out *standard-output*))
  "Read an object from a file.
The keyword argument OUT specifies the output for log messages."
  (let ((beg-real (get-internal-real-time)))
    (prog1 (with-open-file (str file :direction :input)
             (when out
               (format out "~&;; Reading `~a' [~:d bytes]..."
                       file (file-length str))
               (force-output (if (eq out t) *standard-output* out)))
             (with-standard-io-syntax
               ; Look up the symbols in package COMMON-LISP, not
               ; COMMON-LISP-USER, which is under user's control.
               (let ((*package* (find-package "COMMON-LISP")))
                 (read str))))
      (when out
        (format out "done [~,2f sec]~%"
                (/ (- (get-internal-real-time) beg-real)
                   internal-time-units-per-second))))))

(defun browse-url (url &key (browser :netscape) (out *standard-output*))
  "Run the browser (a keyword in `*browsers*' or a list) on the URL."
  (let* ((command
          (etypecase browser
            (list browser)
            (symbol (or (cdr (assoc browser *browsers* :test #'eq))
                        (error "unknown browser: `~s' (must be a key in `~s')"
                               browser '*browsers*)))))
         (args (mapcar (lambda (arg) (format nil arg url)) (cdr command))))
    (when out
      (format out "~&;; running [~s~{ ~s~}]..." (car command) args)
      (force-output (if (eq out t) *standard-output* out)))
    (run-program (car command) :arguments args)
    (when out
      (format out "done~%"))))

(defun clhs (symbol-string &key (browser :netscape) (out *standard-output*))
  "Dump the CLHS doc for the symbol."
  (unless *clhs-table*
    (setq *clhs-table* (read-from-file (clhs-file) :out out)))
  (do* ((symbol (etypecase symbol-string
                  (symbol symbol-string)
                  (string
                    (let ((pack (find-package "COMMON-LISP")))
                      (multiple-value-bind (symb found-p)
                          (find-symbol (string-upcase symbol-string) pack)
                        (unless (eq found-p ':external)
                          (error "no symbol named ~s exported from ~s"
                                 symbol-string pack))
                        symb)))))
        (path-list (or (gethash symbol *clhs-table*)
                       (error "No HyperSpec doc for `~s'" symbol))
                   (cdr path-list)))
       ((endp path-list))
    (browse-url
     (concatenate 'string (lisp::clhs-root) "/Body/" (car path-list))
     :browser browser :out out)))
