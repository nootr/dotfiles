;;; early-init.el --- Pre-GUI initialization -*- lexical-binding: t; -*-

;; Suppress GUI chrome before frame draws (avoids flicker)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(fullscreen . maximized) default-frame-alist)

;; Don't activate packages before init.el loads
(setq package-enable-at-startup nil)

;; Mac key mapping: Command = Meta, Option = Super
(setq mac-command-modifier 'meta)
(setq mac-option-modifier 'super)

;;; early-init.el ends here
