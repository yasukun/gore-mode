;;; gore-mode.el --- gore mode           -*- lexical-binding: t; -*-

;; Copyright (C) 2016  yasukun

;; Author: yasukun <https://twitter.com/sukezo>
;; Keywords: processes

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

;;; Commentary:

;;

;;; Code:

(require 'comint)
(require 'easymenu)

(defconst gore-mode-version "0.0.1"
  "The version of `gore-mode'.")

(defcustom gore-buffer "*GORE*"
  "The name of the Stack gore repl buffer"
  :type 'string
  :group 'gore)

(defcustom gore-mode-hook nil
  "Hook called by `gore-mode'."
  :type 'hook
  :group 'gore)

(defcustom stack-command "gore"
  "The gore command used for build go."
  :type 'string
  :group 'gore)

(defcustom gore-args '("gore")
  "The argument to pass to `gore' to start a gore."
  :type 'list
  :group 'gore)

(defcustom gore-reload-command ":reload"
  "The argument to pass to `gore' to reload a gore."
  :type 'string
  :group 'gore)

(defvar gore-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-l") 'gore-send-line)
    (define-key map (kbd "C-c C-r") 'gore-send-region)
    (define-key map (kbd "C-c C-b") 'gore-revert-buffer)
    (define-key map (kbd "C-c C-g") 'gore-repl)
    ;; (define-key map (kbd "C-c C-s") 'gore-send-commands)
    map)
  "Keymap for stack gore major mode.")

(defun gore-repl ()
  "Launch a go REPL using `go-command' as an inferior mode."
  (interactive)

  (unless (comint-check-proc gore-buffer)
    (set-buffer
     (apply 'make-comint "GORE"
	    stack-command
	    nil
	    gore-args)))
  (pop-to-buffer gore-buffer))

(defun gore-get-repl-proc ()
  (unless (comint-check-proc gore-buffer)
    (gore-repl))
  (get-buffer-process gore-buffer))

(defun gore-send-line ()
  (interactive)
  (gore-send-region (line-beginning-position) (line-end-position)))

(defun gore-send-region (start end)
  "Send the current region to the inferior gore process."
  (interactive "r")
  (deactivate-mark t)
  (let* ((string (buffer-substring-no-properties start end))
	 (proc (gore-get-repl-proc))
	 (multiline-escaped-string
	  (replace-regexp-in-string "\n" "\uFF00" string)))
    (comint-simple-send proc multiline-escaped-string)))

(defun gore-revert-buffer ()
  (interactive)
  (deactivate-mark t)
  (save-buffer)
  (let* ((proc (gore-get-repl-proc)))
    (comint-simple-send proc gore-reload-command)))

(defun gore-send-commands (cmd)
  "Send the command to the inferior gore process."
  (interactive "s:")
  (deactivate-mark t)
  (let* ((proc (gore-get-repl-proc)))
    (comint-simple-send proc (format ":%s" cmd))))

(defun gore-version ()
  "Show the `gore-mode' version in the echo area."
  (interactive)
  (message (conncat "gore-mode version " gore-mode-version)))

;;
;; Menubar
;;

(easy-menu-define gore-mode-menu gore-mode-map
  "Menu for stack gore mode"
  '("GORE"
    ["REPL" gore-repl]
    "---"
    ["Version" gore-version]))

;;
;; Define Major Mode
;;

;;;###autoload
(define-derived-mode gore-mode go-mode "GORE"
  "Major mode for editing go.")

(provide 'gore-mode)

;;
;; On Load
;;

;; Run gore-mode for files ending in .go.
;;;###autoload
(add-to-list 'auto-mode-alist '("\\.go\\'" . gore-mode))

;;; gore-mode.el ends here
