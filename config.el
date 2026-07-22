(defun my/org-babel-tangle-and-reload ()
  "Auto-tangle config.org, reload Doom, and notify."
  (when (string-equal (file-truename (buffer-file-name))
                    (file-truename (expand-file-name "config.org" doom-user-dir)))
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle)
      (condition-case err
          (progn
            (doom/reload)
            (message "Doom reloaded after tangling config.org at %s" (current-time-string)))
        (error
         (message "Reload failed: %s" (error-message-string err)))))))

(add-hook 'org-mode-hook
          (lambda ()
            (when (string-equal (buffer-file-name)
                                (expand-file-name "config.org" doom-user-dir))
              (add-hook 'after-save-hook #'my/org-babel-tangle-and-reload nil 'local))))

(setq user-full-name "Alan M."
      user-mail-address "alan.maciel.salcedo@gmail.com")

(setq projectile-project-search-path '("~/Projects" "~/Labs"))

(after! org
  (setq org-directory "~/org/")
  (setq org-agenda-files '("~/org/agenda.org"))
  (setq org-log-done 'note )
  )

;; Enable line highlight only in dashboard
;; (add-hook '+doom-dashboard-mode-hook #'hl-line-mode)
;; Dashboard: make keyboard selection look like mouse hover
;; Yellow bg + black text only on Doom dashboard, via overlay

;; (setq fancy-splash-image "~/dotfiles-local/emacs/doom.d/splash/lucky-doom-emacs-color.png")

(remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-banner)

(remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-footer)

(setq doom-theme 'doom-monokai-octagon
      doom-themes-treemacs-enable-variable-pitch nil)

;; (add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
;; (load-theme 'twilight t)
;; (setq doom-theme 'twilight)



(setq doom-font (font-spec :family "Iosevka Nerd Font" :size 18 )
      doom-big-font (font-spec :family "Iosevka Nerd Font" :size 24)
      doom-variable-pitch-font (font-spec :family "Overpass Nerd Font" :size 22)
      doom-serif-font (font-spec :family "BlexMono Nerd Font" :weight 'light :size 22))

(custom-set-faces!
  '(font-lock-comment-face :slant italic))

(custom-set-faces! '((corfu-popupinfo) :height 0.9))

(use-package! doom-modeline
  :config
  (setq doom-modeline-persp-name t))

(custom-set-faces!
  '(doom-modeline-buffer-modified :foreground "orange"))

(setq doom-modeline-height 30)

(defun doom-modeline-conditional-buffer-encoding ()
  "We expect the encoding to be LF UTF-8, so only show the modeline when this is not the case"
  (setq-local doom-modeline-buffer-encoding
              (unless (and (memq (plist-get (coding-system-plist buffer-file-coding-system) :category)
                                 '(coding-category-undecided coding-category-utf-8))
                           (not (memq (coding-system-eol-type buffer-file-coding-system) '(1 2))))
                t)))

(add-hook 'after-change-major-mode-hook #'doom-modeline-conditional-buffer-encoding)

(use-package! keycast
  :commands keycast-mode
  :config
  (define-minor-mode keycast-mode
    "Show current command and its key binding in the mode line."
    :global t
    (if keycast-mode
        (progn
          (add-hook 'pre-command-hook 'keycast--update t)
          (add-to-list 'global-mode-string '("" mode-line-keycast " ")))
      (remove-hook 'pre-command-hook 'keycast--update)
      (setq global-mode-string (remove '("" mode-line-keycast " ") global-mode-string))))
  (custom-set-faces!
    '(keycast-command :inherit doom-modeline-debug
                      :height 0.9)
    '(keycast-key :inherit custom-modified
                  :height 1.1
                  :weight bold)))

(beacon-mode 1)

(setq minimap-window-location 'right)
(map! :leader
      (:prefix ("t" . "toggle")
       :desc "Toggle minimap-mode" "M" #'minimap-mode))

  (setq display-line-numbers-type t)

  ;; Reusable helper: viewers (images, PDF, markdown prose) turn off line
  ;; numbers, which compete with the content on a small screen.
  (defun nb/no-line-numbers ()
    "Turn off line numbers in the current buffer."
    (display-line-numbers-mode -1))

(setq default-frame-alist '((width . 115)(height . 34)))

;; (add-to-list 'default-frame-alist '(alpha . 90))

(add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
(add-to-list 'default-frame-alist '(ns-appearance . dark))



(setq warning-minimum-level :emergency)

(setq google-translate-default-source-language "en")
(setq google-translate-default-target-language "es-MX")

;; Always use dwim:origin so Forge follows the branch’s upstream if set,
;; else defaults to "origin"
(setq forge-remote "dwim:origin")
;; (setq forge-remote "origin")
;; Pull only recent topics by default (1 month back)
(setq forge-pull-limit
      (time-subtract (current-time)
                     (days-to-time 30)))  ;; 30 days

(setq forge-topic-list-limit 50          ;; global maximum
      forge-topic-list-limit-per-repo 50) ;; maximum per repo

(setq treesit-language-source-alist
      '((javascript . "https://github.com/tree-sitter/tree-sitter-javascript")
        (jsdoc      . "https://github.com/tree-sitter/tree-sitter-jsdoc")
        (html       . "https://github.com/tree-sitter/tree-sitter-html")
        (css        . "https://github.com/tree-sitter/tree-sitter-css")
        (json       . "https://github.com/tree-sitter/tree-sitter-json")
        (ruby       . "https://github.com/tree-sitter/tree-sitter-ruby")))

(use-package! diff-hl
  :config
  (custom-set-faces!
    `((diff-hl-change)
      :foreground ,(doom-blend (doom-color 'bg) (doom-color 'blue) 0.5))
    `((diff-hl-insert)
      :foreground ,(doom-blend (doom-color 'bg) (doom-color 'green) 0.5)))
)

(after! projectile
  (defun open-projectile-with-magit (&optional DIRECTORY CACHE)
    (interactive)
    (magit-status DIRECTORY)
    (if (fboundp 'magit-fetch-from-upstream)
        (call-interactively #'magit-fetch-from-upstream)
      (call-interactively #'magit-fetch-current)))
  (setq +workspaces-switch-project-function #'open-projectile-with-magit))

(require 'key-chord)
(key-chord-mode t)
;; (key-chord-define-global "ue" 'evil-normal-state) ;; in DVORAK
;; (key-chord-define-global "UE" 'evil-normal-state) ;; in DVORAK
(key-chord-define-global "fd" 'evil-normal-state) ;; in QWERTY
(key-chord-define-global "FD" 'evil-normal-state) ;; in QWERTY

(after! projectile
  (setq projectile-globally-ignored-directories '("flow-typed" "node_modules" "~/.config/emacs/.local/" ".idea" ".vscode" ".ensime_cache" ".eunit" ".git" ".hg" ".fslckout" "_FOSSIL_" ".bzr" "_darcs" ".tox" ".svn" ".stack-work" ".ccls-cache" ".cache" ".clangd")))

;; (after! projectile-rails
;;   (doom-emacs-on-rails-add-custom-projectile-finder "services" "app/services/"  "\\(.+\\)\\.rb$" "app/services/${filename}.rb" "rt")
;;   (doom-emacs-on-rails-add-custom-projectile-finder "admin" "app/admin/"  "\\(.+\\)\\.rb$" "app/admin/${filename}.rb" "rt")
;;   (doom-emacs-on-rails-add-custom-projectile-finder "contracts" "app/contracts/"  "\\(.+\\)\\.rb$" "app/contracts/${filename}.rb" "rq"))

(after! org
  ;; Set some faces
  (custom-set-faces!
    `((org-quote)
      :foreground ,(doom-color 'blue) :extend t)
    `((org-block-begin-line org-block-end-line)
      :background ,(doom-color 'bg)))
  ;; Change how LaTeX and image previews are shown
  (setq org-highlight-latex-and-related '(native entities script)
        ;; GPD Micro PC: 720px portrait screen. A third of it (240px) is
        ;; unreadable, so we use 85% of the width capped at 800px.
        org-image-actual-width (min (round (* 0.85 (display-pixel-width))) 800)
        org-startup-with-inline-images t))

(after! org
  (custom-set-faces!
    `((org-document-title)
      :foreground ,(face-attribute 'org-document-title :foreground)
      :height 1.3 :weight bold)
    `((org-level-1)
      :foreground ,(face-attribute 'outline-1 :foreground)
      :height 1.1 :weight medium)
    `((org-level-2)
      :foreground ,(face-attribute 'outline-2 :foreground)
      :weight medium)
    `((org-level-3)
      :foreground ,(face-attribute 'outline-3 :foreground)
      :weight medium)
    `((org-level-4)
      :foreground ,(face-attribute 'outline-4 :foreground)
      :weight medium)
    `((org-level-5)
      :foreground ,(face-attribute 'outline-5 :foreground)
      :weight medium)))

(add-hook 'org-mode-hook 'org-indent-mode)
(use-package! org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(add-hook 'text-mode-hook (lambda () (hl-line-mode -1)))

(use-package! svg-tag-mode
  :config
  (defconst date-re "[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}")
  (defconst time-re "[0-9]\\{2\\}:[0-9]\\{2\\}")
  (defconst day-re "[A-Za-z]\\{3\\}")
  (defconst day-time-re (format "\\(%s\\)? ?\\(%s\\)?" day-re time-re))

  (defun svg-progress-percent (value)
    (svg-image (svg-lib-concat
                (svg-lib-progress-bar
                 (/ (string-to-number value) 100.0) nil
                 :height 0.8 :foreground (doom-color 'fg) :background (doom-color 'bg)
                 :margin 0 :stroke 2 :radius 3 :padding 2 :width 11)
                (svg-lib-tag (concat value "%") nil
                             :height 0.8 :foreground (doom-color 'fg) :background (doom-color 'bg)
                             :stroke 0 :margin 0)) :ascent 'center))

  (defun svg-progress-count (value)
    (let* ((seq (mapcar #'string-to-number (split-string value "/")))
           (count (float (car seq)))
           (total (float (cadr seq))))
      (svg-image (svg-lib-concat
                  (svg-lib-progress-bar (/ count total) nil
                                        :foreground (doom-color 'fg)
                                        :background (doom-color 'bg) :height 0.8
                                        :margin 0 :stroke 2 :radius 3 :padding 2 :width 11)
                  (svg-lib-tag value nil
                               :foreground (doom-color 'fg)
                               :background (doom-color 'bg)
                               :stroke 0 :margin 0 :height 0.8)) :ascent 'center)))

  (set-face-attribute 'svg-tag-default-face nil :family "Alegreya Sans")
  (setq svg-tag-tags
        `(;; Progress e.g. [63%] or [10/15]
          ("\\(\\[[0-9]\\{1,3\\}%\\]\\)" . ((lambda (tag)
                                            (svg-progress-percent (substring tag 1 -2)))))
          ("\\(\\[[0-9]+/[0-9]+\\]\\)" . ((lambda (tag)
                                            (svg-progress-count (substring tag 1 -1)))))
          ;; Task priority e.g. [#A], [#B], or [#C]
          ("\\[#A\\]" . ((lambda (tag) (svg-tag-make tag :face 'error :inverse t :height .85
                                                     :beg 2 :end -1 :margin 0 :radius 10))))
          ("\\[#B\\]" . ((lambda (tag) (svg-tag-make tag :face 'warning :inverse t :height .85
                                                     :beg 2 :end -1 :margin 0 :radius 10))))
          ("\\[#C\\]" . ((lambda (tag) (svg-tag-make tag :face 'org-todo :inverse t :height .85
                                                     :beg 2 :end -1 :margin 0 :radius 10))))
          ;; Keywords
          ("TODO" . ((lambda (tag) (svg-tag-make tag :inverse t :height .85 :face 'org-todo))))
          ("HOLD" . ((lambda (tag) (svg-tag-make tag :height .85 :face 'org-todo))))
          ("DONE\\|STOP" . ((lambda (tag) (svg-tag-make tag :inverse t :height .85 :face 'org-done))))
          ("NEXT\\|WAIT" . ((lambda (tag) (svg-tag-make tag :inverse t :height .85 :face '+org-todo-active))))
          ("REPEAT\\|EVENT\\|PROJ\\|IDEA" .
           ((lambda (tag) (svg-tag-make tag :inverse t :height .85 :face '+org-todo-project))))
          ("REVIEW" . ((lambda (tag) (svg-tag-make tag :inverse t :height .85 :face '+org-todo-onhold))))))
  :hook (org-mode . svg-tag-mode)
)

  (defun org-agenda-show-svg ()
    (let* ((case-fold-search nil)
           (keywords (mapcar #'svg-tag--build-keywords svg-tag--active-tags))
           (keyword (car keywords)))
      (while keyword
        (save-excursion
          (while (re-search-forward (nth 0 keyword) nil t)
            (overlay-put (make-overlay
                          (match-beginning 0) (match-end 0))
                         'display  (nth 3 (eval (nth 2 keyword)))) ))
        (pop keywords)
        (setq keyword (car keywords)))))
  (add-hook 'org-agenda-finalize-hook #'org-agenda-show-svg)

(use-package! org-modern
  :hook (org-mode . org-modern-mode)
  :config
  (setq
   ;; Edit settings
   org-catch-invisible-edits 'show-and-error
   org-special-ctrl-a/e t
   org-insert-heading-respect-content t
   ;; Appearance
   org-modern-radio-target    '("❰" t "❱")
   org-modern-internal-target '("↪ " t "")
   org-modern-todo nil
   org-modern-tag nil
   org-modern-timestamp t
   org-modern-statistics nil
   org-modern-progress nil
   org-modern-priority nil
   org-modern-horizontal-rule "──────────"
   org-modern-hide-stars "·"
   org-modern-star ["⁖"]
   org-modern-keyword "‣"
   org-modern-list '((43 . "•")
                     (45 . "–")
                     (42 . "↪")))
  (custom-set-faces!
    `((org-modern-tag)
      :background ,(doom-blend (doom-color 'blue) (doom-color 'bg) 0.1)
      :foreground ,(doom-color 'grey))
    `((org-modern-radio-target org-modern-internal-target)
      :inherit 'default :foreground ,(doom-color 'blue)))
  )

;; (use-package! org-appear
;;   :hook
;;   (org-mode . org-appear-mode)
;;   :config
;;   (setq org-hide-emphasis-markers t
;;         org-appear-autolinks 'just-brackets))

(setq org-journal-date-prefix "#+TITLE: "
 org-journal-time-prefix "* "
 org-journal-date-format "%a, %Y-%m-%d"
 org-journal-file-format "%Y-%m-%d.org")

(use-package! org-roam
  :custom
  (org-roam-directory (file-truename "~/roam"))
  :config
  (setq org-roam-node-display-template
        (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
  (org-roam-db-autosync-mode)
  (require 'org-roam-protocol))

(after! org-agenda
  (require 'org-super-agenda)
  (org-super-agenda-mode)
  (setq org-agenda-custom-commands
        '(("o" "Overview"
           ((alltodo ""
                     ((org-super-agenda-groups
                       '((:name "Today" :scheduled today)
                         (:name "Overdue" :deadline past)
                         (:name "Due Soon" :deadline future)
                         (:name "Important" :priority "A"))))))))))

(after! org-roam
  (map!
   ;; Org-roam core
   "C-c n l" #'org-roam-buffer-toggle
   "C-c n f" #'org-roam-node-find
   "C-c n g" #'org-roam-graph
   "C-c n i" #'org-roam-node-insert
   "C-c n c" #'org-roam-capture
   ;; Dailies
   "C-c n j" #'org-roam-dailies-capture-today
   ;; Completion
   "C-M-i"   #'completion-at-point))

(setq frame-title-format
      '(""
        (:eval
         (let ((bf (or buffer-file-name "")))
           (if (and (bound-and-true-p org-roam-directory)
                    (string-match-p
                     (regexp-quote (file-truename (expand-file-name org-roam-directory)))
                     (file-truename bf)))
               (replace-regexp-in-string
                ".*/[0-9]*-?" "☰ "
                (subst-char-in-string ?_ ?\s bf))
             "%b")))
        (:eval
         (when-let ((project-name (and (featurep 'projectile) (projectile-project-name))))
           (unless (string= "-" project-name)
             (format (if (buffer-modified-p) " ◉ %s" "  ●  %s") project-name))))))

(use-package! websocket
    :after org-roam)

(use-package! org-roam-ui
    :after org-roam ;; or :after org
;;         normally we'd recommend hooking orui after org-roam, but since org-roam does not have
;;         a hookable mode anymore, you're advised to pick something yourself
;;         if you don't care about startup time, use
;; :hook (after-init . org-roam-ui-mode)
    :config
    (setq org-roam-ui-sync-theme t
          org-roam-ui-follow t
          org-roam-ui-update-on-save t
          org-roam-ui-open-on-start t))

(add-to-list 'display-buffer-alist
             '("\\*org-roam\\*"
               (display-buffer-in-side-window)
               (side . right)
               (slot . 0)
               (window-width . 0.33)
               (window-parameters . ((no-other-window . t)
                                     (no-delete-other-windows . t)))))

;; Markdown beautification
(after! markdown-mode
  ;; setq-default is required because markdown-mode uses make-variable-buffer-local,
  ;; which makes setq affect only the current buffer, not every future buffer
  (setq-default markdown-fontify-whole-heading-line nil)
  (setq-default markdown-hide-markup               t)
  (setq-default markdown-hide-urls                 t)

  ;; --- Markdown: size/weight/style only; font and colors come from the theme ---
  ;; No concrete family is named, and no foreground/background: only size
  ;; (:height), weight (:weight) and style (italic, underline…). Code and
  ;; tables inherit `fixed-pitch` (the theme's mono) so they align well; prose
  ;; uses doom-font, and colors/backgrounds come from the active doom-theme.
  (custom-set-faces!
    ;; Links
    '(markdown-link-face           :underline t)
    '(markdown-url-face            :height 0.85)
    ;; Strikethrough
    '(markdown-strike-through-face :height 0.85 :strike-through t :weight normal :slant normal)
    ;; Bold/Italic
    '(markdown-bold-face           :weight bold)
    '(markdown-italic-face         :slant italic)
    ;; Inline code — fixed-pitch guarantees monospace without naming a family
    '(markdown-inline-code-face    :inherit fixed-pitch :background "black" :weight normal)
    ;; Code blocks — black background
    '(markdown-pre-face            :inherit (fixed-pitch) :background "black" :extend t :weight normal)
    '(markdown-code-face           :inherit (fixed-pitch) :background "black" :extend t :weight normal)
    ;; Headers — monotonically decreasing scale; the color is set by the theme.
    '(markdown-header-delimiter-face :height 0.9)
    '(markdown-header-face-1 :height 1.5  :weight extra-bold :inherit markdown-header-face)
    '(markdown-header-face-2 :height 1.3  :weight extra-bold :inherit markdown-header-face)
    '(markdown-header-face-3 :height 1.15 :weight extra-bold :inherit markdown-header-face)
    '(markdown-header-face-4 :height 1.05 :weight bold       :inherit markdown-header-face)
    '(markdown-header-face-5 :height 1.0  :weight bold       :inherit markdown-header-face)
    '(markdown-header-face-6 :height 0.9  :weight semi-bold  :inherit markdown-header-face)
    ;; Blockquotes
    '(markdown-blockquote-face     :slant italic :extend t)
    ;; Tables — fixed-pitch for pixel-aligned columns (with valign), at the
    ;; same size as the body (no :height, inherited from fixed-pitch)
    '(markdown-table-face          :inherit fixed-pitch :weight normal))

  ;; Body size and line spacing only; the font family and the colors are left
  ;; to the active doom-font and doom-theme.
  (defun nb/markdown-warm-theme ()
    "Adjust size and line spacing of the markdown buffer (font and colors from the theme)."
    ;; Body at ~18pt: good density and line length on the 720px screen.
    ;; No line-spacing: valign ignores it and would cut the Unicode bars of the
    ;; tables (fancy-bar needs the rows to touch).
    (face-remap-add-relative 'default
      :height 180)
    ;; No line numbers
    (display-line-numbers-mode -1)
    ;; Drop transparency in markdown
    (set-frame-parameter nil 'alpha-background 100)
)

  ;; --- Olivetti: centered text, comfortable width for reading ---
  (require 'olivetti)
  (defun nb/markdown-olivetti ()
    "Enable olivetti to center markdown text."
    (olivetti-mode 1)
    (olivetti-set-width 80))
  (add-hook 'markdown-mode-hook #'nb/markdown-olivetti)

  ;; --- Reveal markup on the current line (### ** etc.) ---
  (defvar-local nb/markdown-shown-line-beg nil
    "Start position of the line currently showing raw markup.")

  (defun nb/on-table-line-p ()
    "Non-nil if the current line is a markdown table row."
    (save-excursion
      (beginning-of-line)
      (looking-at "[[:space:]]*|")))

  (defun nb/refontify-line (line-beg)
    "Re-apply font-lock to the line starting at LINE-BEG to hide the markup again."
    (when (and line-beg
               (integer-or-marker-p line-beg)
               (>= line-beg (point-min))
               (<= line-beg (point-max)))
      (save-excursion
        (goto-char line-beg)
        (font-lock-fontify-region (line-beginning-position)
                                  (line-end-position)))))

  (defun nb/unhide-current-line ()
    "Show markdown markup on the current line; hide it again when point moves away.
Ignores table lines — valign handles their display."
    (unless (minibufferp)
      (let ((cur-beg (line-beginning-position)))
        (unless (equal cur-beg nb/markdown-shown-line-beg)
          ;; Hide the previous line again
          (nb/refontify-line nb/markdown-shown-line-beg)
          ;; On table lines, touch nothing (valign uses display properties)
          (if (nb/on-table-line-p)
              (setq nb/markdown-shown-line-beg nil)
            ;; On other lines, reveal the markup
            (with-silent-modifications
              (remove-text-properties cur-beg (line-end-position)
                                      '(invisible nil display nil composition nil)))
            (setq nb/markdown-shown-line-beg cur-beg))))))

  (defun nb/markdown-setup ()
    "Per-buffer setup for markdown."
    (setq-local nb/markdown-shown-line-beg nil)
    (add-hook 'post-command-hook #'nb/unhide-current-line nil t))

  ;; --- Valign: pixel-perfect tables with fancy bars ---
  (require 'valign)
  (setq valign-fancy-bar t)

  (defun nb/valign-setup ()
    "Enable valign with fancy bars and force alignment."
    (valign-mode 1)
    (run-with-idle-timer 0.5 nil
      (lambda (buf)
        (when (buffer-live-p buf)
          (with-current-buffer buf
            (valign-region (point-min) (point-max)))))
      (current-buffer)))

  ;; --- Unified setup ---
  ;; A single hook with an explicit order, instead of six loose add-hooks whose
  ;; sequence depended on depth/append. The order matters:
  ;; warm-theme + olivetti fix the window width BEFORE the inline images are
  ;; measured; valign runs last, over the already-rendered tables.
  (defun nb/markdown-mode-setup ()
    "Per-buffer configuration for markdown, in a deterministic order."
    (nb/markdown-warm-theme)
    (abbrev-mode 1)
    (nb/markdown-olivetti)
    (nb/markdown-setup)
    (nb/markdown-show-inline-images)
    (nb/valign-setup))

  (add-hook 'markdown-mode-hook #'nb/markdown-mode-setup))

;; Emojis :smile: :wink: etc
(use-package! emojify
  :hook (markdown-mode . emojify-mode)
  :config
  (setq emojify-emoji-styles '(github))
  (setq emojify-display-style 'unicode))

(after! markdown-mode
  ;; (width . height) in pixels; nil = no limit on that axis.
  ;; Note: display-pixel-width is captured when markdown loads; on this machine
  ;; (GPD Micro PC, fixed screen) that is correct. With an external monitor it
  ;; would need to be re-evaluated after connecting.
  (setq markdown-max-image-size
        (cons (round (* 0.85 (display-pixel-width))) nil))

  (defun nb/markdown-show-inline-images ()
    "Show inline images in markdown, without failing when there is no graphical support."
    (when (display-images-p)
      (ignore-errors (markdown-display-inline-images)))))

(if (require 'toc-org nil t)
    (progn
      (add-hook 'org-mode-hook #'toc-org-mode)
      ;; enable in markdown, too
      (add-hook 'markdown-mode-hook #'toc-org-mode)
      (after! markdown-mode
        (map! :map markdown-mode-map
              "C-c C-o" #'toc-org-markdown-follow-thing-at-point)))
  (display-warning 'doom-config "toc-org not found" :emergency))

(use-package! toc-org
  :commands toc-org-enable
  :init
  (add-hook 'org-mode-hook #'toc-org-enable))

(after! image-mode
  ;; 'fit-window shrinks too much on a 720px-wide screen;
  ;; 'fit-width uses all the available horizontal space.
  (setq image-auto-resize 'fit-width
        image-auto-resize-on-window-resize 1
        ;; Animated GIFs loop indefinitely
        image-animate-loop t)

  ;; No line numbers: they compete with the image on a small screen
  (add-hook 'image-mode-hook #'nb/no-line-numbers))

;; locate-library instead of require: it answers "is it installed?" without
;; loading pdf-tools, preserving the module's lazy loading via :mode/:magic.
(if (locate-library "pdf-tools")
    (progn
      ;; Use the epdfinfo from Nix. executable-find avoids hardcoding a store
      ;; path, which changes on every nixpkgs update.
      (after! pdf-info
        (let ((nix-epdfinfo (executable-find "epdfinfo")))
          (when nix-epdfinfo
            (setq pdf-info-epdfinfo-program nix-epdfinfo))))

      (after! pdf-view
        ;; Doom sets 'fit-page; on a portrait screen it reads better fit to width.
        ;; pdf-view-use-scaling (HiDPI) is already enabled by Doom.
        (setq-default pdf-view-display-size 'fit-width)
        (setq pdf-view-continuous t
              pdf-view-resize-factor 1.1)

        ;; Midnight mode so it matches the dark theme.
        ;; setq! (not setq) is mandatory: Doom installs a 'custom-set on this
        ;; variable that re-renders already-open buffers.
        (setq! pdf-view-midnight-colors
               (cons (doom-color 'fg) (doom-color 'bg)))
        (add-hook 'pdf-view-mode-hook #'pdf-view-midnight-minor-mode)

        ;; No line numbers in the viewer
        (add-hook 'pdf-view-mode-hook #'nb/no-line-numbers)))
  (display-warning 'doom-config
                   "pdf-tools not found: enable the `pdf' module in init.el and run `doom sync'"
                   :emergency))

;; :defer + :commands => it autoloads when the menu is invoked, instead of
;; loading on every startup. The define-keys below only store the command
;; symbol; the first keypress triggers the autoload.
(use-package! claudemacs
  :defer t
  :commands (claudemacs-transient-menu claudemacs-transient))
(use-package! eat
  :defer t)

(use-package! claudemacs
  :after eat)

(define-key prog-mode-map (kbd "C-c C-e") #'claudemacs-transient-menu)
(define-key emacs-lisp-mode-map (kbd "C-c C-e") #'claudemacs-transient-menu)
(define-key text-mode-map (kbd "C-c C-e") #'claudemacs-transient-menu)
(with-eval-after-load 'python
  (define-key python-base-mode-map (kbd "C-c C-e") #'claudemacs-transient-menu))

;; Set a big buffer so we can search our history.
(with-eval-after-load 'eat
  (setq eat-term-scrollback-size 400000))

;; If you want it to pop up as a new buffer. Otherwise, it will use "other buffer."
;; Personally, I use the default "other buffer" style.
(add-to-list 'display-buffer-alist
             '("^\\*claudemacs"
               (display-buffer-in-side-window)
               (side . right)
               (window-width . 0.33)))

;; Turn on autorevert because Claude modifies and saves buffers. Make it a habit to save
;; before asking Claude anything, because it uses the file on disk as its source of truth.
;; (And you don't want to lose edits after it modifies and saves the files.)
(global-auto-revert-mode t)


;;
;; font insanity for Claudemacs
;;
(defun my/setup-custom-font-fallbacks-mac ()
  (interactive)
  "Configure font fallbacks on mac for symbols and emojis.
This will need to be called every time you change your font size,
to load the new symbol and emoji fonts."

  (setq use-default-font-for-symbols nil)

  ;; --- Configure for 'symbol' script ---
  ;; We add fonts one by one. Since we use 'prepend',
  ;; the last one added here will be the first one Emacs tries.
  ;; So, list them in reverse order of your preference.

  ;; Least preferred among this list for symbols (will be at the end of our preferred list)
  (set-fontset-font t 'symbol "Hiragino Sans" nil 'prepend)
  (set-fontset-font t 'symbol "STIX Two Math" nil 'prepend)
  (set-fontset-font t 'symbol "Zapf Dingbats" nil 'prepend)
  (set-fontset-font t 'symbol "Monaco" nil 'prepend)
  (set-fontset-font t 'symbol "Menlo" nil 'prepend)
  ;; Most preferred for symbols -- use your main font here
  (set-fontset-font t 'symbol "JetBrainsMono Nerd Font Mono" nil 'prepend)


  ;; --- Configure for 'emoji' script ---
  ;; Add fonts one by one, in reverse order of preference.

  ;; Least preferred among this list for emojis
  (set-fontset-font t 'emoji "Hiragino Sans" nil 'prepend)
  (set-fontset-font t 'emoji "STIX Two Math" nil 'prepend)
  (set-fontset-font t 'emoji "Zapf Dingbats" nil 'prepend)
  (set-fontset-font t 'emoji "Monaco" nil 'prepend)
  (set-fontset-font t 'emoji "Menlo" nil 'prepend)
  ;; (set-fontset-font t 'emoji "Noto Emoji" nil 'prepend) ;; If you install Noto Emoji
  ;; Most preferred for emojis -- use your main font here
  (set-fontset-font t 'emoji "JetBrainsMono Nerd Font Mono" nil 'prepend))

;; to test if you have a font family installed:
;   (find-font (font-spec :family "Menlo"))

;; Then, add the fonts after your setup is complete:
(add-hook 'emacs-startup-hook
          (lambda ()
            (progn
              (when (string-equal system-type "darwin")
                (my/setup-custom-font-fallbacks-mac)))))

(setq treesit-language-source-alist
      '((javascript . "https://github.com/tree-sitter/tree-sitter-javascript")
        (jsdoc      . "https://github.com/tree-sitter/tree-sitter-jsdoc")
        (html       . "https://github.com/tree-sitter/tree-sitter-html")
        (css        . "https://github.com/tree-sitter/tree-sitter-css")
        (json       . "https://github.com/tree-sitter/tree-sitter-json")
        (ruby       . "https://github.com/tree-sitter/tree-sitter-ruby")))
