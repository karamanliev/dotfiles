# Changelog

## 2026-02-14

### Yazi tmux split (Alt+Y)

Added a toggleable yazi split accessible from anywhere in tmux via `Alt+Y`, with nvim integration. Uses a zoomed tmux split instead of a popup to support image previews.

- `Alt+Y` opens/closes a zoomed horizontal split with yazi in the current window
- Pressing `e` on a file sends it to the nvim instance in the current window
- If no nvim is open, opens nvim directly in the yazi pane
- `q` closes yazi and the split; split always opens fresh in the invoking pane's directory
- Toggle state tracked per-window via `@yazi_pane` tmux window option

**Files changed:**
- `.config/tmux/scripts.conf` — `Alt+Y` binding (direct call, no popup)
- `.config/tmux/scripts/yazi-split.sh` — new zoomed split script with toggle
- `.config/yazi/yazi.toml` — `[opener].edit` delegated to script
- `.config/yazi/scripts/nvim-edit.sh` — script handling all edit routing logic

## 2026-02-13

### Lazygit tmux popup (Alt+L)

Added a toggleable lazygit popup accessible from anywhere in tmux via `Alt+L`, with deep nvim integration.

- `Alt+L` opens/hides a lazygit popup session (one per tmux session, toggles like scratch/claude popups)
- Pressing `e` on a file sends it to the nvim instance in the current window (detected live at edit time)
- If no nvim is open, opens a new tmux window with nvim in the parent session
- Pressing `q` hides the popup (lazygit stays alive in background); `Q` quits lazygit and closes the popup
- Status bar is hidden when only lazygit is visible, shown when a second window (e.g. nvim) is open
- Works correctly with multiple nvim instances across different windows — always targets the window the popup was opened from

**Files changed:**
- `.config/tmux/scripts.conf` — `Alt+L` binding, `after-kill-window` status hook
- `.config/tmux/scripts/lazygit-popup.sh` — new popup session script
- `.config/tmux/scripts/toggle-status.sh` — added `_lazygit-popup` to status toggle pattern
- `.config/lazygit/config_nvim.yml` — `os.edit`/`os.editAtLine` delegated to script, `q`/`Q` keybindings
- `.config/lazygit/scripts/nvim-edit.sh` — new script handling all edit routing logic
- `.config/nvim/lua/commands.lua` — store/clear nvim socket in tmux pane option on start/exit
