return {
  {
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
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
    config = function()
      vim.g.bones_compat = 1
      -- vim.cmd.colorscheme('tokyobones')
    end,
  },

  {
    'nyoom-engineering/oxocarbon.nvim',
    priority = 1000,
  },

  {
    'olivercederborg/poimandres.nvim',
    priority = 1000,
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
}
