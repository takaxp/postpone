;;; postpone-pre.el --- Control boot sequence by a postpone trick  -*- lexical-binding: t; -*-

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

;; `postpone-pre' provides a kicker of `postpone.el'.

;;; Code:

(defvar postpone-pre-init-time nil
  "A variable to store the duration of loading postponed packages.")

(defcustom postpone-pre-exclude '(self-insert-command
                                  save-buffers-kill-terminal
                                  exit-minibuffer)
  "A list of commands not to activate `postpone-mode'."
  :type 'sexp
  :group 'postpone)

;;;###autoload
(defun postpone-pre ()
  (interactive)
  (unless (or (memq this-command postpone-pre-exclude)
              postpone-pre-init-time)
    (message "Activating postponed packages...")
    (let ((t1 (current-time)))
      (postpone-kicker 'postpone-pre)
      (setq postpone-pre-init-time (float-time
                                    (time-subtract (current-time) t1))))
    (message "Activating postponed packages...done (%.3f seconds)"
             postpone-pre-init-time)))

(if (not (locate-library "postpone"))
    (error "postpone.el is NOT installed yet or cannot find it")
  (autoload 'postpone-kicker "postpone" nil t)
  (add-hook 'pre-command-hook #'postpone-pre))

(provide 'postpone-pre)
;;; postpone-pre.el ends here
