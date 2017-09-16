;;; postpone.el --- Call functions just one time at your first action.  -*- lexical-binding: t; -*-

;; Copyright (C) 2017  Takaaki ISHIKAWA

;; Author: Takaaki ISHIKAWA  <takaxp@ieee.org>
;; Keywords: tools, convenience
;; Version: 0.9
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

;; Put the following code into your init.el to load specific packages and code
;; when you input something or call a function for the first time.
;;
;; (defun onetime-kicker ()
;;   "Load and execute functions just one time."
;;   (when (require 'postpone nil t)
;;     (postpone-mode 1))
;;   (remove-hook 'pre-command-hook #'onetime-kicker))
;; (add-hook 'pre-command-hook #'onetime-kicker)
;;

;;; Code:

(defcustom postpone-package-list nil
  "A list for loading packages when `postpone-mode' is activated."
  :type 'sexp
  :group 'postpone)

(defcustom postpone-verbose nil
  "Show messages"
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
