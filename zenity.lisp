#|
 This file is a part of messagebox
 (c) 2020 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.messagebox)

(defun zenity (&rest args)
  (handler-case
      (nth-value 2 (uiop:run-program (list* "zenity" (remove NIL args))
                                     :ignore-error-status T :external-format :utf-8))
    (error ()
      (error 'messagebox-failed))))

;; FIXME: figure out whether display is present or not (both X11 and Wayland)
(define-implementation (text &key title (type :info) modal &allow-other-keys)
  (ecase (zenity (ecase type
                   (:info "--info")
                   (:error "--error")
                   (:warning "--warning")
                   (:question "--question"))
                 (format NIL "--text=~a" text)
                 (when title (format NIL "--title=~a" title))
                 (when modal "--modal"))
    (0 (case type
         (:question :yes)
         (T :ok)))
    (1 (case type
         (:question :no)
         (T :cancel)))))
