# dotfiles

Full desktop config: i3 + i3blocks, picom presets, kitty themes, zsh, rofi,
dunst, tmux, starship, git+delta, custom `~/.local/bin` scripts (`q`, `q-chat`,
`picom-preset`, …), OpenCode/Claude/Codex agent configs. Palette: Monokai Boosted.

## Restore

```bash
git clone <repo-url> ~/dotfiles && cd ~/dotfiles
./install.sh          # symlinks everything into $HOME, backs up conflicts
```

Then create `~/.zshrc.local` with your API keys (see AGENTS.md) and set git identity.

**Agents/maintainers: read [AGENTS.md](AGENTS.md) first** — layout table,
restore steps, validation commands and the list of traps.
