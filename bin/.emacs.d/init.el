;;; init.el --- Main configuration -*- lexical-binding: t; -*-

;;;; 1. Package sources
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Refresh package list if empty (first launch)
(unless package-archive-contents
  (package-refresh-contents))

;; Enable use-package :ensure support (separate module in Emacs 30)
(require 'use-package-ensure)
(setq use-package-always-ensure t)

;; Keep custom-set-variables in separate file
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;; Copy PATH from shell (needed for GUI Emacs on macOS)
(use-package exec-path-from-shell
  :if (memq window-system '(mac ns))
  :config
  (exec-path-from-shell-initialize))

;;;; 2. Sane defaults
(setq make-backup-files nil
      auto-save-default nil
      create-lockfiles nil
      inhibit-startup-message t
      ring-bell-function 'ignore
      use-short-answers t)

(setq-default indent-tabs-mode nil
              tab-width 4)

;; Line numbers
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)
(dolist (mode '(vterm-mode-hook term-mode-hook eshell-mode-hook shell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode -1))))

;; Highlight trailing whitespace
(dolist (mode '(prog-mode-hook text-mode-hook))
  (add-hook mode (lambda () (setq show-trailing-whitespace t))))

;; Auto-revert files changed on disk
(global-auto-revert-mode 1)

;; Recent files
(recentf-mode 1)

;; Persist minibuffer history
(savehist-mode 1)

;; Remember cursor position
(save-place-mode 1)

;; Auto-close pairs (except in minibuffer)
(electric-pair-mode 1)
(add-hook 'minibuffer-setup-hook (lambda () (electric-pair-local-mode -1)))

;; Font (JetBrains Mono required)
(if (member "JetBrains Mono" (font-family-list))
    (progn
      (set-face-attribute 'default nil :family "JetBrains Mono" :height 140)
      (set-face-attribute 'fixed-pitch nil :family "JetBrains Mono" :height 140))
  (error "JetBrains Mono font not found. Install with: brew install --cask font-jetbrains-mono"))

;;;; 3. Config auto-reload
(require 'filenotify)

(defvar my/config-watch-descriptor nil)
(defvar my/config-reload-timer nil)

(defun my/reload-init ()
  "Reload init.el with error handling."
  (condition-case err
      (progn
        (load user-init-file nil t)
        (message "Config reloaded"))
    (error (message "Config reload failed: %s" (error-message-string err)))))

(defun my/config-file-changed (event)
  "Handle config file change EVENT with debouncing."
  (when (eq (nth 1 event) 'changed)
    (when my/config-reload-timer
      (cancel-timer my/config-reload-timer))
    (setq my/config-reload-timer
          (run-at-time 0.5 nil #'my/reload-init))))

(defun my/start-config-watcher ()
  "Start watching init.el for changes."
  (when my/config-watch-descriptor
    (file-notify-rm-watch my/config-watch-descriptor))
  (setq my/config-watch-descriptor
        (file-notify-add-watch user-init-file '(change) #'my/config-file-changed)))

(my/start-config-watcher)

;;;; 4. Theme
(use-package ef-themes
  :config
  (load-theme 'ef-autumn t)
  ;; Lighten background so black terminal text is visible
  (set-face-attribute 'default nil :background "#1f1c14"))

;;;; 5. Evil mode
(use-package evil
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-undo-system 'undo-redo)
  :config
  (evil-mode 1)
  ;; Sync kill ring with system clipboard
  (setq select-enable-clipboard t
        select-enable-primary nil
        interprogram-paste-function #'gui-selection-value)
  ;; Cmd-v to paste from clipboard
  (global-set-key (kbd "M-v") #'clipboard-yank)
  (global-set-key (kbd "s-v") #'clipboard-yank))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;; Use ; as Control prefix in normal/visual/motion states
;; Press ; then any key to get C-<key> (e.g., ;x ;c = C-x C-c)
(defun my/semicolon-ctrl ()
  "Simulate Control modifier for the next key."
  (interactive)
  (let ((key (read-char ";")))
    (cond
     ((<= ?a key ?z)
      (setq unread-command-events (list (- key 96))))
     ((<= ?A key ?Z)
      (setq unread-command-events (list (- key 64))))
     ((= key ?\;)
      ;; ;; types a literal semicolon
      (insert ";"))
     (t
      (setq unread-command-events (list (event-apply-control-modifier key)))))))

(with-eval-after-load 'evil
  (evil-define-key '(normal visual motion) 'global ";" #'my/semicolon-ctrl))

;; Ensure ; and search work in dired/dirvish
(with-eval-after-load 'dired
  (evil-define-key '(normal visual motion) dired-mode-map ";" #'my/semicolon-ctrl))
(with-eval-after-load 'dirvish
  (evil-define-key '(normal visual motion) dirvish-mode-map ";" #'my/semicolon-ctrl))

;;;; 6. Which-key
(use-package which-key
  :config
  (which-key-mode 1))

;;;; 7. Completion stack
(use-package vertico
  :config
  (vertico-mode 1))

(use-package orderless
  :config
  (setq completion-styles '(orderless basic)
        completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :config
  (marginalia-mode 1))

(use-package consult
  :bind (("C-x b" . consult-buffer)))

;;;; 8. Magit (git interface)
(defun magit-status-in-new-tab ()
  "Open magit-status in a new tab."
  (interactive)
  (tab-bar-new-tab)
  (magit-status))

(use-package magit
  :bind ("C-x g" . magit-status-in-new-tab)
  :config
  (setq magit-display-buffer-function #'magit-display-buffer-fullframe-status-v1))

;;;; 9. Dirvish (better dired)
(use-package dirvish
  :init
  (dirvish-override-dired-mode)
  :config
  (setq dirvish-attributes '(file-size collapse subtree-state vc-state git-msg))
  (setq dirvish-hide-details t))

;;;; 10. Diff-hl (git diff in fringe)
(use-package diff-hl
  :hook ((prog-mode . diff-hl-mode)
         (text-mode . diff-hl-mode)
         (dired-mode . diff-hl-dired-mode))
  :config
  (diff-hl-flydiff-mode 1)
  (with-eval-after-load 'magit
    (add-hook 'magit-pre-refresh-hook #'diff-hl-magit-pre-refresh)
    (add-hook 'magit-post-refresh-hook #'diff-hl-magit-post-refresh)))

;;;; 11. Beacon (cursor flash on scroll)
(use-package beacon
  :config
  (beacon-mode 1))

;;;; 12. Vterm
(use-package vterm
  :commands vterm)

(defun my/vterm-in-new-tab ()
  "Open a terminal in a new tab."
  (interactive)
  (tab-bar-new-tab)
  (vterm (generate-new-buffer-name "*vterm*")))

(defun my/org-in-new-tab ()
  "Open an org scratch buffer in a new tab."
  (interactive)
  (tab-bar-new-tab)
  (let ((buf (get-buffer-create "*org*")))
    (switch-to-buffer buf)
    (org-mode)))

(defun my/vterm-split-right ()
  "Split window right and open terminal."
  (interactive)
  (split-window-right)
  (other-window 1)
  (vterm (generate-new-buffer-name "*vterm*")))

(defun my/vterm-split-below ()
  "Split window below and open terminal."
  (interactive)
  (split-window-below)
  (other-window 1)
  (vterm (generate-new-buffer-name "*vterm*")))

(global-set-key (kbd "C-x t t") #'my/vterm-in-new-tab)
(global-set-key (kbd "C-x t o") #'my/org-in-new-tab)

;; C-w t / C-w T for terminal in split (;w t / ;w T)
(with-eval-after-load 'evil
  (define-key evil-window-map "t" #'my/vterm-split-below)
  (define-key evil-window-map "T" #'my/vterm-split-right))

;;;; 13. Project.el (built-in)
(require 'project)
;; Use vertico for xref results (project-find-regexp)
(setq xref-show-xrefs-function #'xref-show-definitions-completing-read)
;; Load known projects list at startup
(when (file-exists-p project-list-file)
  (with-temp-buffer
    (insert-file-contents project-list-file)
    (setq project--list (read (current-buffer)))))

;;;; 14. Tab-bar-mode
(setq tab-bar-show t
      tab-bar-close-button-show nil
      tab-bar-new-button-show nil
      tab-bar-tab-hints t
      tab-bar-format '(tab-bar-format-tabs tab-bar-separator))

(defun my/tab-bar-tab-name-format (tab i)
  "Format TAB name with index I as 'Ngt: name'."
  (let ((current-p (eq (car tab) 'current-tab)))
    (propertize
     (concat (number-to-string i) "gt:" (alist-get 'name tab))
     'face (if current-p 'tab-bar-tab 'tab-bar-tab-inactive))))

(setq tab-bar-tab-name-format-function #'my/tab-bar-tab-name-format)
(tab-bar-mode 1)

;; Tab bar styling (uses theme colors)
(defun my/style-tab-bar ()
  "Style tab bar using current theme colors."
  (when (fboundp 'ef-themes-with-colors)
    (ef-themes-with-colors
      (set-face-attribute 'tab-bar nil
                          :background bg-dim :foreground fg-dim
                          :box nil)
      (set-face-attribute 'tab-bar-tab nil
                          :background bg-alt :foreground fg-main
                          :box `(:line-width (4 . 4) :color ,bg-alt))
      (set-face-attribute 'tab-bar-tab-inactive nil
                          :background bg-dim :foreground fg-dim
                          :box `(:line-width (4 . 4) :color ,bg-dim)))))

(with-eval-after-load 'ef-themes
  (add-hook 'ef-themes-post-load-hook #'my/style-tab-bar)
  (my/style-tab-bar))

;;;; 15. Minimal mode line
(defun my/mode-line-evil-state ()
  "Return single letter for current evil state."
  (if (bound-and-true-p evil-local-mode)
      (cond
       ((evil-normal-state-p) "N")
       ((evil-insert-state-p) "I")
       ((evil-visual-state-p) "V")
       ((evil-replace-state-p) "R")
       ((evil-operator-state-p) "O")
       ((evil-motion-state-p) "M")
       ((evil-emacs-state-p) "E")
       (t "-"))
    "-"))

(setq-default mode-line-format
              '(" "
                (:eval (if (mode-line-window-selected-p)
                           (concat (my/mode-line-evil-state) " ")
                         "  "))
                (:eval (if (buffer-modified-p) "◇ " "◆ "))
                "%b"))

;; Style mode line to match theme
(defun my/style-mode-line ()
  "Style mode line using current theme colors."
  (when (fboundp 'ef-themes-with-colors)
    (ef-themes-with-colors
      (set-face-attribute 'mode-line nil
                          :background bg-alt :foreground fg-main
                          :box nil)
      (set-face-attribute 'mode-line-inactive nil
                          :background bg-dim :foreground fg-dim
                          :box nil))))

(with-eval-after-load 'ef-themes
  (add-hook 'ef-themes-post-load-hook #'my/style-mode-line)
  (my/style-mode-line))

;;;; 16. Project workspace function
(require 'project)

(defun my/vterm-send-after-init (buffer command)
  "Send COMMAND to BUFFER's vterm after shell initializes.
Uses process filter to detect when shell is ready."
  (let ((proc (get-buffer-process buffer)))
    (when proc
      (let ((original-filter (process-filter proc))
            (sent nil))
        (set-process-filter
         proc
         (lambda (proc output)
           (funcall original-filter proc output)
           (unless sent
             (setq sent t)
             (run-at-time 0.1 nil
                          (lambda ()
                            (when (buffer-live-p buffer)
                              (with-current-buffer buffer
                                (vterm-send-string command))))))))))))


(defun my/open-project-workspace-at (project)
  "Open PROJECT in a new tab with a 3-pane layout.
Code (top-left), Term (bottom-left), Claude (right)."
  (condition-case err
      (let* ((project (expand-file-name project))
             (proj-name (file-name-nondirectory (directory-file-name project)))
             (default-directory project))
        (unless (file-directory-p project)
          (error "Directory does not exist: %s" project))
        ;; Create a named tab
        (tab-bar-new-tab)
        (tab-bar-rename-tab proj-name)
        ;; Start with a dired/file buffer in the project root (top-left)
        (dired project)
        ;; Split right for Claude (full height)
        (split-window-right (floor (* 0.5 (window-total-width))))
        (other-window 1)
        (vterm (format "*claude-%s*" proj-name))
        (evil-normal-state)
        ;; Send claude command after shell initializes
        (my/vterm-send-after-init (current-buffer) "claude --resume\n")
        ;; Go back to left side and split for terminal (bottom-left)
        (other-window 1)
        (split-window-below)
        (other-window 1)
        (vterm (format "*term-%s*" proj-name))
        (evil-normal-state)
        ;; Focus on Claude pane (right)
        (other-window 2))
    (quit (message "Workspace creation cancelled"))
    (error (message "Failed to create workspace: %s" (error-message-string err)))))

(defun my/open-project-workspace ()
  "Prompt for a project and open it in a workspace."
  (interactive)
  (my/open-project-workspace-at (read-directory-name "Project: ")))

(global-set-key (kbd "C-x p w") #'my/open-project-workspace)

;;;; 17. Language modes

;; Python (built-in, just ensure indent)
(setq python-indent-offset 4)

;; Rust
(use-package rust-mode
  :mode "\\.rs\\'")

;; Markdown
(use-package markdown-mode
  :mode (("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode)))

;; Git-related files (.gitignore, .gitattributes, etc.)
(use-package git-modes)

;; HTML/CSS/JS (built-in modes, just set indent)
(setq css-indent-offset 2)
(setq js-indent-level 2)

;;;; 18. Terminal config
;; Kill vterm buffer when shell exits
(setq vterm-kill-buffer-on-exit t)

;; Hide Emacs cursor in vterm insert mode (terminal has its own cursor)
(defun my/vterm-hide-cursor ()
  "Hide Emacs cursor when entering insert state in vterm."
  (when (derived-mode-p 'vterm-mode)
    (setq-local cursor-type nil)))

(defun my/vterm-show-cursor ()
  "Show Emacs cursor when leaving insert state in vterm."
  (when (derived-mode-p 'vterm-mode)
    (kill-local-variable 'cursor-type)))

(defun my/vterm-escape-to-normal ()
  "Switch to evil normal state in vterm (don't send escape)."
  (interactive)
  (evil-normal-state))

(defun my/vterm-send-escape ()
  "Send Escape key to vterm."
  (interactive)
  (vterm-send-key "<escape>"))

(with-eval-after-load 'evil
  (add-hook 'evil-insert-state-entry-hook #'my/vterm-hide-cursor)
  (add-hook 'evil-insert-state-exit-hook #'my/vterm-show-cursor))

;; Vterm escape behavior:
;; - Insert mode: Esc switches to normal mode
;; - Normal mode: Esc sends escape to terminal
(with-eval-after-load 'vterm
  (evil-define-key 'insert vterm-mode-map (kbd "<escape>") #'my/vterm-escape-to-normal)
  (evil-define-key 'normal vterm-mode-map (kbd "<escape>") #'my/vterm-send-escape)
  ;; Shift+Enter sends Ctrl+J (newline in Claude Code)
  (define-key vterm-mode-map (kbd "S-<return>") (lambda () (interactive) (vterm-send-key "j" nil nil t)))
  ;; Cmd-v to paste from clipboard in vterm
  (define-key vterm-mode-map (kbd "M-v") #'vterm-yank)
  (define-key vterm-mode-map (kbd "s-v") #'vterm-yank))

;;;; 19. Startup and help screens

;; Game of Life state
(defvar my/gol-width 100)
(defvar my/gol-height 24)
(defvar my/gol-grid nil)
(defvar my/gol-timer nil)

(defun my/gol-init ()
  "Initialize Game of Life grid with random cells."
  (setq my/gol-grid (make-vector (* my/gol-width my/gol-height) 0))
  (dotimes (i (length my/gol-grid))
    (aset my/gol-grid i (if (< (random 100) 25) 1 0))))

(defun my/gol-step ()
  "Compute next generation (optimized)."
  (let* ((w my/gol-width)
         (h my/gol-height)
         (size (* w h))
         (old my/gol-grid)
         (new (make-vector size 0)))
    (dotimes (y h)
      (let* ((y-1 (mod (1- y) h))
             (y+1 (mod (1+ y) h))
             (row (* y w))
             (row-1 (* y-1 w))
             (row+1 (* y+1 w)))
        (dotimes (x w)
          (let* ((x-1 (mod (1- x) w))
                 (x+1 (mod (1+ x) w))
                 (neighbors (+ (aref old (+ row-1 x-1)) (aref old (+ row-1 x)) (aref old (+ row-1 x+1))
                               (aref old (+ row x-1))                          (aref old (+ row x+1))
                               (aref old (+ row+1 x-1)) (aref old (+ row+1 x)) (aref old (+ row+1 x+1))))
                 (alive (aref old (+ row x))))
            (aset new (+ row x)
                  (if (or (= neighbors 3) (and (= alive 1) (= neighbors 2))) 1 0))))))
    (setq my/gol-grid new)))

(defconst my/gol-halfblocks
  (vector " " "▄" "▀" "█")
  "Half-block characters indexed by 2-bit pattern: TOP*2 + BOTTOM.")

(defun my/gol-render ()
  "Render Game of Life grid as list of strings.
Uses half-block characters: each char shows 2 vertical cells."
  (let ((lines '())
        (border-width my/gol-width)
        (figure-face '(:foreground "#ff79c6"))
        (w my/gol-width)
        (h my/gol-height))
    ;; Stick figure sitting on top-right edge
    (push (concat (make-string border-width ?\s)
                  (propertize "o  Hi!" 'face figure-face)) lines)
    (push (concat (make-string border-width ?\s)
                  (propertize "|┘" 'face figure-face)) lines)
    ;; Top border with gap for legs
    (push (concat "┌" (make-string (- border-width 1) ?─)
                  (propertize "└┐┐" 'face figure-face)) lines)
    ;; Grid: 2 rows per line, 1 col per char
    (let ((y 0))
      (while (< y h)
        (let ((line "│")
              (row0 (* y w))
              (row1 (* (1+ y) w)))
          (dotimes (x w)
            (let* ((top (aref my/gol-grid (+ row0 x)))
                   (bot (if (< (1+ y) h) (aref my/gol-grid (+ row1 x)) 0))
                   (idx (+ (* top 2) bot)))
              (setq line (concat line (aref my/gol-halfblocks idx)))))
          (setq line (concat line "│"))
          (push line lines))
        (setq y (+ y 2))))
    (let* ((hint "[spacebar: reset]")
           (padding (/ (- border-width (length hint)) 2)))
      (push (concat "└" (make-string padding ?─) hint (make-string (- border-width (length hint) padding) ?─) "┘") lines))
    (nreverse lines)))

(defun my/gol-update-display ()
  "Update the welcome screen with new Game of Life state.
Only runs when welcome buffer is visible to save battery."
  (when-let ((buf (get-buffer "*welcome*")))
    (when (get-buffer-window buf t)
      (with-current-buffer buf
        (when (eq major-mode 'fundamental-mode)
          (my/gol-step)
          (my/startup-screen-render))))))

(defun my/recent-projects-list ()
  "Return deduplicated list of recent projects (by name)."
  (when (and (boundp 'project--list) (listp project--list))
    (let ((all-projects (mapcar #'car project--list))
          (seen-names '())
          (projects '()))
      (dolist (proj all-projects)
        (let ((name (file-name-nondirectory (directory-file-name proj))))
          (unless (member name seen-names)
            (push name seen-names)
            (push proj projects))))
      (nreverse projects))))

(defun my/recent-projects-box ()
  "Generate recent projects box lines."
  (let* ((projects (seq-take (my/recent-projects-list) 5))
         (max-name-len 20)
         (lines '()))
    (push "┌─Recent Projects─────────┐" lines)
    (if projects
        (let ((i 1))
          (dolist (proj projects)
            (let* ((name (file-name-nondirectory (directory-file-name proj)))
                   (name (if (> (length name) max-name-len)
                             (concat (substring name 0 (- max-name-len 2)) "..")
                           name)))
              (push (format "│ %d: %-20s │" i name) lines))
            (setq i (1+ i)))
          ;; Pad to 5 entries
          (while (< (length lines) 6)
            (push "│                         │" lines)))
      (push "│   (no projects yet)     │" lines)
      (dotimes (_ 4)
        (push "│                         │" lines)))
    (push "└─────────────────────────┘" lines)
    (nreverse lines)))

(defun my/startup-screen-render ()
  "Render the welcome screen content."
  (let ((inhibit-read-only t))
    (erase-buffer)
    (let* ((gol-lines (my/gol-render))
           (help-box '("┌────────────────────┐"
                       "│ Help      ;x ?     │"
                       "│ Project   ;x p w   │"
                       "│ Terminal  ;x t t   │"
                       "└────────────────────┘"))
           (projects-box (my/recent-projects-box))
           (gol-width (+ my/gol-width 2))
           (boxes-width (+ (length (car help-box)) 2 (length (car projects-box))))
           (total-height (+ (length gol-lines) 1 (max (length help-box) (length projects-box)))))
      ;; Center vertically
      (dotimes (_ (max 0 (/ (- (window-height) total-height) 2)))
        (insert "\n"))
      ;; Insert Game of Life centered
      (dolist (line gol-lines)
        (insert (make-string (max 0 (/ (- (window-width) gol-width) 2)) ?\s))
        (insert line "\n"))
      ;; Spacer
      (insert "\n")
      ;; Insert help and projects boxes side by side, centered
      (let ((left-margin (max 0 (/ (- (window-width) boxes-width) 2)))
            (help-len (length help-box))
            (proj-len (length projects-box)))
        (dotimes (i (max help-len proj-len))
          (insert (make-string left-margin ?\s))
          (insert (if (< i help-len) (nth i help-box) (make-string (length (car help-box)) ?\s)))
          (insert "  ")
          (insert (if (< i proj-len) (nth i projects-box) ""))
          (insert "\n"))))
    (goto-char (point-min))))

(defun my/gol-stop-timer ()
  "Stop Game of Life timer when buffer is killed."
  (when (and (string= (buffer-name) "*welcome*") my/gol-timer)
    (cancel-timer my/gol-timer)
    (setq my/gol-timer nil)))

(add-hook 'kill-buffer-hook #'my/gol-stop-timer)

(defun my/gol-reset ()
  "Reset Game of Life with new random state."
  (interactive)
  (my/gol-init)
  (my/startup-screen-render))

(defun my/open-recent-project (n)
  "Open the Nth recent project (1-indexed) as a workspace."
  (let ((projects (my/recent-projects-list)))
    (when (<= n (length projects))
      (my/open-project-workspace-at (nth (1- n) projects)))))

(defvar my/welcome-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "SPC") #'my/gol-reset)
    (define-key map (kbd "1") (lambda () (interactive) (my/open-recent-project 1)))
    (define-key map (kbd "2") (lambda () (interactive) (my/open-recent-project 2)))
    (define-key map (kbd "3") (lambda () (interactive) (my/open-recent-project 3)))
    (define-key map (kbd "4") (lambda () (interactive) (my/open-recent-project 4)))
    (define-key map (kbd "5") (lambda () (interactive) (my/open-recent-project 5)))
    map)
  "Keymap for welcome screen.")

(with-eval-after-load 'evil
  (evil-define-key '(normal motion) my/welcome-mode-map (kbd "SPC") #'my/gol-reset)
  (evil-define-key '(normal motion) my/welcome-mode-map (kbd "1") (lambda () (interactive) (my/open-recent-project 1)))
  (evil-define-key '(normal motion) my/welcome-mode-map (kbd "2") (lambda () (interactive) (my/open-recent-project 2)))
  (evil-define-key '(normal motion) my/welcome-mode-map (kbd "3") (lambda () (interactive) (my/open-recent-project 3)))
  (evil-define-key '(normal motion) my/welcome-mode-map (kbd "4") (lambda () (interactive) (my/open-recent-project 4)))
  (evil-define-key '(normal motion) my/welcome-mode-map (kbd "5") (lambda () (interactive) (my/open-recent-project 5))))

(defun my/startup-screen ()
  "Display a minimal welcome screen with Game of Life."
  (let ((buf (get-buffer-create "*welcome*")))
    (with-current-buffer buf
      (read-only-mode -1)
      (unless my/gol-grid (my/gol-init))
      (my/startup-screen-render)
      (read-only-mode 1)
      (use-local-map my/welcome-mode-map)
      ;; Start animation timer
      (when my/gol-timer (cancel-timer my/gol-timer))
      (setq my/gol-timer (run-with-timer 0.2 0.2 #'my/gol-update-display)))
    (switch-to-buffer buf)))

(defun my/help-screen ()
  "Display keybinding help in a new tab."
  (interactive)
  (tab-bar-new-tab)
  (let ((buf (get-buffer-create "*help-keys*")))
    (with-current-buffer buf
      (read-only-mode -1)
      (erase-buffer)
      (insert
       "KEYBINDINGS

; = Control (normal/visual mode)
  In normal mode, ; acts as Control prefix.
  Type ;; to insert a literal semicolon.

Navigation (evil)
  h j k l     Move left/down/up/right
  w b e       Word forward/back/end
  gg / G      Top / bottom of file
  C-u / C-d   Scroll half-page up/down
  /           Search forward
  n / N       Next/prev search result

Editing (evil)
  i / a / o   Insert / append / open line
  dd / yy / p Delete / yank / paste line
  ci\" / ca(   Change inside \" / around (
  u / ;r      Undo / redo
  v / V / ;v  Visual char/line/block

Files
  ;x ;f       Open file
  ;x ;s       Save file
  ;x k        Kill buffer
  ;x ;c       Quit Emacs

Windows
  ;w h/j/k/l  Switch window
  ;w c        Close window
  ;w s / ;w v Split horizontal / vertical
  ;w t / ;w T Terminal below / right
  ;w o        Only this window

Project
  ;x p w      Open project workspace
  ;x p f      Find file in project
  ;x p g      Find text in project
  ;x g        Magit (git)
  ;x b        Switch buffer (consult)

Tabs
  gt / gT     Next / previous tab
  1gt         Go to tab 1 (2gt for 2, etc.)
  ;x t 2      New tab
  ;x t 0      Close tab
  ;x t t      New tab with terminal
  ;x t o      New tab with org

Completion
  C-n / C-p   Next / previous candidate

Other
  ;g          Cancel / quit
  M-x         Execute command
  ;h k / ;h f Describe key / function
  ;x ?        This help screen

Mac keys: Command = Meta (M-), Option = Super (s-)
")
      (goto-char (point-min))
      (read-only-mode 1))
    (switch-to-buffer buf)))

(global-set-key (kbd "C-x ?") #'my/help-screen)
(setq initial-buffer-choice #'my/startup-screen)

;;; init.el ends here
