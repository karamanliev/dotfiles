return {
  'goolord/alpha-nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    'nvim-lua/plenary.nvim',
  },
  config = function()
    local alpha = require 'alpha'
    local theta = require 'alpha.themes.theta'

    -- Create new buttons using the alpha module
    local button = require('alpha.themes.dashboard').button

    -- Define the header
    local header = {
      [[ ___  ___  ________  ___  ________  __________ ________      ________  _______   ___      ___ ]],
      [[|\  \|\  \|\   __  \|\  \|\   ____\|\___   ___ \   __  \    |\   ___ \|\  ___ \ |\  \    /  /|]],
      [[\ \  \\\  \ \  \|\  \ \  \ \  \___|\|___ \  \_\ \  \|\  \   \ \  \_|\ \ \   __/|\ \  \  /  / /]],
      [[ \ \   __  \ \   _  _\ \  \ \_____  \   \ \  \ \ \  \\\  \   \ \  \ \\ \ \  \_|/_\ \  \/  / / ]],
      [[  \ \  \ \  \ \  \\  \\ \  \|____|\  \   \ \  \ \ \  \\\  \ __\ \  \_\\ \ \  \_|\ \ \    / /  ]],
      [[   \ \__\ \__\ \__\\ _\\ \__\____\_\  \   \ \__\ \ \_______\\__\ \_______\ \_______\ \__/ /   ]],
      [[    \|__|\|__|\|__|\|__|\|__|\_________\   \|__|  \|_______\|__|\|_______|\|_______|\|__|/    ]],
      [[                            \|_________|                                                      ]],
    }

    -- Define the new buttons
    local buttons = {
      button('e', '  New file', ':ene <BAR> startinsert <CR>'),
      button('f', '󰈞  Find files', ':Telescope find_files <CR>'),
      button('r', '  Recent files', ':Telescope oldfiles <CR>'),
      button('g', '  Live grep', ':Telescope live_grep <CR>'),
      { type = 'padding', val = 1 }, -- This adds a new line

      button('r', '  Restore session', ':SessionRestore <CR>'),
      button('<leader>ls', '󰈞  List sessions', ':lua require("auto-session.session-lens").search_session() <CR>'),
      { type = 'padding', val = 1 }, -- This adds a new line

      button('<C-l>', '󰤄  LazyGit', ':LazyGit <CR>'),
      button('<C-s>', '󰊢  Git Status', ':Telescope git_status <CR>'),
      button('<C-c>', '  Commits', ':Telescope git_commits <CR>'),
      button('<C-b>', '  Branches', ':Telescope git_branches <CR>'),
      { type = 'padding', val = 1 }, -- This adds a new line

      button('h', '󰋗  Help', ':Telescope help_tags <CR>'),
      button('l', '󰒲  Lazy', ':Lazy <CR>'),
      button('c', '  Config', ':e $MYVIMRC <CR>'),
      button('q', '  Quit', ':qa<CR>'),
    }

    -- Modify the buttons in the theta theme layout
    theta.config.layout[2].val = header
    theta.config.layout[6].val = buttons

    alpha.setup(theta.config)
  end,
}