(in-package #:org.shirakumo.messagebox)

(define-condition messagebox-failed (error)
  ())

(defun show-stream (text &key title (type :info) (stream *error-output*) &allow-other-keys)
  (format stream "~&/ [~a]~@[~a~]:" type title)
  (with-input-from-string (input text)
    (loop for line = (read-line input NIL)
          while line
          do (format stream "| ~a~%" line))))

(defun show-backend (text &rest args)
  (apply #'show-stream text args))

(defmacro define-implementation (args &body body)
  `(setf (fdefinition 'show-backend)
         (lambda ,args ,@body)))

(defun show (text &rest args &key title type modal &allow-other-keys)
  (declare (ignore title type modal))
  (handler-case (apply #'show-backend text args)
    (messagebox-failed ()
      (apply #'show-stream text args))))
