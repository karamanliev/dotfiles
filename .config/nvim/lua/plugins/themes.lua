local keys = require('utils.misc').theme_switch_kb

return {
  {
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    lazy = true,
    keys = keys,
    config = function()
      require('tokyonight').setup({
        style = 'moon',
        transparent = false,
        dim_inactive = false,
        plugins = {
          auto = true,
          all = false,
        },

        styles = {
          keywords = { italic = true },
          comments = { italic = true },
        },
        -- on_colors = function(c)
        --   c.gitSigns.add = c.git.add
        --   c.gitSigns.change = c.git.change
        --   c.gitSigns.delete = c.git.delete
        -- end,
        on_highlights = function(hl, c)
          hl.DiagnosticUnderlineError = { underline = true, sp = c.error }
          hl.DiagnosticUnderlineWarn = { underline = true, sp = c.warning }
          hl.DiagnosticUnderlineInfo = { underline = true, sp = c.info }
          hl.DiagnosticUnderlineHint = { underline = true, sp = c.hint }
          hl.FoldColumn = { bg = 'none' }
          hl.SignColumn = { bg = 'none' }
          hl.Undo = { link = 'DiffText' }
          hl.Redo = { link = 'DiffText' }
          hl.Paste = { link = 'DiffAdd' }
          hl.PackageInfoOutdatedVersion = { fg = c.magenta }
          hl.PackageInfoInvalidVersion = { fg = c.red }
          hl.PackageInfoUpToDateVersion = { fg = c.green1 }
          hl.MatchParen = { bold = true, fg = '#ff966c', bg = '#3b4261' }
          -- hl.IlluminatedWordRead = { underline = true }
          -- hl.IlluminatedWordText = { underline = true }
          -- hl.IlluminatedWordWrite = { underline = true }
          -- hl.GitSignsAdd = { fg = '#627259' }
          -- hl.GitGutterAddLineNr = { fg = '#627259' }
          -- hl.GitSignsChange = { fg = '#6785b8' }
          -- hl.GitGutterChangeLineNr = { fg = '#6785b8' }
        end,
      })
      -- vim.cmd.colorscheme('tokyonight')
    end,
  },

  {
    'zenbones-theme/zenbones.nvim',
    priority = 1000,
    lazy = true,
    keys = keys,
    config = function()
      vim.g.bones_compat = 1
      -- vim.cmd.colorscheme('tokyobones')
    end,
  },

  {
    'olivercederborg/poimandres.nvim',
    priority = 1000,
    lazy = true,
    keys = keys,
    config = function()
      require('poimandres').setup({
        bold_vert_split = false, -- use bold vertical separators
        dim_nc_background = false, -- dim 'non-current' window backgrounds
        disable_background = false, -- disable background
        disable_float_background = false, -- disable background for floats
        disable_italics = false, -- disable italics
      })
    end,
  },

  {
    'rose-pine/neovim',
    name = 'rose-pine',
    lazy = true,
    keys = keys,
    priority = 1000,
    config = function()
      require('rose-pine').setup({
        variant = 'auto', -- auto, main, moon, or dawn
        dark_variant = 'main', -- main, moon, or dawn
        dim_inactive_windows = false,
        extend_background_behind_borders = true,

        enable = {
          terminal = true,
          legacy_highlights = true, -- Improve compatibility for previous versions of Neovim
          migrations = true, -- Handle deprecated options automatically
        },

        styles = {
          bold = true,
          italic = true,
          transparency = false,
        },

        groups = {
          border = 'muted',
          link = 'iris',
          panel = 'surface',

          error = 'love',
          hint = 'iris',
          info = 'foam',
          note = 'pine',
          todo = 'rose',
          warn = 'gold',

          git_add = 'foam',
          git_change = 'rose',
          git_delete = 'love',
          git_dirty = 'rose',
          git_ignore = 'muted',
          git_merge = 'iris',
          git_rename = 'pine',
          git_stage = 'iris',
          git_text = 'rose',
          git_untracked = 'subtle',

          h1 = 'iris',
          h2 = 'foam',
          h3 = 'rose',
          h4 = 'gold',
          h5 = 'pine',
          h6 = 'foam',
        },

        palette = {
          -- Override the builtin palette per variant
          -- moon = {
          --     base = '#18191a',
          --     overlay = '#363738',
          -- },
        },

        highlight_groups = {
          -- Comment = { fg = "foam" },
          -- VertSplit = { fg = "muted", bg = "muted" },
        },

        before_highlight = function(group, highlight, palette)
          -- Disable all undercurls
          -- if highlight.undercurl then
          --     highlight.undercurl = false
          -- end
          --
          -- Change palette colour
          -- if highlight.fg == palette.pine then
          --     highlight.fg = palette.foam
          -- end
        end,
      })
    end,
  },

  {
    'rebelot/kanagawa.nvim',
    lazy = true,
    priority = 1000,
    keys = keys,
    config = function()
      require('kanagawa').setup({
        compile = false, -- enable compiling the colorscheme
        undercurl = true, -- enable undercurls
        commentStyle = { italic = true },
        functionStyle = {},
        keywordStyle = { italic = true },
        statementStyle = { bold = true },
        typeStyle = {},
        transparent = false, -- do not set background color
        dimInactive = false, -- dim inactive window `:h hl-NormalNC`
        terminalColors = true, -- define vim.g.terminal_color_{0,17}
        colors = { -- add/modify theme and palette colors
          palette = {},
          theme = {
            wave = {},
            lotus = {},
            dragon = {},
            all = {
              ui = { bg_gutter = 'none' },
            },
          },
        },
        overrides = function(colors) -- add/modify highlights
          return {}
        end,
        theme = 'dragon', -- Load "wave" theme when 'background' option is not set
        background = { -- map the value of 'background' option to a theme
          dark = 'dragon', -- try "dragon" !
          light = 'lotus',
        },
      })
    end,
  },

  {
    'sho-87/kanagawa-paper.nvim',
    lazy = true,
    priority = 1000,
    keys = keys,
    config = function()
      require('kanagawa-paper').setup({
        undercurl = true,
        transparent = false,
        gutter = false,
        dimInactive = false, -- disabled when transparent
        terminalColors = true,
        commentStyle = { italic = true },
        functionStyle = { italic = false },
        keywordStyle = { italic = true, bold = true },
        statementStyle = { italic = false, bold = false },
        typeStyle = { italic = false },
        colors = { theme = {}, palette = {} }, -- override default palette and theme colors
        overrides = function() -- override highlight groups
          return {}
        end,
      })
    end,
  },

  {
    'catppuccin/nvim',
    lazy = true,
    name = 'catppuccin',
    priority = 1000,
    keys = keys,
    config = function()
      require('catppuccin').setup({
        flavour = 'auto', -- latte, frappe, macchiato, mocha
        background = { -- :h background
          light = 'latte',
          dark = 'mocha',
        },
        transparent_background = false, -- disables setting the background color.
        show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
        term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
        dim_inactive = {
          enabled = false, -- dims the background color of inactive window
          shade = 'dark',
          percentage = 0.15, -- percentage of the shade to apply to the inactive window
        },
        no_italic = false, -- Force no italic
        no_bold = false, -- Force no bold
        no_underline = false, -- Force no underline
        styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
          comments = { 'italic' }, -- Change the style of comments
          conditionals = { 'italic' },
          loops = {},
          functions = {},
          keywords = {},
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          properties = {},
          types = {},
          operators = {},
          -- miscs = {}, -- Uncomment to turn off hard-coded styles
        },
        color_overrides = {},
        custom_highlights = {},
        default_integrations = true,
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          treesitter = true,
          notify = false,
          mini = {
            enabled = true,
            indentscope_color = '',
          },
          -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
        },
      })
    end,
  },

  {
    'EdenEast/nightfox.nvim',
    priority = 1000,
    lazy = true,
    keys = keys,
    config = function()
      require('nightfox').setup({
        options = {
          styles = {
            comments = 'italic',
            keywords = 'bold',
            types = 'italic,bold',
          },
        },
      })
    end,
  },

  {
    'bettervim/yugen.nvim',
    priority = 1000,
    lazy = true,
    keys = keys,
    config = function()
      local palette = require('yugen.palette')

      require('yugen').setup({
        highlight_groups = {
          ['@comment'] = { fg = palette.color500, style = 'italic' },
          -- ['@string'] = { fg = palette.primary },
        },
      })
    end,
  },

  {
    'cdmill/neomodern.nvim',
    priority = 1000,
    lazy = true,
    keys = keys,
    config = function()
      local c = require('neomodern.palette')[vim.g.neomodern_config and vim.g.neomodern_config.style or 'roseprime'].line
      local line = require('utils.misc').adjust_hex_brightness(c, 'lighten', 35)

      require('neomodern').setup({
        plain_float = false,
        -- The following table accepts values the same as the `gui` option for normal
        -- highlights. For example, `bold`, `italic`, `underline`, `none`.
        code_style = {
          comments = 'italic',
          conditionals = 'none',
          functions = 'none',
          keywords = 'none',
          -- Markdown headings
          headings = 'bold',
          operators = 'none',
          keyword_return = 'none',
          strings = 'none',
          variables = 'none',
        },
        highlights = {
          CursorLine = { bg = line },
          CursorLineSign = { bg = line },
          CursorLineNr = { bg = line },
        },
      })
    end,
  },

  {
    'ramojus/mellifluous.nvim',
    priority = 1000,
    lazy = true,
    keys = keys,
    config = function()
      require('mellifluous').setup({
        dim_inactive = false,
        colorset = 'mellifluous',
        styles = { -- see :h attr-list for options. set {} for NONE, { option = true } for option
          main_keywords = { italic = true },
          other_keywords = { italic = true },
          types = {},
          operators = {},
          strings = {},
          functions = { italic = true },
          constants = {},
          comments = { italic = true },
          markup = {
            headings = { bold = true },
          },
          folds = {},
        },
        transparent_background = {
          enabled = false,
          floating_windows = true,
          telescope = true,
          file_tree = true,
          cursor_line = true,
          status_line = false,
        },
        flat_background = {
          line_numbers = true,
          floating_windows = true,
          file_tree = true,
          cursor_line_number = true,
        },
        plugins = {
          cmp = true,
          gitsigns = true,
          indent_blankline = true,
          nvim_tree = {
            enabled = true,
            show_root = false,
          },
          neo_tree = {
            enabled = true,
          },
          telescope = {
            enabled = true,
            nvchad_like = true,
          },
          startify = true,
        },
      })
    end,
  },

  {
    'mellow-theme/mellow.nvim',
    lazy = true,
    priority = 1000,
    keys = keys,
    config = function()
      local adjust_hex = require('utils.misc').adjust_hex_brightness

      vim.g.mellow_italic_comments = true
      vim.g.mellow_italic_functions = true
      vim.g.mellow_italic_booleans = false
      vim.g.mellow_italic_variables = false
      vim.g.mellow_italic_keywords = true
      vim.g.mellow_highlight_overrides = {
        ['CursorLine'] = { bg = adjust_hex('#1b1b1b', 'lighten', 35) },
      }
    end,
  },

  {
    'eddyekofo94/gruvbox-flat.nvim',
    lazy = true,
    priority = 1000,
    keys = keys,
    config = function()
      vim.g.gruvbox_flat_style = 'dark'
      vim.g.gruvbox_theme = {
        WhichKeyDesc = { fg = 'fg' },
        WhichKeyGroup = { fg = 'fg' },
      }
    end,
  },

  {
    'cpwrs/americano.nvim',
    lazy = true,
    priority = 1000,
    keys = keys,
    config = function()
      require('americano').setup({
        terminal = true,
        overrides = {
          ['@tag.tsx'] = { link = '@constant' },
          ['@tag.builtin.tsx'] = { link = '@constant' },
          ['@tag.delimiter.tsx'] = { link = 'Delimiter' },
          ['DiagnosticUnnecessary'] = { link = '@markup.strikethrough' },
          ['Folded'] = { link = 'DevIconAdaBody' },
        },
      })
    end,
  },

  {
    'dgox16/oldworld.nvim',
    lazy = true,
    priority = 1000,
    keys = keys,
    config = function()
      local adjust_hex = require('utils.misc').adjust_hex_brightness

      require('oldworld').setup({
        variants = 'default', -- default, oled, cooler
        highlight_overrides = {
          CursorLine = { bg = adjust_hex('#1b1b1c', 'lighten', 25) },
          Folded = { bg = adjust_hex('#1b1b1c', 'lighten', 10) },
        },
      })
    end,
  },
}
