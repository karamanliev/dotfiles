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

-- Diagnostics
vim.diagnostic.config({
  virtual_text = {
    spacing = 2,
    current_line = true,
    prefix = '■',
    source = 'if_many',
  },
  underline = true,
  severity_sort = true,
  update_in_insert = true,
  float = {
    source = true,
    border = 'single',
    severity_sort = true,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '■',
      [vim.diagnostic.severity.WARN] = '■',
      [vim.diagnostic.severity.HINT] = '■',
      [vim.diagnostic.severity.INFO] = '■',
    },
  },
})

-- Folding
vim.o.foldenable = true
vim.opt.foldtext = ''
vim.o.foldcolumn = '0'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldmethod = 'expr'
-- Default to treesitter folding
vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
-- Prefer LSP folding if client supports it
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client:supports_method('textDocument/foldingRange') then
      local win = vim.api.nvim_get_current_win()
      vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
    end
  end,
})

-- custom statuscolumn
vim.opt.statuscolumn = " %s%{&nu ? (&rnu && v:virtnum < 1 ? (v:relnum ? v:relnum : v:lnum < 10 ? v:lnum . '  ' : v:lnum) : '') : ''} "

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
-- vim.opt.scrolloff = 15

-- Set what is saved by `:mksession`
vim.opt.sessionoptions = 'buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'

-- Set highlight on search
vim.opt.hlsearch = true

-- Make it possible to use vim motions when using bulgarian keyboard layout
vim.opt.langmap =
  'яq,вw,еe,рr,тt,ъy,уu,иi,оo,пp,ш[,щ],аa,сs,дd,фf,гg,хh,йj,кk,лl,зz,ьx,цc,жv,бb,нn,мm,ч`,ЯQ,ВB,ЕE,РR,ТT,ЪY,УU,ИI,ОO,Ш{,Щ},АA,СS,ДD,ФF,ГG,ХH,ЙJ,КK,ЛL,ЗZ,ѝX,ЦC,ЖV,БB,НN,МM,Ч~'

-- Set ttimeoutlen to 0 to disable timeouts
-- vim.opt.ttimeoutlen = 0
-- vim.opt.ttimeout = false

-- Add filetype for http files
vim.filetype.add({
  extension = {
    ['http'] = 'http',
  },
})
