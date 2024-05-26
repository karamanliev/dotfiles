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
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('nvim-highlight-colors').setup()
    end,
  },

  -- Highlight todo, notes, etc in comments
  {
    'folke/todo-comments.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },

  -- vim.input and vim.select replacement
  {
    'stevearc/dressing.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
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

  -- Scrollbar
  {
    'petertriho/nvim-scrollbar',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { { 'kevinhwang91/nvim-hlslens' } },
    config = function()
      local colors = require('tokyonight.colors').setup()

      require('scrollbar').setup {
        handle = {
          color = colors.bg_highlight,
        },
        marks = {
          Search = { color = colors.orange },
          Error = { color = colors.error },
          Warn = { color = colors.warning },
          Info = { color = colors.info },
          Hint = { color = colors.hint },
          Misc = { color = colors.purple },
          GitAdd = { color = colors.info },
        },
        handlers = {
          cursor = false,
          search = true,
          gitsigns = true,
        },
      }
    end,
  },

  -- Noice (nice cmd/search line ui + notifications)
  {
    'folke/noice.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      'MunifTanjim/nui.nvim',
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      -- 'rcarriga/nvim-notify',
    },
    keys = {
      {
        '<leader>ll',
        function()
          require('noice').cmd 'telescope'
        end,
        desc = 'List [L]ogs',
      },
    },
    config = function()
      require('noice').setup {
        lsp = {
          -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
          override = {
            ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
            ['vim.lsp.util.stylize_markdown'] = true,
            ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp
          },
          progress = {
            enabled = false,
          },
        },
        -- you can enable a preset for easier configuration
        presets = {
          bottom_search = false, -- use a classic bottom cmdline for search
          command_palette = false, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false, -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = true, -- add a border to hover docs and signature help
        },
        -- hide search virtual text
        routes = {
          {
            filter = {
              event = 'msg_show',
              kind = 'search_count',
            },
            opts = { skip = true },
          },
        },
      }
    end,
  },
}
