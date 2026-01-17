return {
  {
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    lazy = true,
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
    'olivercederborg/poimandres.nvim',
    priority = 1000,
    lazy = true,
    config = function()
      require('poimandres').setup({
        bold_vert_split = false, -- use bold vertical separators
        dim_nc_background = false, -- dim 'non-current' window backgrounds
        disable_background = false, -- disable background
        disable_float_background = false, -- disable background for floats
        disable_italics = false, -- disable italics
      })
    end,
    init = function()
      vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        pattern = { 'poimandres' },
        callback = function()
          vim.api.nvim_set_hl(0, 'LspReferenceText', { underline = true, bold = true })
          vim.api.nvim_set_hl(0, 'LspReferenceRead', { underline = true, bold = true })
          vim.api.nvim_set_hl(0, 'LspReferenceWrite', { underline = true, bold = true })
        end,
      })
    end,
  },

  {
    'rose-pine/neovim',
    name = 'rose-pine',
    lazy = true,
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
    'thesimonho/kanagawa-paper.nvim',
    lazy = true,
    priority = 1000,
    config = function()
      require('kanagawa-paper').setup({
        undercurl = true,
        transparent = false,
        gutter = false,
        diag_background = true,
        dim_inactive = true,
        terminal_colors = true,
        cache = false,

        styles = {
          comment = { italic = true },
          functions = { italic = false },
          keyword = { italic = true, bold = true },
          statement = { italic = false, bold = false },
          type = { italic = false },
        },

        -- override default palette and theme colors
        colors = {
          palette = {},
          theme = {
            ink = {},
            canvas = {},
          },
        },
        -- adjust overall color balance for each theme [-1, 1]
        color_offset = {
          ink = { brightness = 0, saturation = 0 },
          canvas = { brightness = 0, saturation = 0 },
        },
        -- override highlight groups
        overrides = function(colors)
          return {
            -- Assign a static color to strings
            ['@tag.tsx'] = { fg = colors.palette.dragonBlue, italic = true },
            CursorLine = { bg = require('utils.highlights').adjust_hex_brightness(colors.theme.ui.bg_cursorline, 'darken', 10) },
          }
        end,
      })
    end,
  },

  {
    'dgox16/oldworld.nvim',
    lazy = true,
    priority = 1000,
    config = function()
      local adjust_hex = require('utils.highlights').adjust_hex_brightness
      local p = require('oldworld.palette')
      local u = require('oldworld.utils.color_utils')
      local DARKEN_AMOUNT = 0.20

      require('oldworld').setup({
        variant = 'default', -- default, oled, cooler
        highlight_overrides = {
          CursorLine = { bg = adjust_hex('#1b1b1c', 'lighten', 25) },
          Folded = { bg = adjust_hex('#1b1b1c', 'lighten', 10) },
          DiagnosticUnderlineError = { sp = '#ea83a5', undercurl = true },
          DiagnosticUnderlineWarn = { sp = '#e6b99d', undercurl = true },
          DiagnosticUnderlineInfo = { sp = '#aca1cf', undercurl = true },
          DiagnosticUnderlineHint = { sp = '#85b5ba', undercurl = true },
          DiagnosticUnderlineOk = { sp = 'NvimLightGreen', undercurl = true },
          DiffAdd = { bg = u.darken(p.green, DARKEN_AMOUNT, p.bg) },
          DiffChange = { bg = u.darken(p.blue, DARKEN_AMOUNT, p.bg) },
          DiffDelete = { bg = u.darken(p.red, DARKEN_AMOUNT, p.bg) },
          DiffText = { bg = u.darken(p.blue, 0.50, p.bg) },
        },
      })
    end,
  },
}
