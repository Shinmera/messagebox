#|
 This file is a part of messagebox
 (c) 2020 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(asdf:defsystem messagebox
  :version "1.0.0"
  :license "zlib"
  :author "Nicolas Hafner <shinmera@tymoon.eu>"
  :maintainer "Nicolas Hafner <shinmera@tymoon.eu>"
  :description "A library to show a native message box dialog."
  :homepage "https://shinmera.github.io/messagebox/"
  :bug-tracker "https://github.com/shinmera/messagebox/issues"
  :source-control (:git "https://github.com/shinmera/messagebox.git")
  :serial T
  :defsystem-depends-on (:trivial-features)
  :components ((:file "package")
               (:file "protocol")
               (:file "zenity" :if-feature :linux)
               (:file "macos" :if-feature :darwin)
               (:file "win32" :if-feature :windows)
               (:file "documentation"))
  :depends-on ((:feature :darwin :cffi)
               (:feature :darwin :trivial-main-thread)
               (:feature :darwin :float-features)
               (:feature :windows :com-on)
               (:feature :linux :uiop)
               :documentation-utils))
