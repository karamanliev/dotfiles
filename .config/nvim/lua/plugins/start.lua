return {
  'goolord/alpha-nvim',
  enabled = false,
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    'nvim-lua/plenary.nvim',
  },
  config = function()
    local alpha = require('alpha')
    local dashboard = require('alpha.themes.dashboard')
    local theta = require('alpha.themes.theta')

    -- Create new buttons using the alpha module
    local button = dashboard.button

    -- Define the header
    -- local header = {
    --   [[ ___  ___  ________  ___  ________  __________ ________      ________  _______   ___      ___ ]],
    --   [[|\  \|\  \|\   __  \|\  \|\   ____\|\___   ___ \   __  \    |\   ___ \|\  ___ \ |\  \    /  /|]],
    --   [[\ \  \\\  \ \  \|\  \ \  \ \  \___|\|___ \  \_\ \  \|\  \   \ \  \_|\ \ \   __/|\ \  \  /  / /]],
    --   [[ \ \   __  \ \   _  _\ \  \ \_____  \   \ \  \ \ \  \\\  \   \ \  \ \\ \ \  \_|/_\ \  \/  / / ]],
    --   [[  \ \  \ \  \ \  \\  \\ \  \|____|\  \   \ \  \ \ \  \\\  \ __\ \  \_\\ \ \  \_|\ \ \    / /  ]],
    --   [[   \ \__\ \__\ \__\\ _\\ \__\____\_\  \   \ \__\ \ \_______\\__\ \_______\ \_______\ \__/ /   ]],
    --   [[    \|__|\|__|\|__|\|__|\|__|\_________\   \|__|  \|_______\|__|\|_______|\|_______|\|__|/    ]],
    --   [[                            \|_________|                                                      ]],
    -- }
    local header = {
      [[                                                                       ]],
      [[                                                                     ]],
      [[       ████ ██████           █████      ██                     ]],
      [[      ███████████             █████                             ]],
      [[      █████████ ███████████████████ ███   ███████████   ]],
      [[     █████████  ███    █████████████ █████ ██████████████   ]],
      [[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
      [[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
      [[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
      [[                                                                       ]],
    }
    -- local header = {
    --   [[                                                    ]],
    --   [[ ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ]],
    --   [[ ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ]],
    --   [[ ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ]],
    --   [[ ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ]],
    --   [[ ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ]],
    --   [[ ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ]],
    --   [[                                                    ]],
    -- }

    -- Define the new buttons
    local buttons = {
      -- button('e', '  New file', ':ene <BAR> startinsert <CR>'),
      button('.', '󰈞  Find files', ':Telescope frecency<CR>'),
      button(',', '  Live grep', ':Telescope live_grep_args<CR>'),
      button('r', '  Recent files', ':Telescope oldfiles<CR>'),
      { type = 'padding', val = 1 }, -- This adds a new line

      button('R', '  Restore session', ':SessionRestore<CR>'),
      button('S', '󰈞  List sessions', '<cmd>lua require("auto-session.session-lens").search_session()<cr>'),
      { type = 'padding', val = 1 }, -- This adds a new line

      button('g', '󰊢  LazyGit', '<cmd>LazyGit<cr>'),
      button('d', '  Diffview', ':DiffviewOpen<CR>'),
      -- button('c', '  Commits', ':Telescope git_commits <CR>'),
      -- button('b', '  Branches', ':Telescope git_branches <CR>'),
      { type = 'padding', val = 1 }, -- This adds a new line

      button('T', '  TODO', ':e ~/Documents/todo.md<CR>'),
      button('N', '  NOTES', ':e ~/Documents/note.md<CR>'),
      { type = 'padding', val = 1 }, -- This adds a new line

      -- button('h', '󰋗  Help', ':Telescope help_tags <CR>'),
      ---@diagnostic disable-next-line: param-type-mismatch
      button('l', '󰒲  Lazy', function()
        require('lazy').home()
      end),
      button('m', '󱥒  Mason', ':Mason<CR>'),
      ---@diagnostic disable-next-line: param-type-mismatch
      button('t', '  Themes', function()
        local target = vim.fn.getcompletion

        ---@diagnostic disable-next-line: duplicate-set-field
        vim.fn.getcompletion = function()
          return vim.tbl_filter(function(color)
            return not vim.tbl_contains({ 'randombones' }, color)
          end, target('', 'color'))
        end

        vim.cmd('Telescope colorscheme previewer=false layout_config={height=100,width=25,anchor="NE"}')
        vim.fn.getcompletion = target
      end),
      button('q', '  Quit', ':qa<CR>'),
    }

    -- Modify the buttons in the theta theme layout
    theta.header.val = header
    theta.buttons.val = buttons

    alpha.setup(theta.config)
  end,
}
