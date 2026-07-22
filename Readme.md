# Doom Emacs Configuration

Personal [Doom Emacs](https://github.com/doomemacs/doomemacs) configuration, tuned for a
**GPD Micro PC** running NixOS — a 720×1280 screen rotated to portrait. Most of the layout
decisions here (image widths, PDF fit mode, markdown line length, line-number toggles) exist
because of that narrow, vertical display.

This repo is consumed as a git submodule of the NixOS config
(`nixos-config/dotfiles/doom`), which symlinks it to `~/.config/doom` (`$DOOMDIR`).

## Literate configuration

`config.org` is the source of truth. `config.el` is **generated** — don't edit it by hand.

Saving `config.org` triggers `my/org-babel-tangle-and-reload`, which tangles every
`emacs-lisp` block into `config.el` and then calls `doom/reload`, so changes take effect
without restarting Emacs.

If the tangle doesn't fire, press `C-c C-c` on the `#+PROPERTY:` line at the top of
`config.org` to re-read the file-local settings.

## Files

| File | Role |
| --- | --- |
| `config.org` | Literate source — edit this |
| `config.el` | Tangled output — generated, do not edit |
| `init.el` | Doom modules enabled and their flags |
| `packages.el` | Extra packages beyond Doom's defaults |
| `custom.el` | `custom-set-variables` output (safe themes, etc.) |

## Requirements

- Emacs 30+
- Doom Emacs installed and on `PATH` (`doom sync`, `doom doctor`)
- Nerd Fonts: **Iosevka** (fixed pitch), **Overpass** (variable pitch), **BlexMono** (serif)
- `epdfinfo` on `PATH` for `pdf-tools` — provided by Nix; the config resolves it with
  `executable-find` instead of hardcoding a store path
- Build toolchain for `vterm` (gcc, cmake, make)

## Setup

```bash
# from the parent NixOS config, if using it as a submodule
git submodule update --init dotfiles/doom

# otherwise, point DOOMDIR at this repo
git clone git@github.com:alanmaciel/doomemacs.git ~/.config/doom

doom sync
doom doctor   # verify fonts, epdfinfo and language servers
```

After editing `init.el` or `packages.el`, run `doom sync` and restart Emacs. Edits to
`config.org` only need a save.

## Enabled modules

Completion is `vertico` + `corfu` with `orderless`; editing is `evil +everywhere` with
snippets, folding and file templates. Tooling includes `lsp`, `tree-sitter`, `magit +forge`,
`pdf` and `vterm`.

Languages: `emacs-lisp`, `json`, `javascript +tree-sitter`, `markdown`,
`org (+pretty +journal +roam +dragndrop +present +publish)`, `python +lsp`, `rest`,
`ruby +rails`, `sh`, `web +tree-sitter`, `yaml`.

See `init.el` for the full list.

## Extra packages

Beyond Doom's defaults (`packages.el`):

- **Org**: `org-roam`, `org-roam-ui`, `org-super-agenda`, `org-modern`, `org-bullets`,
  `svg-tag-mode`, `emacsql`, `websocket`
- **Writing / reading**: `olivetti`, `valign`, `emojify`, `grip-mode`
- **Git**: `magit-delta`, `vdiff`, `vdiff-magit`
- **AI**: `claudemacs` (+ `eat` as its terminal backend)
- **UX**: `beacon`, `key-chord`

## Appearance

- Theme: `doom-monokai-octagon`
- Fonts: Iosevka Nerd Font 18 / big 24, Overpass Nerd Font 22 (variable pitch),
  BlexMono Nerd Font light 22 (serif)
- Italic comments, taller modeline (30px) with perspective name, encoding shown only when
  it isn't UTF-8/LF
- Dashboard banner and footer removed
- Default frame: 115×34

## Markdown reading mode

Markdown buffers are set up as a reading surface rather than a code buffer:

- Markup and URLs hidden, revealed only on the line under the cursor (table rows are left
  alone so `valign` can own their display)
- Body text at ~18pt, no line numbers, frame transparency disabled
- `olivetti` centers text at 80 columns
- `valign` aligns tables pixel-perfect with fancy bars
- Inline images capped at 85% of screen width
- Faces set size/weight/style only — colors and font family come from the active theme
- `:smile:`-style emoji via `emojify`
- `toc-org` generates the table of contents in both Org and Markdown

## Document preview

- **Images**: `fit-width` auto-resize (`fit-window` shrinks too much on a 720px screen),
  animated GIFs loop, no line numbers
- **PDF**: `fit-width`, continuous scroll, midnight mode using the theme's fg/bg colors

## Org

- Notes in `~/org/`, agenda from `~/org/agenda.org`, `org-log-done` set to `note`
- Roam database in `~/roam/`, with autosync and `org-roam-protocol`
- Inline images shown at startup, sized to 85% of screen width (max 800px)
- `org-super-agenda` adds an "Overview" custom command (key `o` in the agenda dispatcher)
  grouping Today, Overdue, Due Soon and Important
- `svg-tag-mode` renders TODO keywords, priorities and `[3/7]` / `[42%]` progress as SVG
  badges, in both buffers and the agenda
- The frame title shows Roam note titles as `☰ Title` and the current Projectile project

## Key bindings

| Binding | Action |
| --- | --- |
| `fd` (key-chord) | Back to evil normal state |
| `C-c C-e` | Claudemacs transient menu (prog, elisp, text, python) |
| `C-c n f` / `n i` / `n l` | Roam: find node / insert node / toggle buffer |
| `C-c n c` / `n j` / `n g` | Roam: capture / daily capture / graph |
| `SPC t M` | Toggle minimap |
| `C-c C-o` | Follow TOC entry in Markdown |

## Claude Code integration

`claudemacs` runs Claude Code inside Emacs on top of `eat`. Both are deferred — the package
only loads when the transient menu is first invoked. The session opens in a right side window
at 33% width, with a 400k-line scrollback so history stays searchable.

`global-auto-revert-mode` is on because Claude edits files on disk. Save before asking it
anything: the file on disk is its source of truth.

## Git

- Forge uses `dwim:origin` (follows the branch's upstream when set), pulls the last 30 days
  of topics, capped at 50 per repo
- Switching to a project via workspaces opens Magit and fetches from upstream
- Diff-hl gutter colors are blended against the theme background
