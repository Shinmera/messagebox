(in-package #:org.shirakumo.messagebox.zenity)

(defclass zenity ()
  ((program-name :initarg :program-name :initform "zenity" :accessor program-name)))

(defmethod org.shirakumo.messagebox::show-backend ((zenity zenity) text &key title (type :info) modal &allow-other-keys)
  (multiple-value-bind (status output)
      (org.shirakumo.messagebox::run
       (program-name zenity)
       (ecase type
         (:info "--info")
         (:error "--error")
         (:warning "--warning")
         (:question "--question")
         (:line "--entry")
         (:text "--text-info")
         (:password "--password"))
       (format NIL "--text=~a" text)
       (when (eql type :text) "--editable")
       (when title (format NIL "--title=~a" title))
       (when modal "--modal"))
    (case status
      (0 (case type
           (:question :yes)
           ((:line :text :password)
            (string-right-trim '(#\Linefeed) output))
           (T :ok)))
      (1 (case type
           (:question :no)
           (T :cancel)))
      (5 (case type
           (:question :no)
           (T :cancel)))
      (T
       (error 'org.shirakumo.messagebox:messagebox-failed)))))
