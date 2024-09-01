(in-package #:org.shirakumo.messagebox.nxgl)

(org.shirakumo.messagebox::define-implementation nxgl (text &key (type :info) (code 0) &allow-other-keys)
    (declare (ignore modal title))
    (case type
      (:error
       (let ((text (if (< 1024 (length text)) (subseq text 0 1024) text)))
         (unless (cffi:foreign-funcall "nxgl_show_error" :int32 code :string text :string text :bool)
           (error 'messagebox-failed))))
      (T
       (error 'org.shirakumo.messagebox:messagebox-failed))))
