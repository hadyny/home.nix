;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-
;;(setenv "LSP_USE_PLISTS" "true")
;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")
(setq user-full-name "Hadyn Youens"
      user-mail-address "hadyn.youens@educationperfect.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;

(setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
      doom-themes-enable-italic t)

(custom-set-faces!
  '(font-lock-comment-face :slant italic)
  '(font-lock-keyword-face :slant italic))

;; (setq doom-themes-treemacs-theme "doom-atom")
;; (doom-themes-treemacs-config)

(setq doom-themes-padded-modeline t)
(setq doom-theme 'catppuccin)

(setq doom-font (font-spec :family "GeistMono Nerd Font Propo" :size 13)
      doom-big-font (font-spec :family "Source Code Pro" :size 24)
      doom-symbol-font (font-spec :family "Symbols Nerd Font Mono"))

(setq-default line-spacing 0.33)

;; Prevents some cases of Emacs flickering.
(add-to-list 'default-frame-alist '(inhibit-double-buffering . t))

(use-package! exec-path-from-shell
  :init (exec-path-from-shell-initialize))

;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
                                        ;
;; (defun my/apply-theme (appearance)
;;   "Load theme, taking current system APPEARANCE into consideration."
;;   (mapc #'disable-theme custom-enabled-themes)
;;   (pcase appearance
;;     ('light (setq catppuccin-flavor 'latte)
;;             (catppuccin-reload))
;;     ('dark (setq catppuccin-flavor 'mocha)
;;            (catppuccin-reload))))

;; (add-hook 'ns-system-appearance-change-functions #'my/apply-theme)

;; (setq catppuccin-flavor 'mocha)
;; (setq doom-theme 'catppuccin)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type nil)

;;; :tools lsp
;; Disable invasive lsp-mode features
(after! lsp-mode
  (add-hook 'csharp-mode-hook #'lsp-deferred)
  (add-hook 'tsx-ts-mode-hook #'lsp-deferred)
  (add-hook 'typescript-ts-mode-hook #'lsp-deferred)
  (setq lsp-enable-symbol-highlighting nil
        ;; If an LSP server isn't present when I start a prog-mode buffer, you
        ;; don't need to tell me. I know. On some machines I don't care to have
        ;; a whole development environment for some ecosystems.
        lsp-enable-suggest-server-download t))

(after! lsp-ui
  (setq lsp-ui-sideline-show-diagnostics t)
  (setq lsp-ui-sideline-delay 0.5)
  (setq lsp-auto-execute-action nil))

;; Auto install treesitter grammars
(use-package! treesit-auto
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(setq treesit-font-lock-level 4)

(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1))

;; formats the buffer before saving
(add-hook 'before-save-hook 'tide-format-before-save)

;; if you use treesitter based typescript-ts-mode (emacs 29+)
(add-hook 'typescript-ts-mode-hook #'setup-tide-mode)
(add-hook 'tsx-ts-mode-hook #'setup-tide-mode)

(use-package! tide
  :ensure t
  :after (flycheck)
  :hook ((typescript-ts-mode . tide-setup)
         (tsx-ts-mode . tide-setup)
         (typescript-ts-mode . tide-hl-identifier-mode)
         (before-save . tide-format-before-save)))

(add-to-list 'auto-mode-alist '("\\.ts.*$" . typescript-ts-mode))
(add-to-list 'auto-mode-alist '("\\.tsx$" . tsx-ts-mode))

(add-to-list 'auto-mode-alist '("\\.cs$" . csharp-mode))

(add-to-list 'auto-mode-alist '("\\.nix\\'" . nix-ts-mode))

;;; :tools magit
(setq ;;magit-repository-directories '(("~/src" . 2)("~/src/ep", 3))
 magit-save-repository-buffers nil
 ;; Don't restore the wconf after quitting magit, it's jarring
 magit-inhibit-save-previous-winconf t
 evil-collection-magit-want-horizontal-movement t
 transient-values '((magit-rebase "--autosquash" "--autostash")
                    (magit-pull "--rebase" "--autostash")
                    (magit-revert "--autostash")))

;;; :ui doom-dashboard
(setq fancy-splash-image (file-name-concat doom-user-dir "splash.png"))
;; Hide the menu for as minimalistic a startup screen as possible.
(setq +doom-dashboard-functions '(doom-dashboard-widget-banner))

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

(setq doom-modeline-modal nil)

(setq treemacs-position 'right)

(setq dired-use-ls-dired nil)

(fringe-mode '(40 . 40))

;; Focus new window after splitting
(setq evil-split-window-below t
      evil-vsplit-window-right t)

(use-package! lsp-tailwindcss 
  :init
  (setq lsp-tailwindcss-add-on-mode t
        lsp-tailwindcss-emmet-completions t
        lsp-tailwindcss-skip-config-check t)
  :config
  (add-to-list 'lsp-tailwindcss-major-modes 'typescript-ts-mode :append)
  (add-to-list 'lsp-tailwindcss-major-modes 'tsx-ts-mode :append))

;; (use-package! copilot
;;   :hook (prog-mode . copilot-mode)
;;   :bind (:map copilot-completion-map
;;               ("<tab>" . 'copilot-accept-completion)
;;               ("TAB" . 'copilot-accept-completion)
;;               ("C-TAB" . 'copilot-accept-completion-by-word)
;;               ("C-<tab>" . 'copilot-accept-completion-by-word)))

(setq confirm-kill-emacs nil)
(setq auto-save-default nil
      make-backup-files nil)

;; Disable some ligatures
(plist-put! +ligatures-extra-symbols
            :and           nil
            :or            nil
            :for           nil
            :not           nil
            :true          nil
            :false         nil
            :int           nil
            :float         nil
            :str           nil
            :bool          nil
            :list          nil
            )
(let ((ligatures-to-disable '(:true :false :int :float :str :bool :list :and :or :for :not)))
  (dolist (sym ligatures-to-disable)
    (plist-put! +ligatures-extra-symbols sym nil)))

;;Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
