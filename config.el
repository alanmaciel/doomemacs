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



(setq doom-font (font-spec :family "Iosevka Nerd Font" :size 14)
      doom-big-font (font-spec :family "Iosevka Nerd Font" :size 18)
      doom-variable-pitch-font (font-spec :family "Overpass Nerd Font" :size 10)
      doom-serif-font (font-spec :family "BlexMono Nerd Font" :weight 'light :size 10))

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

(setq default-frame-alist '((width . 115)(height . 34)))

(add-to-list 'default-frame-alist '(alpha . 90))

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

(setq forge-topic-list-limit 100          ;; máximo global
      forge-topic-list-limit-per-repo 50) ;; máximo por repo

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

;; (after! projectile-rails
;;   ;; Example: switch from app/contracts/{resource}.rb to app/services/{resource} and vice-versa
;;   (defun projectile-rails-find-contract ()
;;     "Switch from contract to service and vice versa."
;;     (interactive)
;;     (if (string-match-p "app/contracts" (buffer-file-name)) (find-file (replace-regexp-in-string "contract" "service" (replace-regexp-in-string "_contracts" "_services" (buffer-file-name))))
;;       (find-file (replace-regexp-in-string "service" "contract" (replace-regexp-in-string "_services" "_contracts" (buffer-file-name))))))
;;   (map! :leader "rQ" #'projectile-rails-find-contract) ;; Uncomment to bind to SPC r q
;;   )

(require 'key-chord)
(key-chord-mode t)
;; (key-chord-define-global "ue" 'evil-normal-state) ;; in DVORAK
;; (key-chord-define-global "UE" 'evil-normal-state) ;; in DVORAK
(key-chord-define-global "fd" 'evil-normal-state) ;; in QWERTY
(key-chord-define-global "FD" 'evil-normal-state) ;; in QWERTY

(after! projectile
  (setq projectile-globally-ignored-directories '("flow-typed" "node_modules" "~/.config/emacs/.local/" ".idea" ".vscode" ".ensime_cache" ".eunit" ".git" ".hg" ".fslckout" "_FOSSIL_" ".bzr" "_darcs" ".tox" ".svn" ".stack-work" ".ccls-cache" ".cache" ".clangd")))

(after! projectile-rails
  (doom-emacs-on-rails-add-custom-projectile-finder "services" "app/services/"  "\\(.+\\)\\.rb$" "app/services/${filename}.rb" "rt")
  (doom-emacs-on-rails-add-custom-projectile-finder "admin" "app/admin/"  "\\(.+\\)\\.rb$" "app/admin/${filename}.rb" "rt")
  (doom-emacs-on-rails-add-custom-projectile-finder "contracts" "app/contracts/"  "\\(.+\\)\\.rb$" "app/contracts/${filename}.rb" "rq"))

(after! org
  ;; Set some faces
  (custom-set-faces!
    `((org-quote)
      :foreground ,(doom-color 'blue) :extend t)
    `((org-block-begin-line org-block-end-line)
      :background ,(doom-color 'bg)))
  ;; Change how LaTeX and image previews are shown
  (setq org-highlight-latex-and-related '(native entities script)
        org-image-actual-width (min (/ (display-pixel-width) 3) 800)))

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

(setq svg-tag-tags
      '((":TODO:" . ((lambda (tag) (svg-tag-make "TODO"))))))
(setq svg-tag-tags
      '((":HELLO:" .  ((lambda (tag) (svg-tag-make "HELLO"))
                       (lambda () (interactive) (message "Hello world!"))
                       "Print a greeting message"))))
(setq svg-tag-tags
      '((":TODO:" . ((lambda (tag) (svg-tag-make tag))))))
(setq svg-tag-tags
      '(("\\(:[A-Z]+:\\)" . ((lambda (tag)
                               (svg-tag-make tag :beg 1 :end -1))))))
(setq svg-tag-tags
      '(("\\(:[A-Z]+\\)\\|[a-zA-Z#0-9]+:" . ((lambda (tag)
                                              (svg-tag-make tag :beg 1 :inverse t
                                                            :margin 0 :crop-right t))))
        (":[A-Z]+\\(\\|[a-zA-Z#0-9]+:\\)" . ((lambda (tag)
                                              (svg-tag-make tag :beg 1 :end -1
                                                            :margin 0 :crop-left t))))))
(setq svg-tag-tags
      '(("\\(:#[A-Za-z0-9]+\\)" . ((lambda (tag)
                                     (svg-tag-make tag :beg 2))))
        ("\\(:#[A-Za-z0-9]+:\\)$" . ((lambda (tag)
                                       (svg-tag-make tag :beg 2 :end -1))))))

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
           (if (or (and (bound-and-true-p org-roam-directory)
                        (string-match-p
                         (regexp-quote (file-truename (expand-file-name org-roam-directory)))
                         (file-truename bf)))
                   (string-match-p
                    (regexp-quote (file-truename "~/RoamNotes"))
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

(if (require 'toc-org nil t)
    (progn
      (add-hook 'org-mode-hook #'toc-org-mode)
      ;; enable in markdown, too
      (add-hook 'markdown-mode-hook #'toc-org-mode)
      (after! markdown-mode
        (map! :map markdown-mode-map
              "C-c C-o" #'toc-org-markdown-follow-thing-at-point)))
  (warn "toc-org not found"))

(use-package! toc-org
  :commands toc-org-enable
  :init
  (add-hook 'org-mode-hook #'toc-org-enable))

(use-package! claudemacs)

(require 'claudemacs)
(define-key prog-mode-map (kbd "C-c C-e") #'claudemacs-transient-menu)
(define-key emacs-lisp-mode-map (kbd "C-c C-e") #'claudemacs-transient-menu)
(define-key text-mode-map (kbd "C-c C-e") #'claudemacs-transient-menu)
(with-eval-after-load 'python
  (define-key python-base-mode-map (kbd "C-c C-e") #'claudemacs-transient))

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
