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
if vim.env.SSH_TTY then
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
vim.keymap.set('n', 'L', 'i<cr><escape>', { desc = 'Split line [L]eft' })

-- Goto prev/next buffer with Alt + </>
vim.keymap.set('n', '<M-,>', '<cmd>bprev<cr>', { desc = 'Go to [P]revious buffer' })
vim.keymap.set('n', '<M-.>', '<cmd>bnext<cr>', { desc = 'Go to [N]ext buffer' })
vim.keymap.set('n', '[b', '<cmd>bprev<cr>', { desc = 'Go to [P]revious buffer' })
vim.keymap.set('n', ']b', '<cmd>bnext<cr>', { desc = 'Go to [N]ext buffer' })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
-- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Don't move cursor when using J
vim.keymap.set('n', 'J', 'mzJ`z', { desc = 'Join lines [J]' })

-- Center buffer while navigating
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Scroll [U]p' })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Scroll [D]own' })
vim.keymap.set('n', '<C-b>', '<C-b>zz', { desc = 'Scroll [B]ack' })
vim.keymap.set('n', '<C-f>', '<C-f>zz', { desc = 'Scroll [F]orward' })
vim.keymap.set('n', '{', '{zz', { desc = 'Go to [P]revious paragraph' })
vim.keymap.set('n', '}', '}zz', { desc = 'Go to [N]ext paragraph' })
vim.keymap.set('n', '<C-i>', '<C-i>zz', { desc = 'Go to [N]ext cursor position' })
vim.keymap.set('n', '<C-o>', '<C-o>zz', { desc = 'Go to [P]revious cursor position' })
vim.keymap.set('n', '%', '%zz', { desc = 'Go to [M]atching bracket' })

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
vim.keymap.set('n', '<leader>tc', '<cmd>ToggleFoldColumn<cr>', { desc = 'Toggle [F]old [C]olumn' })
