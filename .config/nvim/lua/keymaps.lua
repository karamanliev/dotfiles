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

-- Goto prev/next buffer with Alt + </>
vim.keymap.set('n', '<M-,>', '<cmd>bprev<cr>', { desc = 'Go to [P]revious buffer' })
vim.keymap.set('n', '<M-.>', '<cmd>bnext<cr>', { desc = 'Go to [N]ext buffer' })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
-- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

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
