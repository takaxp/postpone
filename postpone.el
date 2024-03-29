;;; postpone.el --- Control boot sequence by a postpone trick  -*- lexical-binding: t; -*-

;; Copyright (C) 2017-2022 Takaaki ISHIKAWA

;; Author: Takaaki ISHIKAWA  <takaxp at ieee dot org>
;; Keywords: tools, convenience
;; Version: 0.9.3
;; URL: https://github.com/takaxp/postpone
;; Package-Requires: ((emacs "24.4"))

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

;; This package provides a simple loading mechanism of packages with some delay.
;; The normal function `resuire' loads packages when it is evaluated.
;; But if you introduce this minor mode, the associated packages with this mode
;; will be loaded just when you type something for the first time after booting
;; your Emacs.  So the loading of associated packages is postponed until you
;; actually start to use Emacs.  You need the following two steps.
;;
;; 1. Just require `postpone-pre.el' in init.el. No need to load `postpone.el'.
;;
;; (when (require 'postpone-pre nil t) ;; do NOT specify posrpone.el here
;;   (setq postpone-pre-exclude '(self-insert-command
;;                                newline
;;                                delete-char
;;                                save-buffer
;;                                save-buffers-kill-terminal
;;                                electric-newline-and-maybe-indent
;;                                exit-minibuffer)))
;;
;; 2. Bind any commands to `postpone-mode' by `with-eval-after-load'.
;;
;; (with-eval-after-load "postpone"
;;   ;; Add any settings you want to load with delay.
;;   ;; Those settings will be activated when you initially type something.
;;   )
;;
;; or
;;
;; add package to `postpone-package-list'.  The packages in the list will be
;; required when `postpone-mode' is activated.
;; e.g.
;; (with-eval-after-load "postpone"
;;   (add-to-list 'postpone-package-list 'org))
;;

;;; Code:
(require 'postpone-pre)

(defcustom postpone-package-list nil
  "A list for loading packages when function `postpone-mode' is activated."
  :type 'sexp
  :group 'postpone)

(defcustom postpone-verbose t
  "Show loading messages of required packages."
  :type 'boolean
  :group 'postpone)

(defvar postpone--lock nil
  "A variable to lock this mode.")

(defun postpone--lock ()
  "Lock this mode."
  (setq postpone-mode-hook nil)
  (setq postpone--lock t)
  (postpone-mode -1))

(defun postpone--setup ()
  "Setup and disable this minor-mode in a moment."
  (mapc #'(lambda (x)
            (if postpone-verbose
                (message "--- \"%s\" %s" x
                         (if (require x nil t)
                             "loaded." "not exist."))
              (require x nil t)))
        postpone-package-list)
  (postpone--lock))

(defun postpone-message (arg)
  "Show loading message with ARG."
  (when postpone-verbose
    (message (format "Loading %s...done" arg))))

(defun postpone-kicker (kicker)
  "Load and execute functions just one time.
KICKER shall be a command."
  (postpone-mode 1)
  (when (commandp kicker)
    (remove-hook 'pre-command-hook kicker)))

;;;###autoload
(defun postpone-init-time ()
  "Print initialization time of postponed packages."
  (interactive)
  (if postpone-pre-init-time
      (message "%.3f seconds" postpone-pre-init-time)
    (user-error "The value is NOT initialized.")))

;;;###autoload
(define-minor-mode postpone-mode
  "Call functions at your first action just one time."
  :init-value nil
  :lighter nil
  :keymap nil
  (when (and (not postpone--lock)
             postpone-mode)
    (postpone--setup)))

(provide 'postpone)
;;; postpone.el ends here
