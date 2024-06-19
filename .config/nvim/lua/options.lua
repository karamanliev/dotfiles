-- Set <space> as the leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Relative line numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 5

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Foldcolumn
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
vim.o.foldcolumn = '0' -- '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- custom statuscolumn
vim.opt.statuscolumn = " %s%{&nu ? (&rnu && v:virtnum < 1 ? (v:relnum ? v:relnum : v:lnum < 10 ? v:lnum . '  ' : v:lnum) : '') : ''} "
-- vim.opt.statuscolumn = " %=%{v:virtnum < 1 ? (v:relnum ? v:relnum : v:lnum < 10 ? v:lnum . '  ' : v:lnum) : ''}%=%s"

-- enable changing buffers without saving
vim.opt.hidden = true

-- Enable mouse support
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Enable true color support
vim.opt.termguicolors = true

-- Clipboard
-- Use OSC52 when SSH
vim.opt.clipboard = 'unnamedplus'
vim.g.clipboard = vim.env.SSH_TTY
    and {
      name = 'OSC 52',
      copy = {
        ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
        ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
      },
      paste = {
        ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
        ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
      },
    }
  or false

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
vim.opt.timeout = true
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- set transparency to the completion and popup menus
vim.opt.pumblend = 0
vim.opt.winblend = 0

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 15

-- Set what is saved by `:mksession`
vim.opt.sessionoptions = 'buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'

-- Set highlight on search
vim.opt.hlsearch = true

-- Diagnostic virtual text
vim.g.virtual_text = {
  source = false,
  severity = { min = vim.diagnostic.severity.WARN },
}
