#|
 This file is a part of messagebox
 (c) 2020 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.messagebox)

(defun zenity (&rest args)
  (handler-case
      (multiple-value-bind (output error status)
          (uiop:run-program (list* "zenity" (remove NIL args))
                            :output :string
                            :ignore-error-status T
                            :external-format :utf-8)
        (values status output))
    (error ()
      (error 'messagebox-failed))))

;; FIXME: figure out whether display is present or not (both X11 and Wayland)
(define-implementation (text &key title (type :info) modal &allow-other-keys)
    (multiple-value-bind (status output)
        (zenity (ecase type
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
         (error 'messagebox-failed)))))
