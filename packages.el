;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;; Core packages
(package! transient
  :recipe (:host github
           :repo "magit/transient"
           :branch "main"
           :files ("lisp/*.el" "transient.info")
           :pre-build nil)
  :pin nil)
(package! doom-themes)
(package! treemacs)
(package! treemacs-evil)
(package! treemacs-projectile)
(package! treemacs-icons-dired)
(package! treemacs-magit)
(package! all-the-icons)
;; (package! all-the-icons-dired)
(package! treemacs-all-the-icons) 
;; VS Code-like features
(package! vscode-icon)  ; VS Code icons
(package! company-box)  ; Better completion UI
(package! dired-sidebar)  ; Alternative file explorer

;; Language support
(package! protobuf-mode)

;; Enhanced editing
(package! rainbow-delimiters)  ; Colored parentheses
(package! highlight-indent-guides)  ; VS Code-like indent guides
(package! git-gutter)  ; Git indicators in gutter

;; Better terminal
(package! vterm)

;; File management
(package! ranger)  ; Terminal file manager
(package! dired-single)  ; Reuse dired buffers

;; Additional productivity
(package! which-key)  ; Show key bindings
(package! helpful)  ; Better help pages;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el
