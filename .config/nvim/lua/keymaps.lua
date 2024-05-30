-- Clear search highlights with <Esc>
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Remap macro recording to 'Q' instead of 'q'
vim.keymap.set('n', 'q', '<nop>', {})
vim.keymap.set('n', 'Q', 'q', { desc = 'Record macro [Q]', noremap = true })

-- Yank the line on `dd` only if it is non-empty
vim.keymap.set('n', 'dd', function()
  if vim.fn.getline('.'):match('^%s*$') then
    return '"_dd'
  end
  return 'dd'
end, { expr = true })

-- Split line in normal mode
vim.keymap.set('n', 'L', 'i<cr><escape>', { desc = 'Split line [L]eft' })

-- Goto prev/next buffer with Alt + h/l
vim.keymap.set('n', '<M-h>', '<cmd>bprevious<cr>', { desc = 'Go to [P]revious buffer' })
vim.keymap.set('n', '<M-l>', '<cmd>bnext<cr>', { desc = 'Go to [N]ext buffer' })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
-- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Center buffer while navigating
vim.keymap.set('n', 'n', 'nzz', { desc = 'Go to [N]ext search result' })
vim.keymap.set('n', 'N', 'Nzz', { desc = 'Go to [P]revious search result' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Scroll [U]p' })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Scroll [D]own' })
vim.keymap.set('n', '<C-b>', '<C-b>zz', { desc = 'Scroll [B]ack' })
vim.keymap.set('n', '<C-f>', '<C-f>zz', { desc = 'Scroll [F]orward' })
vim.keymap.set('n', '{', '{zz', { desc = 'Go to [P]revious paragraph' })
vim.keymap.set('n', '}', '}zz', { desc = 'Go to [N]ext paragraph' })
vim.keymap.set('n', 'G', 'Gzz', { desc = 'Go to [E]nd of file' })
vim.keymap.set('n', 'gg', 'ggzz', { desc = 'Go to [B]eginning of file' })
vim.keymap.set('n', '<C-i>', '<C-i>zz', { desc = 'Go to [N]ext cursor position' })
vim.keymap.set('n', '<C-o>', '<C-o>zz', { desc = 'Go to [P]revious cursor position' })
vim.keymap.set('n', '%', '%zz', { desc = 'Go to [M]atching bracket' })
vim.keymap.set('n', '#', '#zz', { desc = 'Go to [P]revious matching word' })
vim.keymap.set('n', '*', '*zz', { desc = 'Go to [N]ext matching word' })

-- Press 'C-S' for quick find/replace for the word under the cursor
vim.keymap.set('n', '<C-s>', function()
  local cmd = ':%s/<C-r><C-w>//gI<Left><Left><Left>'
  local keys = vim.api.nvim_replace_termcodes(cmd, true, false, true)
  vim.api.nvim_feedkeys(keys, 'n', false)
end)

-- Same as above but for visual mode selection
vim.keymap.set('x', '<C-s>', '"zy<Esc>:%s/<C-R>z//gI<Left><Left><Left>')

-- Toggle diagnostics virtual_text, because it could be annoying
local diagnostics_active = true
vim.keymap.set('n', '<leader>tx', function()
  diagnostics_active = not diagnostics_active
  if diagnostics_active then
    vim.diagnostic.show()
  else
    vim.diagnostic.hide()
  end
end, { desc = 'Toggle text diagnostics' })
