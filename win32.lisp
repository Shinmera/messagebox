(in-package #:org.shirakumo.messagebox)

(cffi:define-foreign-library user32
  (:windows "User32.dll"))

(cffi:defcenum result
  (:failed 0)
  (:ok 1)
  (:cancel 2)
  (:abort 3)
  (:retry 4)
  (:ignore 5)
  (:yes 6)
  (:no 7)
  (:try-again 10)
  (:continue 11)
  (:wtf 4294967295))

(cffi:defbitfield type
  (:ok #x00000000)
  (:ok-cancel #x00000001)
  (:abort-retry-ignore #x00000002)
  (:yes-no-cancel #x00000003)
  (:yes-no #x00000004)
  (:retry-cancel #x00000005)
  (:cancel-try-continue #x00000006)

  (:stop #x00000010)
  (:error #x00000010)
  (:hand #x00000010)
  (:question #x00000020)
  (:exclamation #x00000030)
  (:warning #x00000030)
  (:info #x00000040)
  (:asterisk #x00000040)

  (:button1 #x00000000)
  (:button2 #x00000100)
  (:button3 #x00000200)
  (:button4 #x00000300)

  (:application-modal #x00000000)
  (:system-modal #x00001000)
  (:task-modal #x00002000)
  
  (:default-desktop-only #x00020000)
  (:right #x00080000)
  (:set-foreground #x00010000)
  (:rtl-reading #x00100000)
  (:topmost #x00040000)
  (:service-notification #x00200000))

(cffi:defcfun (win-message-box "MessageBoxExW") result
  (parent :pointer)
  (text :pointer)
  (caption :pointer)
  (type type)
  (language-id :unsigned-short))

(define-implementation (text &key title (type :info) buttons modal &allow-other-keys)
  (unless (cffi:foreign-library-loaded-p 'user32)
    (cffi:load-foreign-library 'user32))
  (let* ((text (org.shirakumo.com-on:string->wstring text))
         (title (org.shirakumo.com-on:string->wstring (or title (string-capitalize type))))
         (result (win-message-box (cffi:null-pointer) text title
                                  (list type
                                        (or buttons
                                            (case type
                                              (:question :yes-no)
                                              (T :ok)))
                                        (if modal :application-modal :ok))
                                  0)))
    (cffi:foreign-free text)
    (cffi:foreign-free title)
    (if (or (eql :wtf result) (eql :failed result))
        (error 'messagebox-failed)
        result)))
