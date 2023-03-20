;; Copyright (C) 2010-2014, 2016-2017, 2023 Free Software Foundation, Inc

;; Author: Rocky Bernstein <rocky@gnu.org>

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

(require 'load-relative)

(require 'realgud)
(require-relative-list '("core" "track-mode") "realgud--trepan-xpy-")


;; This is needed, or at least the docstring part of it is needed to
;; get the customization menu to work in Emacs 25.
(defgroup realgud--trepan-xpy nil
  "The realgud interface to the Python debugger, trepan-trepan-xpy"
  :group 'realgud
  :group 'python
  :version "25.1")

(declare-function trepan-xpy-query-cmdline  'realgud--trepan-xpy-core)
(declare-function trepan-xpy-parse-cmd-args 'realgud--trepan-xpy-core)
(declare-function realgud:run-debugger    'realgud:run)
(declare-function realgud:run-process     'realgud:core)
(declare-function realgud:flatten         'realgud-utils)

;; -------------------------------------------------------------------
;; User-definable variables
;;

(defcustom realgud:trepan-xpy-command-name
  ;;"trepan-xpy --emacs 3"
  "trepan-xpy"
  "File name for executing the Python debugger and command options.
This should be an executable on your path, or an absolute file name."
  :type 'string
  :group 'realgud-trepan-xpy)

(declare-function trepan-xpy-track-mode (bool))

;; -------------------------------------------------------------------
;; The end.
;;

;;;###autoload
(defun realgud:trepan-xpy (&optional opt-cmd-line no-reset)
  "Invoke the trepan-xpy Python debugger and start the Emacs user interface.

String OPT-CMD-LINE is treated like a shell string; arguments are
tokenized by `split-string-and-unquote'. The tokenized string is
parsed by `trepan-xpy-parse-cmd-args' and path elements found by that
are expanded using `realgud:expand-file-name-if-exists'.

Normally, command buffers are reused when the same debugger is
reinvoked inside a command buffer with a similar command. If we
discover that the buffer has prior command-buffer information and
NO-RESET is nil, then that information which may point into other
buffers and source buffers which may contain marks and fringe or
marginal icons is reset. See `loc-changes-clear-buffer' to clear
fringe and marginal icons.
"
  (interactive)
  (realgud:run-debugger "trepan-xpy"
			'trepan-xpy-query-cmdline
			'trepan-xpy-parse-cmd-args
			'realgud:trepan-xpy-minibuffer-history
			opt-cmd-line no-reset)
  )

;;;###autoload
(defalias 'trepan-xpy 'realgud:trepan-xpy)

;;;###autoload
(defun realgud:trepan-xpy-delayed ()
  "This is like `trepan-xpy', but assumes inside the program to be debugged, you
have a call to the debugger somewhere, e.g. 'from trepan.api import debug; debug()'.
Therefore we invoke python rather than the debugger initially.
"
  (interactive)
  (let* ((initial-debugger python-shell-interpreter)
	 (actual-debugger "trepan-xpy")
	 (cmd-str (trepan-xpy-query-cmdline initial-debugger))
	 (cmd-args (split-string-and-unquote cmd-str))
	 ;; XXX: python gets registered as the interpreter rather than
	 ;; a debugger, and the debugger position (nth 1) is missing:
	 ;; the script-args takes its place.
	 (parsed-args (trepan-xpy-parse-cmd-args cmd-args))
	 (script-args (nth 1 parsed-args))
	 (script-name (car script-args))
	 (parsed-cmd-args
	  (cl-remove-if 'nil (realgud:flatten parsed-args))))
    (realgud:run-process actual-debugger script-name parsed-cmd-args
			 'realgud:trepan-xpy-deferred-minibuffer-history)))

(realgud-deferred-invoke-setup "trepan-xpy")

(provide-me "realgud-")
