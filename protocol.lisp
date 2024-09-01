(in-package #:org.shirakumo.messagebox)

(defvar *default-backend*)

(define-condition messagebox-failed (error)
  ())

(defun default-backend ()
  (if (boundp '*default-backend*)
      *default-backend*
      (setf *default-backend* (determine-default-backend))))

(defclass backend () ())

(defgeneric show-backend (backend text &key title type modal &allow-other-keys))

(defmethod show-backend ((backend symbol) text &rest args)
  (apply #'show-backend (make-instance backend) text args))

(defmacro define-implementation (name args &body body)
  `(progn 
     (defclass ,name (backend) ())
     (defmethod show-backend ((backend ,name) ,@args)
       ,@body)))

(defun show (text &rest args &key title type modal (backend (default-backend)) &allow-other-keys)
  (declare (ignore title type modal))
  (remf args :backend)
  (apply #'show-backend backend text args))

(defun run (program &rest args)
  (handler-case
      (multiple-value-bind (output error status)
          (uiop:run-program (list* program (remove NIL args))
                            :output :string
                            :ignore-error-status T
                            :external-format :utf-8)
        (declare (ignore error))
        (values status output))
    (error ()
      (error 'messagebox-failed))))
