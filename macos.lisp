(in-package #:org.shirakumo.messagebox.macos)

(cffi:define-foreign-library cocoa
  (t (:framework "Cocoa")))

(cffi:define-foreign-library appkit
  (t (:framework "AppKit")))

(cffi:define-foreign-library foundation
  (t (:framework "Foundation")))

(cffi:defctype id :pointer)
(cffi:defctype oclass :pointer)
(cffi:defctype sel :pointer)

(cffi:defcfun (get-class "objc_getClass") oclass
  (name :string))

(cffi:defcfun (register-name "sel_registerName") sel
  (name :string))

(cffi:defcfun (set-uncaught-exception-handler "NSSetUncaughtExceptionHandler") :void
  (handler :pointer))

(cffi:defcallback exception-handler :void ((object id) (pointer :pointer))
  (error 'messagebox-failed))

(defmacro objc-call (self method &rest args)
  (when (stringp self)
    (setf self `(get-class ,self)))
  (when (evenp (length args))
    (setf args (append args '(id))))
  (let* ((struct (gensym "STRUCT"))
         (retval (car (last args)))
         (base-args (list* 'id self
                           'sel `(register-name ,method)
                           (loop for (type name) on (butlast args) by #'cddr
                                 collect `,type collect name))))
    (cond ((and (listp retval) (eq :struct (first retval)))
           `(cffi:with-foreign-object (,struct ',retval)
              (cffi:foreign-funcall "objc_msgSend_stret" :pointer ,struct ,@base-args :void)
              (cffi:mem-ref ,struct ',retval)))
          ((find retval '(:double :float))
           `(cffi:foreign-funcall "objc_msgSend_fpret" ,@base-args ,retval))
          (T
           `(cffi:foreign-funcall "objc_msgSend" ,@base-args ,retval)))))

(defun free-instance (id)
  (objc-call id "dealloc" :void))

(defmacro with-object ((var init) &body body)
  `(let ((,var ,init))
     (unwind-protect
          (progn ,@body)
       (free-instance ,var))))

(cffi:defcenum NSApplicationActivationPolicy
  (:regular 0)
  (:accessory 1)
  (:prohibited 2))

(cffi:defcenum NSModalResponse
  (:cancel 0)
  (:ok 1)
  (:stop -1000)
  (:abort -1001)
  (:continue -1002)
  (:first 1000)
  (:second 1001)
  (:third 1002))

(cffi:defcenum NSAlertStyle
  (:warning 0)
  (:info 1)
  (:error 2))

(cffi:defcenum NSBackingStoreType
  (:buffered 2))

(cffi:defcvar (nsapp "NSApp") :pointer)

(cffi:defcenum (NSEventMask :uint64)
  (:any #.(1- (ash 1 64))))

(cffi:defcvar (nsdefaultrunloopmode "NSDefaultRunLoopMode") :pointer)

(defun process-event (app)
  (let ((event (objc-call app "nextEventMatchingMask:untilDate:inMode:dequeue:"
                          NSEventMask :any
                          :pointer (objc-call "NSDate" "distantPast")
                          :pointer nsdefaultrunloopmode
                          :bool T)))
    (unless (cffi:null-pointer-p event)
      (objc-call app "sendEvent:" :pointer event))))

(defmacro with-body-in-main-thread (args &body body)
  #+darwin `(trivial-main-thread:with-body-in-main-thread ,args ,@body)
  #-darwin `(progn ,@body))

(org.shirakumo.messagebox::define-implementation macos (text &key title (type :info) &allow-other-keys)
  (unless (cffi:foreign-library-loaded-p 'cocoa)
    (cffi:load-foreign-library 'foundation)
    (cffi:load-foreign-library 'appkit)
    (cffi:load-foreign-library 'cocoa))
  (with-body-in-main-thread (:blocking T)
    (float-features:with-float-traps-masked T
      (let ((strings ()))
        (unwind-protect
             (flet ((nsstring (string)
                      (car (push (objc-call "NSString" "stringWithUTF8String:" :string string) strings))))
               (set-uncaught-exception-handler (cffi:callback exception-handler))
               (let ((app (objc-call "NSApplication" "sharedApplication")))
                 (objc-call app "setActivationPolicy:" NSApplicationActivationPolicy :accessory :bool)
                 (with-object (window (objc-call (objc-call "NSAlert" "alloc") "init"))
                   (objc-call window "setInformativeText:" :pointer (nsstring text))
                   (objc-call window "setAlertStyle:" NSAlertStyle (case type (:question :info) (T type)))
                   (when title
                     (objc-call window "setMessageText:" :pointer (nsstring title)))
                   (case type
                     (:question
                      (objc-call window "addButtonWithTitle:" :pointer (nsstring "Yes"))
                      (objc-call window "addButtonWithTitle:" :pointer (nsstring "No")))
                     (T
                      (objc-call window "addButtonWithTitle:" :pointer (nsstring "Ok"))))
                   (ecase (unwind-protect (objc-call window "runModal" NSModalResponse)
                            ;; This is necessary to get the window to close.
                            (loop while (process-event app)))
                     ((:cancel :stop :abort :second)
                      (case type
                        (:question :no)
                        (T :cancel)))
                     ((:ok :first :continue)
                      (case type
                        (:question :yes)
                        (T :ok)))))))
          (mapc #'free-instance strings))))))
