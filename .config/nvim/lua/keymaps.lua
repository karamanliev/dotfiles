-- Clear search highlights with <Esc>
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Better up/down
vim.keymap.set({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, '<Down>', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, '<Up>', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true, silent = true })

-- Remap macro recording to 'Q' instead of 'q'
vim.keymap.set('n', 'q', '<nop>', {})
vim.keymap.set('n', 'Q', 'q', { desc = 'Record macro [Q]', noremap = true })

-- Yank filepath to clipboard
vim.keymap.set({ 'n', 'x' }, '<leader>yf', '<cmd>let @+=expand("%:p")<CR>', { desc = 'Yank filepath' })

-- Open SSH file locally
if vim.env.SSH_CONNECTION then
  vim.keymap.set({ 'n', 'x' }, '<leader>x', '<cmd>OpenSshFile<cr>', { desc = 'Open SSH file' })
  vim.keymap.set({ 'n', 'x' }, '<leader>X', '<cmd>OpenSshFile dir<cr>', { desc = 'Open SSH dir' })
end

-- Don't yank on visual paste
vim.keymap.set('v', 'p', '"_dP', { desc = 'Paste' })

-- Yank in visual without moving cursor
vim.keymap.set('v', 'y', 'y`]', { desc = 'Yank' })

-- Yank the line on `dd` only if it is non-empty
vim.keymap.set('n', 'dd', function()
  if vim.fn.getline('.'):match('^%s*$') then
    return '"_dd'
  end
  return 'dd'
end, { expr = true })

-- Split line in normal mode
vim.keymap.set('n', 'L', 'i<cr><escape>', { desc = 'Split line Left' })

-- Cycle between last two buffers like <C-6>
vim.keymap.set('n', 'gl', '<cmd>b#<cr>', { desc = 'Go to Last buffer' })

-- Goto prev/next buffer with Alt + </>
vim.keymap.set('n', '<M-,>', '<cmd>bprev<cr>', { desc = 'Go to Previous buffer' })
vim.keymap.set('n', '<M-.>', '<cmd>bnext<cr>', { desc = 'Go to Next buffer' })
vim.keymap.set('n', '[b', '<cmd>bprev<cr>', { desc = 'Go to Previous buffer' })
vim.keymap.set('n', ']b', '<cmd>bnext<cr>', { desc = 'Go to Next buffer' })

-- Resize splits
vim.keymap.set('n', '<M-->', '<cmd>vertical resize -2<cr>', { desc = 'Resize Vertical Less' })
vim.keymap.set('n', '<M-=>', '<cmd>vertical resize +2<cr>', { desc = 'Resize Vertical More' })
vim.keymap.set('n', '<M-_>', '<cmd>resize -2<cr>', { desc = 'Resize Horizontal Less' })
vim.keymap.set('n', '<M-+>', '<cmd>resize +2<cr>', { desc = 'Resize Horizontal More' })

-- Diagnostic keymaps
-- TODO: Switch to vim.diagnostic.jump() in neovim 0.11.0
vim.keymap.set('n', '[d', function()
  vim.diagnostic.goto_prev({ float = false })
end, { desc = 'Go to previous Diagnostic message' })
vim.keymap.set('n', ']d', function()
  vim.diagnostic.goto_next({ float = false })
end, { desc = 'Go to next Diagnostic message' })
vim.keymap.set('n', '[e', function()
  vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR, float = false })
end, { desc = 'Go to previous Error message' })
vim.keymap.set('n', ']e', function()
  vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR, float = false })
end, { desc = 'Go to next Error message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic Error messages' })
-- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic Quickfix list' })

-- Don't move cursor when using J
vim.keymap.set('n', 'J', 'mzJ`z', { desc = 'Join lines J' })

-- Center buffer while navigating
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Scroll Up' })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Scroll Down' })
vim.keymap.set('n', '<C-b>', '<C-b>zz', { desc = 'Scroll Back' })
vim.keymap.set('n', '<C-f>', '<C-f>zz', { desc = 'Scroll Forward' })
vim.keymap.set('n', '{', '{zz', { desc = 'Go to Previous paragraph' })
vim.keymap.set('n', '}', '}zz', { desc = 'Go to Next paragraph' })
vim.keymap.set('n', '<C-i>', '<C-i>zz', { desc = 'Go to Next cursor position' })
vim.keymap.set('n', '<C-o>', '<C-o>zz', { desc = 'Go to Previous cursor position' })
vim.keymap.set('n', '%', '%zz', { desc = 'Go to Matching bracket' })

-- Open Notes/Todos file
vim.keymap.set('n', '<leader>on', '<cmd>vsplit ~/Documents/note.md<cr>', { desc = 'Open Notes' })
vim.keymap.set('n', '<leader>ot', '<cmd>vsplit ~/Documents/todo.md<cr>', { desc = 'Open Todos' })

-- Toggle diagnostics, because it could be annoying
local diagnostics_active = true
vim.keymap.set('n', '<leader>tx', function()
  diagnostics_active = not diagnostics_active
  if diagnostics_active then
    vim.diagnostic.show()
  else
    vim.diagnostic.hide()
  end
end, { desc = 'Toggle diagnostics' })

-- Toggle Fold Column
vim.keymap.set('n', '<leader>tc', '<cmd>ToggleFoldColumn<cr>', { desc = 'Toggle Fold Column' })

-- Open lazygit in new tmux window
vim.keymap.set('n', '<leader>gg', '<cmd>LazyGit<cr>', { desc = 'LazyGit' })

-- Open yazi in new tmux window
vim.keymap.set('n', '<leader>Y', function()
  local current_file_dir = vim.fn.expand('%:p:h')
  local tmux_command = 'silent !tmux new-window -c "' .. vim.fn.getcwd() .. '" -- yazi ' .. current_file_dir
  vim.cmd(tmux_command)
end, { desc = 'Yazi', silent = true }) -- opens yazi in a new tmux window
