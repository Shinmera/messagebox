(in-package #:org.shirakumo.messagebox.kdialog)

(org.shirakumo.messagebox::define-implementation kdialog (text &key title (type :info) (default "") &allow-other-keys)
  (multiple-value-bind (status output)
      (org.shirakumo.messagebox::run
       "kdialog"
       (ecase type
         (:info "--msgbox")
         (:error "--error")
         (:warning "--sorry")
         (:question "--yesno")
         (:line "--inputbox")
         (:password "--password"))
       text
       (when (eql type :line) default)
       (when title "--title")
       title)
    (case status
      (0 (case type
           (:question :yes)
           ((:line :password)
            (string-right-trim '(#\Linefeed) output))
           (T :ok)))
      (1 (case type
           (:question :no)
           (T :cancel)))
      (2 (case type
           (:question :no)
           (T :cancel)))
      (T
       (error 'org.shirakumo.messagebox:messagebox-failed)))))
