(in-package #:org.shirakumo.messagebox)

(define-implementation (text &key title (type :info) modal (code 0) &allow-other-keys)
    (declare (ignore modal title))
    (ecase type
      (:error
       (let ((text (if (< 1024 (length text)) (subseq text 0 1024) text)))
         (unless (cffi:foreign-funcall "nxgl_show_error" :int32 code :string text :string text :bool)
           (error 'messagebox-failed))))
      ((:info :warning :question :line :text :password)
       (error 'messagebox-failed))))
