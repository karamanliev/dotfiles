-- Set <space> as the leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Setting options ]]
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Enable true color support
vim.opt.termguicolors = true

-- Sync clipboard between OS and Neovim.
vim.opt.clipboard = 'unnamedplus'

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeout = true
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- add transparency to the popup completion menu and
vim.opt.pumblend = 15
vim.opt.winblend = 15

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 15

vim.opt.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'

-- [[ Basic Keymaps ]]
-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set('n', 'L', 'i<cr><escape>', { desc = 'Split line [L]eft' })
-- do i really need this?
-- vim.keymap.set('n', 'H', 'd$O<escape>p', { desc = 'Split line [R]ight' })
-- Navigate buffers with Ctrl + hjkl
vim.keymap.set('n', '<M-l>', '<cmd>bnext<cr>', { desc = 'Go to [N]ext buffer' })
vim.keymap.set('n', '<M-h>', '<cmd>bprevious<cr>', { desc = 'Go to [P]revious buffer' })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
-- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Open Oil
vim.keymap.set('n', '-', '<cmd>Oil<CR>', { desc = 'Open Oil' })

-- Close all buffers, but the active one
vim.api.nvim_create_user_command('ClearBuffers', function()
  local current_line = vim.fn.line '.'
  vim.cmd [[%bd|e#|bd#]]
  vim.cmd(current_line .. 'norm! zz')
end, {})

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
vim.keymap.set('x', '<C-s>', '"zy<Esc>:%s/<C-R>z//gI<Left><Left>')

-- Move lines up and down
vim.keymap.set('n', '<A-j>', '<cmd>m .+1<cr>==', { desc = 'Move line [D]own' })
vim.keymap.set('n', '<A-k>', '<cmd>m .-2<cr>==', { desc = 'Move line [U]p' })
vim.keymap.set('v', '<A-j>', "<cmd>m '>+1<cr>gv=gv", { desc = 'Move line [D]own' })
vim.keymap.set('v', '<A-k>', "<cmd>m '<-2<cr>gv=gv", { desc = 'Move line [U]p' })

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

-- [[ Basic Autocommands ]]
local autocmd = vim.api.nvim_create_autocmd
local autogroup = vim.api.nvim_create_augroup
local general = autogroup('General', { clear = true })

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = general,
  desc = 'Highlight when yanking (copying) text',
})

autocmd('FileType', {
  callback = function()
    vim.bo.bufhidden = 'unload'
    vim.cmd.wincmd 'L'
    vim.cmd.wincmd '='
  end,
  pattern = 'help',
  group = general,
  desc = 'Open help in vertical split',
})

autocmd('BufReadPost', {
  callback = function()
    if vim.fn.line '\'"' > 1 and vim.fn.line '\'"' <= vim.fn.line '$' then
      vim.cmd 'normal! g`"'
    end
  end,
  group = general,
  desc = 'Preserve Last Cursor Position on Quit',
})

autocmd('BufEnter', {
  callback = function()
    vim.opt.formatoptions:remove { 'c', 'r', 'o' }
  end,
  group = general,
  desc = 'Disable New Line Comment',
})

-- Show current buffer CWD for 5 seconds
vim.api.nvim_create_user_command('BufCWD', function()
  local function print_buffer_cwd()
    local cwd = vim.fn.expand '%:p:h'
    local padded_cwd = cwd .. string.rep(' ', 2) -- Adding 2 spaces of padding
    vim.notify('Current Buffer CWD: ' .. padded_cwd, vim.log.levels.INFO, { ttl = 10000 })
  end

  print_buffer_cwd()
end, {})

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
require('lazy').setup({
  { import = 'plugins' },
}, {})
