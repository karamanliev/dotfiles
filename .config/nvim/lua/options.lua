-- Set <space> as the leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Relative line numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 5

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Set dark background
vim.opt.background = 'dark'

-- Folding
function Foldexpr()
  local buf = vim.api.nvim_get_current_buf()
  if vim.b[buf].ts_folds == nil then
    -- as long as we don't have a filetype, don't bother
    -- checking if treesitter is available (it won't)
    if vim.bo[buf].filetype == '' then
      return '0'
    end
    if vim.bo[buf].filetype:find('dashboard') then
      vim.b[buf].ts_folds = false
    else
      vim.b[buf].ts_folds = pcall(vim.treesitter.get_parser, buf)
    end
  end
  return vim.b[buf].ts_folds and vim.treesitter.foldexpr() or '0'
end

-- use tree-sitter for folding. If needed to use normal folding, run :set foldmethod=syntax
vim.o.foldenable = true
vim.opt.foldmethod = 'expr'
if vim.fn.has('nvim-0.10') == 1 then
  vim.opt.foldexpr = 'v:lua.Foldexpr()'
else
  vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
end
vim.o.foldcolumn = '0'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99

-- custom statuscolumn
vim.opt.statuscolumn = " %s%{&nu ? (&rnu && v:virtnum < 1 ? (v:relnum ? v:relnum : v:lnum < 10 ? v:lnum . '  ' : v:lnum) : '') : ''} "
-- vim.opt.statuscolumn = " %=%{v:virtnum < 1 ? (v:relnum ? v:relnum : v:lnum < 10 ? v:lnum . '  ' : v:lnum) : ''}%=%s"
-- vim.opt.laststatus = 0

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

-- Increase the size of cmdwinheight
vim.opt.cmdwinheight = 20

-- Clipboard
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Use OSC52 when SSH
local function paste()
  return {
    vim.fn.split(vim.fn.getreg(''), '\n'),
    vim.fn.getregtype(''),
  }
end

if vim.env.SSH_TTY then
  vim.g.clipboard = {
    name = 'OSC 52',
    copy = {
      ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
      ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
    },
    paste = {
      ['+'] = paste,
      ['*'] = paste,
    },
  }
end

-- Enable break indent
vim.opt.breakindent = true

-- Indentation
vim.opt.autoindent = true
vim.opt.shiftround = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2

-- Save undo history
vim.opt.undofile = true

-- Disable swap files
vim.opt.swapfile = false

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

-- Make it possible to use vim motions when using bulgarian keyboard layout
vim.opt.langmap =
  'яq,вw,еe,рr,тt,ъy,уu,иi,оo,пp,ш[,щ],аa,сs,дd,фf,гg,хh,йj,кk,лl,зz,ьx,цc,жv,бb,нn,мm,ч`,ЯQ,ВB,ЕE,РR,ТT,ЪY,УU,ИI,ОO,Ш{,Щ},АA,СS,ДD,ФF,ГG,ХH,ЙJ,КK,ЛL,ЗZ,ѝX,ЦC,ЖV,БB,НN,МM,Ч~'

-- Set ttimeoutlen to 0 to disable timeouts
vim.opt.ttimeoutlen = 0
vim.opt.ttimeout = false
