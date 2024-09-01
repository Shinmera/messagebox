(in-package #:org.shirakumo.messagebox)

(docs:define-docs
  (type messagebox-failed
    "Error signalled when the messagebox fails to be shown.

See SHOW")

  (type no-backend-found
    "Error signalled if no suitable backend can be found at all.

See MESSAGEBOX-FAILED")

  (function show
    "Show a message box dialog.

TEXT  --- The primary text to display.
TITLE --- The title to show on the message box window.
TYPE  --- What kind of message to display. Should be one of
           :info
           :error
           :warning
           :question
MODAL --- Whether the dialog should be modal to the application
          May not make a difference on some systems.

If the dialog fails to show, an error of type MESSAGEBOX-FAILED is
signalled.

Depending on the backend further options may be supported.

Do note that some systems might not show long text well. You
should thus avoid trying to do things such as displaying stack
traces using this function. It is instead recommended to write
relevant debug information to a file and refer to this file in the
displayed message.

Returns :OK, :YES, :NO, or :CANCEL. :YES and :NO can only be
returned if the TYPE is :QUESTION.

See MESSAGEBOX-FAILED"))
