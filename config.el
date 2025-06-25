;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Basic user info (optional)
;; (setq user-full-name "Your Name"
;;       user-mail-address "you@example.com")

;; -------------------------------------------------------
;; Core setup
;; -------------------------------------------------------

;; Start the Emacs server so `emacsclient` commands work
(after! server
  (unless (server-running-p)
    (server-start)))

;; Doom Themes
(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (setq doom-theme 'doom-city-lights)
  (load-theme 'doom-city-lights t)
  ;; Treemacs icons
  (setq doom-themes-treemacs-theme "doom-one")
  (doom-themes-treemacs-config))

;; -------------------------------------------------------
;; General settings
;; -------------------------------------------------------

(setq display-line-numbers-type t)
(setq org-directory "~/org/")

;; Auto-save and backup settings (like VS Code)
(setq auto-save-default t
      auto-save-timeout 2
      auto-save-interval 20
      make-backup-files t
      backup-directory-alist '(("." . "~/.emacs.d/backups")))

;; -------------------------------------------------------
;; Treemacs Configuration
;; -------------------------------------------------------


(use-package! treemacs
  :defer t
  :config
  (setq treemacs-width 35
        treemacs-follow-mode t
        treemacs-filewatch-mode t
        treemacs-git-mode 'deferred
        treemacs-collapse-dirs 3
        treemacs-persist-file
        (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
        treemacs-is-never-other-window nil
        treemacs-goto-tag-strategy 'refetch-index)

  ;; VS-Code-like keys
  (global-set-key (kbd "C-\\") #'treemacs)
  (global-set-key (kbd "C-c t") #'treemacs)

  ;; Auto-refresh, extras
  (treemacs-filewatch-mode  t)
  (treemacs-fringe-indicator-mode t)
  (treemacs-git-commit-diff-mode t)
  (treemacs-resize-icons 16))



;; ─────────────────────────────────────────────────────────
;; Auto-open Treemacs on first buffer (only when no DIR arg)
;; ─────────────────────────────────────────────────────────
(defun my/treemacs-on-startup ()
  "Open Treemacs after Doom has finished starting, unless a
directory was supplied on the command line."
  (unless my/initial-directory
    (require 'treemacs)                ; guarantees the package is loaded
    (save-selected-window (treemacs))))

(add-hook 'doom-after-init-hook #'my/treemacs-on-startup)

;; -------------------------------------------------------
;; Treemacs icons (all-the-icons theme)
;; -------------------------------------------------------
(use-package! treemacs-all-the-icons
  :after treemacs              ; load only after core Treemacs
  :config
  (treemacs-load-theme "all-the-icons"))
;; -------------------------------------------------------
;; VS Code-like directory opening behavior
;; -------------------------------------------------------

(defvar my/initial-directory nil
  "Directory Emacs should open on startup when a path is supplied
either on the command line or via emacsclient.")

;; Handle both regular Emacs and emacsclient invocations
(defun my/handle-directory-arg ()
  "Handle directory argument from command line."
  (let ((args (or command-line-args-left
                  (and (boundp 'server-buffer-clients)
                       (cdr command-line-args)))))
    (when args
      (dolist (arg args)
        (when (and arg (stringp arg) (file-directory-p arg)
                   (not (string-match-p "^-" arg))) ; skip options
          (setq my/initial-directory (expand-file-name arg))
          (setq command-line-args-left
                (delete arg command-line-args-left))
          (cl-return t))))))               ; needs (require 'cl-lib)

;; For regular emacs startup
(add-to-list 'command-line-functions #'my/handle-directory-arg)

;; For emacsclient frames
(defun my/handle-emacsclient-directory (&optional dir)
  "Handle directory opening from emacsclient."
  (when (and dir (file-directory-p dir))
    (setq default-directory (expand-file-name dir))
    (cd   default-directory)
    (require 'treemacs)
    (treemacs-select-directory default-directory)
    (treemacs-display-current-project-exclusively)
    (when (featurep 'projectile)
      (projectile-add-known-project default-directory)
      (run-at-time "0.1 sec" nil #'projectile-find-file))))

(add-hook 'server-visit-hook
          (lambda ()
            (when (and buffer-file-name
                       (file-directory-p buffer-file-name))
              (my/handle-emacsclient-directory buffer-file-name))))

;; Set up initial workspace after Doom loads
(add-hook! 'doom-after-init-hook
  (defun my/setup-initial-workspace ()
    "Open the supplied directory (if any) after Doom finishes."
    (when my/initial-directory
      (setq default-directory my/initial-directory)
      (cd   my/initial-directory)
      (require 'treemacs)
      (treemacs-select-directory my/initial-directory)
      (treemacs-display-current-project-exclusively)
      (when (featurep 'projectile)
        (projectile-add-known-project my/initial-directory)
        (run-at-time "0.1 sec" nil #'projectile-find-file)))))

;; Hook for emacsclient frames
(add-hook 'server-visit-hook
          (lambda ()
            (when (and buffer-file-name
                       (file-directory-p buffer-file-name))
              (my/handle-emacsclient-directory buffer-file-name))))

;; Setup initial workspace after Doom loads
(add-hook! 'doom-after-init-hook
  (defun my/setup-initial-workspace ()
    "Set up the initial workspace with Treemacs if directory was provided."
    (when my/initial-directory
      (cd my/initial-directory)
      (setq default-directory my/initial-directory)
      
      ;; Ensure treemacs is loaded and open it
      (require 'treemacs)
      (treemacs-select-directory my/initial-directory)
      (treemacs-display-current-project-exclusively)
      
      ;; Add to projectile
      (when (featurep 'projectile)
        (projectile-add-known-project my/initial-directory)
        ;; Open file finder after a short delay
        (run-at-time "0.1 sec" nil #'projectile-find-file)))))



;; -------------------------------------------------------
;; VS Code-like features
;; -------------------------------------------------------

;; Command palette (like Ctrl+Shift+P in VS Code)
(map! :leader
      :desc "M-x" "SPC" #'execute-extended-command
      :desc "Find file in project" "p f" #'projectile-find-file
      :desc "Search project" "p s" #'projectile-ripgrep)

;; Quick file switching (like Ctrl+P in VS Code)
(map! :n "C-p" #'projectile-find-file
      :i "C-p" #'projectile-find-file)

;; Multiple cursors support
(use-package! evil-mc
  :config
  (global-evil-mc-mode 1))

;; Better search (like Ctrl+Shift+F in VS Code)
(map! :n "C-S-f" #'projectile-ripgrep
      :i "C-S-f" #'projectile-ripgrep)

;; -------------------------------------------------------
;; File explorer enhancements
;; -------------------------------------------------------

;; Make dired more like VS Code's file explorer
(use-package! dired
  :config
  (setq dired-dwim-target t
        dired-recursive-copies 'always
        dired-recursive-deletes 'always
        dired-listing-switches "-alh --group-directories-first"))

;; -------------------------------------------------------
;; Languages / LSP
;; -------------------------------------------------------

;; Enable LSP for VS Code-like intellisense
(after! lsp-mode
  (setq lsp-enable-symbol-highlighting t
        lsp-ui-doc-enable t
        lsp-ui-doc-show-with-cursor t
        lsp-ui-sideline-enable t
        lsp-ui-sideline-show-hover t
        lsp-ui-sideline-show-diagnostics t))

(use-package! protobuf-mode
  :defer t)

;; -------------------------------------------------------
;; Terminal integration
;; -------------------------------------------------------

;; VS Code-like integrated terminal
(map! :leader
      :desc "Open terminal here" "o t" #'+vterm/here
      :desc "Toggle terminal" "t t" #'+vterm/toggle)

;; -------------------------------------------------------
;; Additional keybindings
;; -------------------------------------------------------

;; File operations
(map! "C-s" #'save-buffer
      "C-S-s" #'write-file
      "C-o" #'find-file
      "C-w" #'kill-current-buffer
      "C-S-w" #'delete-window)

;; Tab-like buffer switching
(map! :n "gt" #'next-buffer
      :n "gT" #'previous-buffer)

;; Quick actions
(map! :leader
      :desc "Format buffer" "c f" #'+format/buffer
      :desc "Comment line" "c c" #'comment-line)

;; -------------------------------------------------------
;; Window management
;; -------------------------------------------------------

;; VS Code-like window splitting
(map! "C-\\" #'split-window-right
      "C-|" #'split-window-below)

;; -------------------------------------------------------
;; Startup optimization
;; -------------------------------------------------------

;; Faster startup
(setq gc-cons-threshold 100000000
      read-process-output-max (* 1024 1024))

;; Reset after startup
(add-hook! 'emacs-startup-hook
  (setq gc-cons-threshold 16777216
        read-process-output-max (* 1024 1024)))

;;; config.el ends here