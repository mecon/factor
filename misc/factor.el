;; Eduardo Cavazos - wayo.cavazos@gmail.com

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Add these lines to your .emacs file:

;; (load-file "/scratch/repos/Factor/misc/factor.el")
;; (setq factor-binary "/scratch/repos/Factor/factor")
;; (setq factor-image "/scratch/repos/Factor/factor.image")

;; Of course, you'll have to edit the directory paths for your system
;; accordingly.

;; That's all you have to do to "install" factor.el on your
;; system. Whenever you edit a factor file, Emacs will know to switch
;; to Factor mode.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; M-x run-factor === Start a Factor listener inside Emacs

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; BUG: A double quote character on a commented line will break the
;; syntax highlighting for that line.

(defgroup factor nil
  "Factor mode"
  :group 'languages)

(defvar factor-mode-syntax-table nil
  "Syntax table used while in Factor mode.")

(if factor-mode-syntax-table
    ()
  (let ((i 0))
    (setq factor-mode-syntax-table (make-syntax-table))

    ;; Default is atom-constituent
    (while (< i 256)
      (modify-syntax-entry i "_   " factor-mode-syntax-table)
      (setq i (1+ i)))

    ;; Word components.
    (setq i ?0)
    (while (<= i ?9)
      (modify-syntax-entry i "w   " factor-mode-syntax-table)
      (setq i (1+ i)))
    (setq i ?A)
    (while (<= i ?Z)
      (modify-syntax-entry i "w   " factor-mode-syntax-table)
      (setq i (1+ i)))
    (setq i ?a)
    (while (<= i ?z)
      (modify-syntax-entry i "w   " factor-mode-syntax-table)
      (setq i (1+ i)))

    ;; Whitespace
    (modify-syntax-entry ?\t " " factor-mode-syntax-table)
    (modify-syntax-entry ?\n ">" factor-mode-syntax-table)
    (modify-syntax-entry ?\f " " factor-mode-syntax-table)
    (modify-syntax-entry ?\r " " factor-mode-syntax-table)
    (modify-syntax-entry ?  " " factor-mode-syntax-table)

    (modify-syntax-entry ?\[ "(]  " factor-mode-syntax-table)
    (modify-syntax-entry ?\] ")[  " factor-mode-syntax-table)
    (modify-syntax-entry ?{ "(}  " factor-mode-syntax-table)
    (modify-syntax-entry ?} "){  " factor-mode-syntax-table)

    (modify-syntax-entry ?\( "()" factor-mode-syntax-table)
    (modify-syntax-entry ?\) ")(" factor-mode-syntax-table)
    (modify-syntax-entry ?\" "\"    " factor-mode-syntax-table)))

(defvar factor-mode-map (make-sparse-keymap))

(defcustom factor-mode-hook nil
  "Hook run when entering Factor mode."
  :type 'hook
  :group 'factor)

(defconst factor-font-lock-keywords
  '(("#!.*$" . font-lock-comment-face)
    ("!( .* )" . font-lock-comment-face)
    ("^!.*$" . font-lock-comment-face)
    (" !.*$" . font-lock-comment-face)
    ("( .* )" . font-lock-comment-face)
    "MAIN:"
    "IN:" "USING:" "TUPLE:" "^C:" "^M:"
    "METHOD:"
    "USE:" "REQUIRE:" "PROVIDE:"
    "REQUIRES:"
    "GENERIC:" "GENERIC#" "SYMBOL:" "PREDICATE:" "VAR:" "VARS:"
    "C-STRUCT:"
    "C-UNION:" "<PRIVATE" "PRIVATE>" "MACRO:" "MACRO::" "DEFER:" "TYPEDEF:"))

(defun factor-mode ()
  "A mode for editing programs written in the Factor programming language."
  (interactive)
  (kill-all-local-variables)
  (use-local-map factor-mode-map)
  (setq major-mode 'factor-mode)
  (setq mode-name "Factor")
  (make-local-variable 'comment-start)
  (setq comment-start "! ")
  (make-local-variable 'font-lock-defaults)
  (setq font-lock-defaults
	'(factor-font-lock-keywords nil nil nil nil))
  (set-syntax-table factor-mode-syntax-table)
  (run-hooks 'factor-mode-hook))

(add-to-list 'auto-mode-alist '("\\.factor\\'" . factor-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'comint)

(defvar factor-binary "~/factor/factor")
(defvar factor-image "~/factor/factor.image")

(defun factor-telnet-to-port (port)
  (interactive "nPort: ")
  (switch-to-buffer
   (make-comint-in-buffer "factor-telnet" nil (cons "localhost" port))))

(defun factor-telnet ()
  (interactive)
  (factor-telnet-to-port 9000))

(defun factor-telnet-factory ()
  (interactive)
  (factor-telnet-to-port 9010))

(defun factor-run-file ()
  (interactive)
  (comint-send-string "*factor*" (format "\"%s\"" (buffer-file-name)))
  (comint-send-string "*factor*" " run-file\n"))

;; (defun factor-send-region (start end)
;;   (interactive "r")
;;   (comint-send-region "*factor*" start end)
;;   (comint-send-string "*factor*" "\n"))

(defun factor-send-string (str)
  (let ((n (length (split-string str "\n"))))
    (save-excursion
      (set-buffer "*factor*")
      (goto-char (point-max))
      (if (> n 1) (newline))
      (insert str)
      (comint-send-input))))

(defun factor-send-region (start end)
  (interactive "r")
  (let ((str (buffer-substring start end))
        (n   (count-lines      start end)))
    (save-excursion
      (set-buffer "*factor*")
      (goto-char (point-max))
      (if (> n 1) (newline))
      (insert str)
      (comint-send-input))))

(defun factor-send-definition ()
  (interactive)
  (factor-send-region (search-backward ":")
                      (search-forward  ";")))

(defun factor-see ()
  (interactive)
  (comint-send-string "*factor*" "\\ ")
  (comint-send-string "*factor*" (thing-at-point 'sexp))
  (comint-send-string "*factor*" " see\n"))

(defun factor-help ()
  (interactive)
  (comint-send-string "*factor*" "\\ ")
  (comint-send-string "*factor*" (thing-at-point 'sexp))
  (comint-send-string "*factor*" " help\n"))

(defun factor-edit ()
  (interactive)
  (comint-send-string "*factor*" "\\ ")
  (comint-send-string "*factor*" (thing-at-point 'sexp))
  (comint-send-string "*factor*" " edit\n"))

(defun factor-clear ()
  (interactive)
  (factor-send-string "clear"))

(defun factor-comment-line ()
  (interactive)
  (beginning-of-line)
  (insert "! "))

(define-key factor-mode-map "\C-c\C-f" 'factor-run-file)
(define-key factor-mode-map "\C-c\C-r" 'factor-send-region)
(define-key factor-mode-map "\C-c\C-d" 'factor-send-definition)
(define-key factor-mode-map "\C-c\C-s" 'factor-see)
(define-key factor-mode-map "\C-ce"    'factor-edit)
(define-key factor-mode-map "\C-c\C-h" 'factor-help)
(define-key factor-mode-map "\C-cc"    'comment-region)
(define-key factor-mode-map [return]   'newline-and-indent)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; factor-listener-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-derived-mode factor-listener-mode comint-mode "Factor Listener")

(define-key factor-listener-mode-map [f8] 'factor-refresh-all)

(defun run-factor ()
  (interactive)
  (switch-to-buffer
   (make-comint-in-buffer "factor" nil (expand-file-name factor-binary) nil
			  (concat "-i=" (expand-file-name factor-image))
			  "-run=listener"))
  (factor-listener-mode))

(defun factor-refresh-all ()
  (interactive)
  (comint-send-string "*factor*" "refresh-all\n"))


