;; Copyright (C) 2010-2019 Free Software Foundation, Inc

;; Author: Rocky Bernstein <rocky@gnu.org>

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;; trepan-xpy: Python 3.2 and beyond

(eval-when-compile (require 'cl-lib))   ;For setf.

(require 'load-relative)
(require 'realgud)

(defvar realgud-pat-hash)
(declare-function make-realgud-loc-pat 'realgud-regexp)

(defvar realgud:trepan-xpy-pat-hash (make-hash-table :test 'equal)
  "Hash key is the what kind of pattern we want to match:
backtrace, prompt, etc.  The values of a hash entry is a
realgud-loc-pat struct")

(declare-function make-realgud-loc 'realgud-loc)

;; realgud-loc-pat that describes a trepan-xpy location generally shown
;; before a command prompt.
;;
;; For example:
;;   (/usr/bin/zonetab2pot.py:15 @3): <module>
;;   (/usr/bin/zonetab2pot.py:15 remapped <string>): <module>
;; or MS Windows:
;;   (c:\\mydirectory\\gcd.py:10): <module>
(setf (gethash "loc" realgud:trepan-xpy-pat-hash)
      realgud:python-trepan-loc-pat)

;; An initial list of regexps that don't generally have files
;; associated with them and therefore we should not try to find file
;; associations for them.  This list is used to seed a field of the
;; same name in the cmd-info structure inside a command buffer. A user
;; may add additional files to the command-buffer's re-ignore-list.
(setf (gethash "ignore-re-file-list" realgud:trepan-xpy-pat-hash)
      (list realgud-python-ignore-file-re))

;; realgud-loc-pat that describes a trepan-xpy prompt.
;; Note: the prompt in nested debugging
;; For example:
;; (trepan3)
;; ((trepan-xpy))
(setf (gethash "prompt" realgud:trepan-xpy-pat-hash)
      (make-realgud-loc-pat
       :regexp   "^(+trepan-xpy+) "
       ))

;; realgud-loc-pat that describes a trepan-xpy backtrace line.
;; For example:
;; ->0 get_distribution(dist='trepan==0.3.9')
;;     called from file '/python2.7/dist-packages/pkg_res.py' at line 341
;; ##1 load_entry_point(dist='tr=0.3.9', group='console_scripts', name='tr')
;;     called from file '/python2.7/dist-packages/pkg_res.py' at line 351
;; ##2 <module> exec()

(setf (gethash "debugger-backtrace" realgud:trepan-xpy-pat-hash)
      realgud:python-trepan-backtrace-pat)

;;  realgud-loc-pat that describes a line a Python "info break" line.
;; For example:
;; 1   breakpoint    keep y   at /usr/local/bin/trepan-xpy:7
(setf (gethash "debugger-breakpoint" realgud:trepan-xpy-pat-hash)
      realgud-python-breakpoint-pat)

;;  realgud-loc-pat that describes a Python backtrace line.
(setf (gethash "lang-backtrace" realgud:trepan-xpy-pat-hash)
      realgud-python-backtrace-loc-pat)

;;  realgud-loc-pat that describes location in a pytest error
(setf (gethash "pytest-error" realgud:trepan-xpy-pat-hash)
      realgud-pytest-error-loc-pat)

;;  realgud-loc-pat that describes location in a flake8 message
(setf (gethash "flake8-msg" realgud:trepan-xpy-pat-hash)
      realgud-flake8-msg-loc-pat)

;;  realgud-loc-pat that describes a "breakpoint set" line
(setf (gethash "brkpt-set" realgud:trepan-xpy-pat-hash)
      realgud:python-trepan-brkpt-set-pat)

;;  realgud-loc-pat that describes a "delete breakpoint" line
(setf (gethash "brkpt-del" realgud:trepan-xpy-pat-hash)
      realgud:python-trepan-brkpt-del-pat)

;; realgud-loc-pat that describes a debugger "disable" (breakpoint) response.
;; For example:
;;   Breakpoint 4 disabled.
(setf (gethash "brkpt-disable" realgud:trepan-xpy-pat-hash)
      realgud:python-trepan-brkpt-disable-pat)

;; realgud-loc-pat that describes a debugger "enable" (breakpoint) response.
;; For example:
;;   Breakpoint 4 enabled.
(setf (gethash "brkpt-enable" realgud:trepan-xpy-pat-hash)
      realgud:python-trepan-brkpt-enable-pat)

;; realgud-loc-pat for a termination message.
(setf (gethash "termination" realgud:trepan-xpy-pat-hash)
       "^trepan-xpy: That's all, folks...\n")

(setf (gethash "font-lock-keywords" realgud:trepan-xpy-pat-hash)
      realgud:python-debugger-font-lock-keywords)

(setf (gethash "font-lock-breakpoint-keywords" realgud:trepan-xpy-pat-hash)
      realgud:python-debugger-font-lock-breakpoint-keywords)

(setf (gethash "trepan-xpy" realgud-pat-hash) realgud:trepan-xpy-pat-hash)

(defvar realgud:trepan-xpy-command-hash (make-hash-table :test 'equal)
  "Hash key is command name like 'shell' and the value is
  the trepan-xpy command to use, like 'python'")

(setf (gethash "eval"             realgud:trepan-xpy-command-hash) "eval %s")
(setf (gethash "info-breakpoints" realgud:trepan-xpy-command-hash) "info break")
(setf (gethash "pprint"           realgud:trepan-xpy-command-hash) "pp %s")
(setf (gethash "shell"            realgud:trepan-xpy-command-hash) "python")
(setf (gethash "until"            realgud:trepan-xpy-command-hash) "continue %l")

;; If your version of trepan-xpy doesn't support "quit!",
;; get a more recent version of trepan-xpy
(setf (gethash "quit" realgud:trepan-xpy-command-hash) "quit!")

(setf (gethash "trepan-xpy" realgud-command-hash) realgud:trepan-xpy-command-hash)

(provide-me "realgud--trepan-xpy-")
