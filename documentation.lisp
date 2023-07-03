(in-package #:org.shirakumo.messagebox)

(docs:define-docs
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

If the backend fails or no suitable backend is present, the
dialog is shown on *ERROR-OUTPUT*.

Depending on the backend further options may be supported.

Do note that some systems might not show long text well. You
should thus avoid trying to do things such as displaying stack
traces using this function. It is instead recommended to write
relevant debug information to a file and refer to this file in the
displayed message.

This function should not error.

Returns :OK, :YES, :NO, or :CANCEL. :YES and :NO can only be
returned if the TYPE is :QUESTION."))
