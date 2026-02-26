local config_file = vim.fn.expand('~/.config/darkman/themes.conf')
local state_theme_file = vim.fn.expand('~/.local/state/current_theme')

local theme = nil

if vim.fn.filereadable(config_file) == 1 then
  local config_lines = vim.fn.readfile(config_file)
  for _, line in ipairs(config_lines) do
    local dark_theme = line:match('^DARK_THEME="([%w._-]+)"')
    if dark_theme then
      theme = dark_theme
      break
    end
  end
end

if vim.fn.filereadable(state_theme_file) == 1 then
  local lines = vim.fn.readfile(state_theme_file)
  local candidate = lines[1] or ''
  if candidate:match('^[%w._-]+$') then
    theme = candidate
  end
end

if theme then
  pcall(vim.cmd.colorscheme, theme)
end
