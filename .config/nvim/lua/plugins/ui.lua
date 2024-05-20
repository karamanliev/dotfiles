return {
  -- Theme
  {
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      require('tokyonight').setup {
        style = 'moon',
        transparent = false,
        dim_inactive = true,
      }

      vim.cmd.colorscheme 'tokyonight'
    end,
  },

  -- Highlight colors HEX/RGB/HSV/HSL
  {
    'brenoprata10/nvim-highlight-colors',
    event = 'VeryLazy',
    config = function()
      require('nvim-highlight-colors').setup()
    end,
  },

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  -- vim.input and vim.select replacement
  {
    'stevearc/dressing.nvim',
    event = 'VeryLazy',
    opts = {},
    config = function()
      require('dressing').setup {
        input = {
          get_config = function()
            if vim.api.nvim_buf_get_option(0, 'filetype') == 'NvimTree' then
              return { enabled = false }
            end
          end,
        },
      }
    end,
  },

  -- Colorized indents
  {
    'lukas-reineke/indent-blankline.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    main = 'ibl',
    enabled = false,
    config = function()
      require('ibl').setup {
        scope = {
          show_start = false,
        },
        indent = {
          char = '┊',
          tab_char = '┊',
          smart_indent_cap = true,
        },
        whitespace = {
          remove_blankline_trail = true,
        },
      }
    end,
  },
  {
    'nvimdev/indentmini.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    enabled = true,
    config = function()
      require('indentmini').setup {
        char = '┊',
      }
    end,
  },
}
