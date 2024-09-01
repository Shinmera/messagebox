(defpackage #:org.shirakumo.messagebox
  (:use #:cl)
  ;; protocol.lisp
  (:export
   #:*default-backend*
   #:messagebox-failed
   #:show)
  ;; defaults.lisp
  (:export
   #:no-backend-found
   #:determine-default-backend))

(defpackage #:org.shirakumo.messagebox.win32
  (:use #:cl)
  (:export #:win32))

(defpackage #:org.shirakumo.messagebox.macos
  (:use #:cl)
  (:export #:macos))

(defpackage #:org.shirakumo.messagebox.zenity
  (:use #:cl)
  (:export #:zenity))

(defpackage #:org.shirakumo.messagebox.kdialog
  (:use #:cl)
  (:export #:kdialog))

(defpackage #:org.shirakumo.messagebox.nxgl
  (:use #:cl)
  (:export #:nxgl))
