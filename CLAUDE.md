# CLAUDE.md

Personal macOS dev-environment bootstrap. `install.sh` is run via `curl | sh`, clones this repo to `~/.enviroment`, installs packages, and copies config files into place. `uninstall.sh` reverses it.

The repo name is spelled `enviroment` (no "n"). Keep that spelling in paths and URLs.

## Layout

- `install.sh` / `uninstall.sh` - Entry points; each is a set of `setup_*` / `remove_*` functions called in order from `main()`
- `shell/zshrc.zsh-template` -> `~/.zshrc`
- `shell/tmux.conf-template` -> `~/.tmux.conf`
- `shell/aerospace.toml` -> `~/.aerospace.toml`
- `shell/iterm2-settings.plist` -> iTerm2 preferences (via `defaults import`)
- `keyboard/karabiner.json` -> `~/.config/karabiner/karabiner.json`

Configs are copied, not symlinked. Editing a file here does not change the live machine until it is re-copied.

## Conventions

- Scripts are POSIX `sh` (`#!/bin/sh`), not bash. Avoid bashisms such as `[[ ]]`, arrays, and `function`. (`local` is already used and works under macOS `sh`.)
- Every install or removal step reports its result with `track_installation "<name>" success|failed` (or `track_removal`) so it appears in the end-of-run summary. Warn and continue on failure; only `exit 1` for prerequisites.
- Steps should be idempotent: skip if already present, back up before overwriting user files.
- Use the `info` / `warn` / `error` helpers for output.

## Keep in sync

When changing one of these, update its counterpart:

- `BREW_PACKAGES` and `BREW_CASKS` exist in both `install.sh` and `uninstall.sh`. In `uninstall.sh`, tapped casks use the bare name (`aerospace`, not `nikitabobko/tap/aerospace`).
- Claude Code and Codex use their vendors' curl installers, both into `~/.local/bin`. `uninstall.sh` removes those files directly. `NPM_PACKAGES` in `uninstall.sh` exists only to clean up older npm-based installs.
- Adding or removing a step in `main()` means updating `TOTAL_STEPS`.
- `README.md` documents the package list, installer steps, MCP servers, aliases, tmux bindings, AeroSpace keybindings, and workspace assignments. Update it when any of those change.
- Manual-step text appears in both `setup_manual_steps()` and the README.

## Checking changes

There are no tests. Before committing script changes:

```sh
sh -n install.sh && sh -n uninstall.sh
zsh -n shell/zshrc.zsh-template
```

Do not run `install.sh` or `uninstall.sh` to test them. They modify the real machine: Homebrew, `defaults write`, git global config, and `sudo`.

`master` is the branch the curl installer pulls, so anything pushed there ships immediately.
