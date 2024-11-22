local M = {}

local telescopeConfig = require('telescope.config')
local actions_state = require('telescope.actions.state')
local from_entry = require('telescope.from_entry')

-- File and text search in hidden files and directories
local get_vimgrep_args = function()
  -- Clone the default Telescope configuration
  local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

  -- I want to search in hidden/dot files.
  table.insert(vimgrep_arguments, '--hidden')

  -- Interpret the search pattern literally and not as a regex.
  table.insert(vimgrep_arguments, '-F')

  -- Remove indentation from results
  table.insert(vimgrep_arguments, '--trim')
  -- I don't want to search in the `.git` directory.
  table.insert(vimgrep_arguments, '--glob')
  table.insert(vimgrep_arguments, '!**/.git/*')

  return vimgrep_arguments
end

M.vimgrep_arguments = get_vimgrep_args()

-- Open the selected file/dir with OpenSshFile command
M.open_ssh_file = function(opts)
  local entry = actions_state.get_selected_entry()
  if entry then
    local file_path = from_entry.path(entry, true)
    local dir = file_path and file_path:match('(.*/)')
    local path = opts.is_folder and dir or file_path

    vim.cmd('OpenSshFile ' .. path)
  end
end

-- Focus the preview window
M.focus_preview = function(prompt_bufnr)
  local action_state = require('telescope.actions.state')
  local picker = action_state.get_current_picker(prompt_bufnr)
  local prompt_win = picker.prompt_win
  local previewer = picker.previewer
  local winid = previewer.state.winid
  local bufnr = previewer.state.bufnr
  vim.keymap.set('n', '<Tab>', function()
    vim.cmd(string.format('noautocmd lua vim.api.nvim_set_current_win(%s)', prompt_win))
  end, { buffer = bufnr })
  vim.cmd(string.format('noautocmd lua vim.api.nvim_set_current_win(%s)', winid))
  -- api.nvim_set_current_win(winid)
end

M.set_colorscheme = function(prompt_bufnr)
  local colorscheme = actions_state.get_selected_entry()
  if colorscheme then
    require('telescope.actions').close(prompt_bufnr)
    vim.cmd('colorscheme ' .. colorscheme.value)
    local colorscheme_path = vim.fn.stdpath('config') .. '/lua/custom/colorscheme.lua'
    local lines = vim.fn.readfile(colorscheme_path)

    for i, line in ipairs(lines) do
      if line:match('vim%.cmd%.colorscheme%(.+%)') then
        lines[i] = string.format("vim.cmd.colorscheme('%s')", colorscheme.value)
        break
      end
    end

    vim.fn.writefile(lines, colorscheme_path)
    vim.fn.system('nvim-sync-colors.sh ' .. colorscheme.value)
  end
end

return M
