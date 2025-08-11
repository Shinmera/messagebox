(asdf:defsystem messagebox
  :version "1.0.0"
  :license "zlib"
  :author "Yukari Hafner <shinmera@tymoon.eu>"
  :maintainer "Yukari Hafner <shinmera@tymoon.eu>"
  :description "A library to show a native message box dialog."
  :homepage "https://shinmera.com/docs/messagebox/"
  :bug-tracker "https://shinmera.com/project/messagebox/issues"
  :source-control (:git "https://shinmera.com/project/messagebox.git")
  :serial T
  :defsystem-depends-on (:trivial-features)
  :components ((:file "package")
               (:file "protocol")
               (:file "zenity" :if-feature :linux)
               (:file "kdialog" :if-feature :linux)
               (:file "macos" :if-feature :darwin)
               (:file "win32" :if-feature :windows)
               (:file "nxgl" :if-feature :nx)
               (:file "defaults")
               (:file "documentation"))
  :depends-on ((:feature :darwin :cffi)
               (:feature :darwin :trivial-main-thread)
               (:feature :darwin :float-features)
               (:feature :windows :com-on)
               (:feature :nx :cffi)
               :uiop
               :documentation-utils))
