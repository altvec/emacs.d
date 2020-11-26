;;; -*- lexical-binding: t -*-

(setq gc-cons-threshold (* 50 1000 1000))

;; Startup timer
(add-hook 'emacs-startup-hook
	  (lambda()
	    (message "Emacs ready in %s with %d garbage collections."
		     (format "%.2f seconds"
			     (float-time
			      (time-subtract after-init-time
					      before-init-time)))
		     gcs-done)))


;; User info
(setq user-full-name "Sergey Kalistratov"
      user-mail-address "kalistratov@fastmail.com")

;; Check if system is Darwin/MacOS
(defun is-macos()
  "Return true if system is Darwin based"
  (string-equal system-type "darwin"))



;;;;;;;;;;;;;;;;;
;; Use package ;;
;;;;;;;;;;;;;;;;;

(require 'package)
(let* ((no-ssl (and (memq system-type '(ms-dos))
		    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  (add-to-list 'package-archives (cons "org"   (concat proto "://orgmode.org/elpa/")) t))
  ;; (add-to-list 'package-archives (cons "gnu"   (concat proto "://elpa.gnu.org/packages/")) t))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile (require 'use-package))
(setq use-package-always-ensure t)

;; This package is useful for overriding major mode keybindings
(use-package bind-key)

;; Ctrl is Ctrl. Command is Super. Alt/option is Meta. Right Alt/option used for enter symbols.
(when (is-macos)
  (setq
   mac-right-command-modifier 'super
   mac-command-modifier 'super
   mac-option-modifier 'meta
   mac-left-option-modifier 'meta
   mac-right-option-modifier 'nil))

(global-set-key (kbd "s-=") 'text-scale-increase)
(global-set-key (kbd "s--") 'text-scale-decrease)


;;;;;;;;;;;;;
;; Visuals ;;
;;;;;;;;;;;;;
(when (is-macos)
  (add-to-list
   'default-frame-alist '(ns-transparent-titlebar . t))
  (add-to-list
   'default-frame-alist '(ns-appearance . dark)))
;;(load-theme 'tsdh-light t)

;; doom themes
(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-nord t)

  ;; org-mode fontification
  (doom-themes-org-config))

(setq-default line-spacing 0)
(set-face-attribute 'default nil :font "JetBrains Mono 14")
;; Enable composition mode
(mac-auto-operator-composition-mode)

(tool-bar-mode -1)
(scroll-bar-mode -1)
(blink-cursor-mode 0)
(global-visual-line-mode t)

;; Show full path in the title bar.
(setq-default frame-title-format "%b (%f)")

;; Show columns in addition to rows in mode line.
(setq column-number-mode t)

;; Nerver use tabs, use spaces instead.
(setq-default
 indent-tabs-mode nil
 c-basic-indent 2
 c-basic-offset 2
 tab-width 2)

(setq
 tab-width 2
 js-indent-level 2
 css-indent-offset 2
 c-basic-offset 2)

;; Do not autosave and backup files
(setq
 make-backup-files nil
 auto-save-default nil
 create-lockfiles  nil)

;; Auto update buffers when underlying files changes externally
(global-auto-revert-mode t)

;; Basic GUI tweaks
(setq
 inhibit-startup-message t         ; Don't show the startup message
 inhibit-startup-screen t          ; or screen
 cursor-in-non-selected-windows t  ; Hide the cursor in inactive windows
 echo-keystrokes 0.1               ; Show keystrokes right away, don't show the message in the scratch buffer
 initial-scratch-message nil       ; Empty scratch buffer
 sentence-end-double-space t       ; Double space at the end of the sentence!
 confirm-kill-emacs 'y-or-n-p)     ; y or n instead of yes and no when quitting

(fset 'yes-or-no-p 'y-or-n-p)      ; y or n instead of yes and no everywhere else
(delete-selection-mode 1)
(global-unset-key (kbd "s-p"))

;; Stop making noise
(setq ring-bell-function #'ignore)

;; Eval expr regardless of the mode
(global-set-key (kbd "C-s-<return>") (kbd "C-x C-e"))

;; Quick switch to scratch buffer with Cmd-0
(global-set-key (kbd "s-0") (lambda()
                              (interactive)
                              (if (string= (buffer-name) "*scratch*")
                                  (previous-buffer)
                                (switch-to-buffer "*scratch*"))))

;; This is great for learning Emacs, it shows a nice table of possible commands.
(use-package which-key
  :diminish
  :config
  (which-key-mode)
  (setq which-key-idle-delay 1.0))

;; Make emacs keys work with russian keymap
(use-package reverse-im
  :config
  (reverse-im-activate "russian-computer"))

;; Better mode line
(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom
  (doom-modeline-height 12)
  (doom-modeline-bar-width 4))


;; Rainbow delimiters
(use-package rainbow-delimiters
  ;; prog-mode is a base mode for any programming language mode
  :hook (prog-mode . rainbow-delimiters-mode))


;;;;;;;;;;;;;;;;;;;;
;; OS integration ;;
;;;;;;;;;;;;;;;;;;;;

;; Pass system shell env to Emacs.
(when (is-macos)
  (use-package exec-path-from-shell
    :config
    (when (memq window-system '(mac ns))
      (exec-path-from-shell-initialize))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Navigation and editing ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Kill the line with Cmd-Backspace.
;; Note that thanks to Simpleclip, killing doesn't rewrite the system clipboard.
;; Kill one word by =Alt-Backspace=. Also, kill forward word with =Alt-Shift-Backspace=,
;; since =Alt-Backspace= is kill word backwards.
(global-set-key (kbd "s-<backspace>") 'kill-whole-line)
(global-set-key (kbd "s-<delete>") 'kill-whole-line)
(global-set-key (kbd "M-S-<backspace>") 'kill-word)
(global-set-key (kbd "M-<delete>") 'kill-word)
(bind-key* "S-<delete>" 'kill-word)

;; Use Cmd/Super for movement and selection just like in macOS.
(global-set-key (kbd "s-<right>") 'end-of-visual-line)
(global-set-key (kbd "s-<left>") 'beginning-of-visual-line)
(global-set-key (kbd "s-<up>") 'beginning-of-buffer)
(global-set-key (kbd "s-<down>") 'end-of-buffer)
(global-set-key (kbd "s-l") 'goto-line)

(global-set-key (kbd "s-a") 'mark-whole-buffer)        ; select all
(global-set-key (kbd "s-s") 'save-buffer)              ; save
(global-set-key (kbd "s-S") 'write-file)               ; save as
(global-set-key (kbd "s-q") 'save-buffers-kill-emacs)  ; quit

;; Regular undo-redo.
(use-package undo-fu)
(global-unset-key (kbd "C-z"))
(global-set-key (kbd "C-z")   'undo-fu-only-undo)
(global-set-key (kbd "C-S-z") 'undo-fu-only-redo)
(global-set-key (kbd "s-z")   'undo-fu-only-undo)
(global-set-key (kbd "s-r")   'undo-fu-only-redo)

;; Avy for fast navigation.
(use-package avy
  :defer t
  :config
  (global-set-key (kbd "s-;") 'avy-goto-char-timer))

;; Auto completion

(use-package company
  :config
  (setq company-idle-delay 0.1)
  (setq company-global-modes '(not org-mode))
  (setq company-minimum-prefix-length 1)
  (add-hook 'after-init-hook 'global-company-mode))

;; Auto-complete does't work with elpy :(
;; (use-package auto-complete
;;   :config
;;   (ac-config-default))

(use-package smartparens
  :config
  (smartparens-global-mode t)
  (show-smartparens-global-mode t)
  (setq sp-show-pair-delay 0)
  (sp-local-pair 'emacs-lisp-mode "'" nil :actions nil)
  (sp-local-pair 'markdown-mode "`" nil :actions '(wrap insert)) ; only use ` for wrap and auto insert in md
  (sp-local-tag 'markdown-mode "s" "```scheme" "```")
  (define-key smartparens-mode-map (kbd "C-s-<right>") 'sp-forward-slurp-sexp)
  (define-key smartparens-mode-map (kbd "C-s-<left>") 'sp-forward-barf-sexp))

;; Go back to prev mark (position) within buffer and go back (forward).
(defun my-pop-local-mark-ring()
  (interactive)
  (set-mark-command t))

(defun unpop-to-mark-command()
  "Unpop off mark ring. Does nothing if mark ring is empty."
  (interactive)
  (when mark-ring
    (setq mark-ring (cons (copy-marker (mark-marker)) mark-ring))
    (set-marker (mark-marker) (car (last mark-ring)) (current-buffer))
    (when (null (mark t)) (ding))
    (setq mark-ring (nbutlast mark-ring))
    (goto-char (marker-position (car (last mark-ring))))))

(global-set-key (kbd "s-,") 'my-pop-local-mark-ring)
(global-set-key (kbd "s-.") 'unpop-to-mark-command)

;; Since Cmd/Super-, and Cmd/Super-. move you back and forward in the current buffer
;; the same keys with Shift move you back and forward between open buffers.
(global-set-key (kbd "s-<") 'previous-buffer)
(global-set-key (kbd "s->") 'next-buffer)

;; Go to other windows easily with one keystroke Super/Cmd-something insted of C-x something
(defun vsplit-last-buffer()
  (interactive)
  (split-window-vertically)
  (other-window 1 nil)
  (switch-to-next-buffer))

(defun hsplit-last-buffer()
  (interactive)
  (split-window-horizontally)
  (other-window 1 nil)
  (switch-to-next-buffer))

(global-set-key (kbd "s-w") (kbd "C-x 0")) ; just like close tab in a web browser
(global-set-key (kbd "s-W") (kbd "C-x 1")) ; close others with shift
(global-set-key (kbd "s-T") 'vsplit-last-buffer)
(global-set-key (kbd "s-t") 'hsplit-last-buffer)
(global-set-key (kbd "C-s-k") 'kill-this-buffer) ; kill buffer with ctrl-super-k

;; Allows to gradually expand selection inside words, sentences, etc.
;; C-' is bound to Org's `cycle through agenda files` which I don't use.
(use-package expand-region
  :config
  (global-set-key (kbd "s-'") 'er/expand-region)
  (global-set-key (kbd "s-\"") 'er/contract-region))

;; Move text lines around with meta-up/down
(use-package move-text
  :config
  (move-text-default-bindings))

;; Crux
(use-package crux
  :bind (("C-a" . crux-move-beginning-of-line)
         ("s-<return>" . crux-smart-open-line)
         ("s-S-<return>" . crux-smart-open-line-above)
         ("s-R" . crux-rename-file-and-buffer)))

;; Join lines whether you're in a region or not.
(defun smart-join-line (beg end)
  "If in a region, join all the lines in it. If not, join the current line with the next line."
  (interactive "r")
  (if mark-active
      (join-region beg end)
      (top-join-line)))

(defun top-join-line ()
  "Join the current line with the next line."
  (interactive)
  (delete-indentation 1))

(defun join-region (beg end)
  "Join all the lines in the region."
  (interactive "r")
  (if mark-active
      (let ((beg (region-beginning))
            (end (copy-marker (region-end))))
        (goto-char beg)
        (while (< (point) end)
          (join-line 1)))))

(global-set-key (kbd "s-j") 'smart-join-line)

;; Upcase word and region using the same keys
(global-set-key (kbd "M-u") 'upcase-dwim)
(global-set-key (kbd "M-l") 'downcase-dwim)

;; Delete trailing spaces and add new line in the end of a file on save.
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(setq require-final-newline t)

;; Multiple cusors are a must. Make <return> insert a newline; multiple-cursors-mode can still be disabled with C-g.
(use-package multiple-cursors
  :config
  (setq mc/always-run-for-all 1)
  (global-set-key (kbd "s-d") 'mc/mark-next-like-this)
  (global-set-key (kbd "s-D") 'mc/mark-all-dwim)
  (define-key mc/keymap (kbd "<return>") nil))

;; Comment lines.
(global-set-key (kbd "s-/") 'comment-line)


;;;;;;;;;;;;;
;; Windows ;;
;;;;;;;;;;;;;

;; Automatic windows are always created on the botton, not on the side.
(setq
 split-height-threshold 0
 split-width-threshold nil)

;; Move between windows with control-command-arrow and with cmd - like in iterm
(global-set-key (kbd "s-o") (kbd "C-x o"))

(use-package windmove
  :config
  (global-set-key (kbd "s-[")  'windmove-left)    ;; Cmd+[ go to left window
  (global-set-key (kbd "s-]")  'windmove-right)   ;; Cmd+] go to right window
  (global-set-key (kbd "s-{")  'windmove-up)      ;; Cmd+Shift+ go to upper window
  (global-set-key (kbd "<s-}>")  'windmove-down)) ;; Ctrl+Shift+ go to down window

;; Enable winner mode to quickly restore window configurations
(winner-mode 1)

;; Shackle to make sure all windows are nicely positioned.
(use-package shackle
  :init
  (setq shackle-default-alignment 'below
        shackle-default-size 0.4
        shackle-rules '((help-mode           :align below :select t)
                        (helpful-mode        :align below)
                        (compilation-mode    :select t   :size 0.25)
                        ("*compilation*"     :select nil :size 0.25)
                        ("*ag search*"       :select nil :size 0.25)
                        ("*Flycheck errors*" :select nil :size 0.25)
                        ("*Warnings*"        :select nil :size 0.25)
                        ("*Error*"           :select nil :size 0.25)
                        ("*Org Links*"       :select nil :size 0.1)
                        (magit-status-mode                :align bottom :size 0.5  :inhibit-window-quit t)
                        (magit-log-mode                   :same t                  :inhibit-window-quit t)
                        (magit-commit-mode                :ignore t)
                        (magit-diff-mode     :select nil  :align left   :size 0.5)
                        (git-commit-mode                  :same t)
                        (vc-annotate-mode                 :same t)
                        ))
  :config
  (shackle-mode 1))

;; Edit indirect
;; Select any region and edit it in another buffer.
;; TODO: if region selected, invoke edit indirect with same keystroke as narrow
(use-package edit-indirect)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; IVY, SWIPER AND COUNSEL ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package ivy
  :diminish
  :config
  (ivy-mode 1)
  (setq
   ivy-use-virtual-buffers t
   ivy-count-format "(%d/%d) "
   enable-recursive-minibuffers t
   ivy-initial-inputs-alist nil
   ivy-re-builders-alist
   '((swiper . ivy--regex-plus)
     (swiper-isearch . regexp-quote)
     ;; (counsel-git . ivy--regex-plus)
     ;; (counsel-ag . ivy--regex-plus)
     (counsel-rg . ivy--regex-plus)
     (t      . ivy--regex-fuzzy)))   ;; enable fuzzy searching everywhere except for Swiper and ag

  (global-set-key (kbd "s-b") 'ivy-switch-buffer))

(use-package swiper
  :config
  (global-set-key (kbd "s-f") 'swiper-isearch))

(use-package counsel
  :config
  ;; When using git ls (via counsel-git), include unstaged files
  (setq counsel-git-cmd "git ls-files -z --full-name --exclude-standard --others --cached --")
  (setq ivy-initial-inputs-alist nil)

  (global-set-key (kbd "M-x") 'counsel-M-x)
  (global-set-key (kbd "s-y") 'counsel-yank-pop)
  (global-set-key (kbd "C-x C-f") 'counsel-find-file)
  (global-set-key (kbd "s-F") 'counsel-rg)
  (global-set-key (kbd "s-p") 'counsel-git))

(use-package smex)
(use-package flx)

(use-package ivy-rich
  :config
  (ivy-rich-mode 1)
  (setq ivy-rich-path-style 'abbrev)) ;; To abbreviate paths using abbreviate-file-name (e.g. replace “/home/username” with “~”


;; Projectile
(use-package projectile
  :config
  (setq projectile-project-search-path '("~/Code/")))
  (define-key projectile-mode-map (kbd "C-s-p") 'projectile-command-map) ;; Ctrl-cmd-p show projectile menu
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (projectile-mode +1)


;;;;;;;;;;;
;; MAGIT ;;
;;;;;;;;;;;

;; Navigate to projects with =Cmd+Shift+P= (thanks to reddit user and emacscast listener fritzgrabo):
(defun magit-status-with-prefix-arg ()
  "Call `magit-status` with a prefix."
  (interactive)
  (let ((current-prefix-arg '(4)))
    (call-interactively #'magit-status)))

(use-package magit
  :config
  (setq magit-repository-directories '(("\~/Code" . 4)))
  (global-set-key (kbd "s-P") 'magit-status-with-prefix-arg)
  (global-set-key (kbd "s-g") 'magit-status))


;;;;;;;;;;;;;;;;;
;; Programming ;;
;;;;;;;;;;;;;;;;;

(use-package markdown-mode
  :defer t
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'"       . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :bind (:map markdown-mode-map
              ("s-k"        . 'markdown-insert-link)
              ("C-s-<down>" . 'markdown-narrow-to-subtree)
              ("C-s-<up>"   . 'widen)))

(use-package yaml-mode
  :defer t
  :mode (("\\.ya?ml\\'"  . yaml-mode)))

(use-package web-mode
  :defer t
  :mode ("\\.\\(html?\\|ejs\\|tsx\\|jsx\\)\\'")
  :config
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-attribute-indent-offset 2))

(use-package emmet-mode
  :defer t
  :init
  (setq
   emmet-indentation 2
   emmet-move-cursor-between-quotes t)
  :config
  (add-hook 'sgml-mode-hook 'emmet-mode) ; auto-start on any markup mode
  (add-hook 'web-mode-hook  'emmet-mode)
  (add-hook 'html-mode-hook 'emmet-mode)
  (add-hook 'css-mode-hook  'emmet-mode))

(use-package python
  :defer t
  :mode ("\\.py\\'" . python-mode))

(use-package elpy
  :after (python)
  :hook
  (python-mode . elpy-mode)
  (elpy-mode . flycheck-mode)
  :custom
  (elpy-rpc-virtualenv-path 'current)
  (elpy-modules
   '(elpy-module-company
     elpy-module-eldoc
     elpy-module-highlight-indentation
     elpy-module-django))
  :config
  (elpy-enable))

(use-package format-all)

;; Javascript
(use-package js2-mode
  :mode "\\.jsx?\\'"
  :config
  (add-to-list 'magic-mode-alist '("#!/usr/bin/env node" . js2-mode))
  )


;;;;;;;;;;;;;;
;; ORG mode ;;
;;;;;;;;;;;;;;

(use-package org
  :defer t
  :config
  (setq
   org-startup-indented t
   org-catch-invisible-edits 'error
   org-cycle-separator-lines -1
   calendar-week-start-day 1
   org-ellipsis "⤵"
   org-directory "/Users/skali/Library/Mobile Documents/com~apple~CloudDocs/knowledgebase/org"
   org-agenda-files '("/Users/skali/Library/Mobile Documents/com~apple~CloudDocs/knowledgebase/org")
   org-refile-target (quote ((nil :maxlevel . 9)
                             (org-agenda-files :maxlevel . 9)))
   org-src-tab-acts-natively t
   org-src-preserve-indentation t
   org-src-fontify-natively t
   ;; org-hide-emphasis-markers t ; hide markers

   ;; enable speed keys to manage headings without arrows
   org-use-speed-commands t

   ;; allow shift select with arrows
   org-support-shift-select t)



   ;; custom fill-column for org
   (add-hook 'org-mode-hook (lambda () (setq fill-column 120)))
  :bind (:map org-mode-map
              ("C-s-<down>" . 'org-narrow-to-subtree)
              ("C-s-<up>"   . 'widen))
  :config
  (require 'org-indent)
  (require 'org-tempo)
  (add-to-list 'org-structure-template-alist '("el"   . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("py"   . "src python"))
  (add-to-list 'org-structure-template-alist '("sh"   . "src sh"))
  (add-to-list 'org-structure-template-alist '("js"   . "src javascript"))
  (add-to-list 'org-structure-template-alist '("yaml" . "src yaml"))
  (add-to-list 'org-structure-template-alist '("json" . "src json"))

  :custom
  (org-blank-before-new-entry '((heading . t)
                                (plain-list-item . t)))
  )

(use-package ob-emacs-lisp :ensure nil :after org)
(use-package ob-js :ensure nil :after org)
(use-package ob-python :ensure nil :after org)
(use-package ob-shell :ensure nil :after org)
(use-package ob-typescript :after org)
(use-package ob-http :after org)

;;;;;;;;;;;
;; Other ;;
;;;;;;;;;;;

;; Store custom-file separately, don't freak out when it's not found.
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file 'noerror)

(use-package unkillable-scratch
  :ensure t
  :config (unkillable-scratch t))


;;;;;;;;;;;;;
;; THE END ;;
;;;;;;;;;;;;;

(setq gc-cons-threshold (* 2 1000 1000))
