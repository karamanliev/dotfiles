-- Clear search highlights with <Esc>
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set('n', '<leader>w', '<cmd>w<CR>', { desc = 'Write file' })
vim.keymap.set('n', '<leader>W', '<cmd>WriteWithoutFormat<CR>', { desc = 'Write file (no autoformat)' })

-- Better up/down
vim.keymap.set({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, '<Down>', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, '<Up>', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true, silent = true })

-- Yank filepath to clipboard
vim.keymap.set({ 'n', 'x' }, '\\y', '<cmd>let @+=expand("%:p")<CR>', { desc = 'Yank filepath' })

-- Reselect last yanked/pasted text
vim.keymap.set('n', 'gV', '`[v`]', { desc = 'Reselect last yanked/pasted text' })

-- Open SSH file locally
if vim.env.SSH_CONNECTION then
  vim.keymap.set({ 'n', 'x' }, '<leader>x', '<cmd>OpenSshFile<cr>', { desc = 'Open SSH file' })
  vim.keymap.set({ 'n', 'x' }, '<leader>X', '<cmd>OpenSshFile dir<cr>', { desc = 'Open SSH dir' })
end

-- Press 'C-n' for quick find/replace for the word under the cursor
vim.keymap.set('n', '<C-n>', function()
  local cmd = ':%s/<C-r><C-w>//gcI<Left><Left><Left><Left>'
  local keys = vim.api.nvim_replace_termcodes(cmd, true, false, true)
  vim.api.nvim_feedkeys(keys, 'n', false)
end)

-- Same as above but for visual mode selection
vim.keymap.set('x', '<C-n>', '"zy<Esc>:%s/<C-R>z//gcI<Left><Left><Left><Left>')

-- Search in visual selection
vim.keymap.set('x', 'g/', '<Esc>/\\%V', { desc = 'Search in visual selection' })

-- Don't yank on visual paste
-- vim.keymap.set('v', 'p', '"_dP', { desc = 'Paste' })

-- Yank in visual without moving cursor
vim.keymap.set('v', 'y', 'y`]', { desc = 'Yank' })

vim.keymap.set({ 'n', 'x' }, '<leader>tw', '<cmd>ToggleWrap<cr>', { desc = 'Toggle Wrapping' })

-- Yank the line on `dd` only if it is non-empty
vim.keymap.set('n', 'dd', function()
  if vim.fn.getline('.'):match('^%s*$') then
    return '"_dd'
  end
  return 'dd'
end, { expr = true })

-- Resize splits
vim.keymap.set('n', '<M-,>', '<cmd>vertical resize -2<cr>', { desc = 'Resize Vertical Less' })
vim.keymap.set('n', '<M-.>', '<cmd>vertical resize +2<cr>', { desc = 'Resize Vertical More' })
vim.keymap.set('n', '<M-S-,>', '<cmd>resize -2<cr>', { desc = 'Resize Horizontal Less' })
vim.keymap.set('n', '<M-S.>', '<cmd>resize +2<cr>', { desc = 'Resize Horizontal More' })

-- Diagnostic keymaps
vim.keymap.set('n', '[e', function()
  vim.diagnostic.jump({ severity = vim.diagnostic.severity.ERROR, float = false, count = -1 })
end, { desc = 'Go to previous Error message' })
vim.keymap.set('n', ']e', function()
  vim.diagnostic.jump({ severity = vim.diagnostic.severity.ERROR, float = false, count = 1 })
end, { desc = 'Go to next Error message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic Error messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setqflist, { desc = 'Open diagnostic Quickfix list' })

-- Don't move cursor when using J
vim.keymap.set('n', 'J', 'mzJ`z', { desc = 'Join lines J' })

-- Move lines and blocks up and down
vim.keymap.set('n', '<M-j>', '<cmd>m .+1<cr>==', { desc = 'Move line down' })
vim.keymap.set('n', '<M-k>', '<cmd>m .-2<cr>==', { desc = 'Move line up' })
vim.keymap.set('i', '<M-j>', '<Esc>:m .+1<cr>==gi', { desc = 'Move line down (insert)' })
vim.keymap.set('i', '<M-k>', '<Esc>:m .-2<cr>==gi', { desc = 'Move line up (insert)' })
vim.keymap.set('v', '<M-j>', ":'<,'>m '>+1<cr>gv=gv", { desc = 'Move block down' })
vim.keymap.set('v', '<M-k>', ":'<,'>m '<-2<cr>gv=gv", { desc = 'Move block up' })

-- Select foldmethod with vim.ui.select
vim.keymap.set('n', 'zfm', '<cmd>SelectFoldMethod<cr>', { desc = 'Select foldmethod' })

-- Open lazygit in new tmux window
vim.keymap.set('n', '<leader>gg', '<cmd>LazyGit<cr>', { desc = 'LazyGit' })
vim.keymap.set('n', 'gh', '<cmd>LazyGit<cr>', { desc = 'LazyGit' })
vim.keymap.set('n', 'gH', '<cmd>LazyGit!<cr>', { desc = 'LazyGit split' })
vim.keymap.set('n', 'gL', '<cmd>LazyGitLogs<cr>', { desc = 'LazyGit' })
vim.keymap.set('n', '<leader>L', function()
  require('lazy').home()
end, { desc = 'Lazy' })

-- Open yazi in new tmux window
vim.keymap.set('n', '<leader>Y', function()
  local current_file_dir = vim.fn.expand('%:p:h')
  local tmux_command = 'silent !tmux new-window -c "' .. vim.fn.getcwd() .. '" -- yazi ' .. current_file_dir
  vim.cmd(tmux_command)
end, { desc = 'Yazi', silent = true }) -- opens yazi in a new tmux window

-- Add a mapping (dd) to delete the current quickfix item
local function remove_qf_item()
  local list = vim.fn.getqflist()
  local idx = vim.fn.line('.')
  table.remove(list, idx)
  vim.fn.setqflist(list, 'r')
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'qf',
  callback = function()
    vim.keymap.set('n', 'dd', remove_qf_item, { buffer = true, desc = 'Delete quickfix entry' })
  end,
})
