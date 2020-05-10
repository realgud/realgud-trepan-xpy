;; Copyright (C) 2015-2016, 2020 Free Software Foundation, Inc

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
;; Python "trepan-xpy" Debugger tracking a comint buffer.

(require 'realgud)
(require 'load-relative)
(require-relative-list '("core" "init") "realgud--trepan-xpy-")

(declare-function realgud-track-mode 'realgud-track-mode)
(declare-function realgud-track-mode-hook 'realgud-track-mode)
(declare-function realgud-track-mode-setup 'realgud-track-mode)
(declare-function realgud:track-set-debugger 'realgud-track-mode)
(declare-function realgud-python-populate-command-keys 'realgud-lang-python)

(realgud-track-mode-vars "trepan-xpy")

(declare-function realgud-track-mode(bool))

(realgud-python-populate-command-keys trepan-xpy-track-mode-map)

(defun trepan-xpy-track-mode-hook()
  (if trepan-xpy-track-mode
      (progn
	(use-local-map trepan-xpy-track-mode-map)
	(message "using trepan-xpy mode map")
	)
    (message "trepan-xpy track-mode-hook disable called")
    )
)

(define-minor-mode trepan-xpy-track-mode
  "Minor mode for tracking trepan-xpy source locations inside a process shell via realgud. trepan-xpy is a Python debugger. See URL `http://code.google.com/p/python3-trepan/'.

If called interactively with no prefix argument, the mode is toggled. A prefix argument, captured as ARG, enables the mode if the argument is positive, and disables it otherwise.

\\{trepan-xpy-track-mode-map}
"
  :init-value nil
  ;; :lighter " trepan-xpy"   ;; mode-line indicator from realgud-track is sufficient.
  ;; The minor mode bindings.
  :global nil
  :group 'realgud:trepan-xpy
  :keymap trepan-xpy-track-mode-map
  (realgud:track-set-debugger "trepan-xpy")
  (if trepan-xpy-track-mode
      (progn
	(realgud-track-mode-setup 't)
	(trepan-xpy-track-mode-hook))
    (progn
      (setq realgud-track-mode nil)
      ))
)

(define-key trepan-xpy-short-key-mode-map "T" 'realgud:cmd-backtrace)

(provide-me "realgud--trepan-xpy-")
