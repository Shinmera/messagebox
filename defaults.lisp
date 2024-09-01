(in-package #:org.shirakumo.messagebox)

(define-condition no-backend-found (messagebox-failed)
  ()
  (:report (lambda (c s) (format s "No usable backend for file-select could be found!"))))

(defun split (char string)
  (let ((paths ())
        (buffer (make-string-output-stream)))
    (flet ((maybe-commit ()
             (let ((string (get-output-stream-string buffer)))
               (when (string/= string "")
                 (push string paths)))))
      (loop for c across string
            do (if (char= c char)
                   (maybe-commit)
                   (write-char c buffer))
            finally (maybe-commit)))
    (nreverse paths)))

(defun find-in-path (file)
  (dolist (path (split #\: (uiop:getenv "PATH")))
    (when (probe-file (merge-pathnames file path))
      (return (merge-pathnames file path)))))

(define-implementation text (text &key title (type :info) (stream *error-output*))
  (format stream "~&/ [~a]~@[~a~]:" type title)
  (with-input-from-string (input text)
    (loop for line = (read-line input NIL)
          while line
          do (format stream "| ~a~%" line))))

(defun determine-default-backend ()
  (cond ((find :win32 *features*)
         'org.shirakumo.messagebox.win32:win32)
        ((find :darwin *features*)
         'org.shirakumo.messagebox.macos:macos)
        ((find :nx *features*)
         'org.shirakumo.messagebox.nxgl:nxgl)
        ((find-in-path "kdialog")
         'org.shirakumo.messagebox.kdialog:kdialog)
        ((find-in-path "matedialog")
         (make-instance 'org.shirakumo.messagebox.zenity:zenity :program-name "matedialog"))
        ((find-in-path "qarma")
         (make-instance 'org.shirakumo.messagebox.zenity:zenity :program-name "qarma"))
        ((find-in-path "zenity")
         'org.shirakumo.messagebox.zenity:zenity)
        ((interactive-stream-p *error-output*)
         'text)
        (T
         (error 'no-backend-found))))