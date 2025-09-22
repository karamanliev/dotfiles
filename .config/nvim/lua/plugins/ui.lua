return {
  -- Highlight colors HEX/RGB/HSV/HSL
  {
    'brenoprata10/nvim-highlight-colors',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('nvim-highlight-colors').setup({
        -- render = 'virtual',
        virtual_symbol = '■',
        enable_tailwind = true,
        exclude_filetypes = {
          'bigfile',
        },
      })
    end,
  },

  -- Highlight todo, notes, etc in comments
  {
    'folke/todo-comments.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    keys = {
      {
        ']t',
        function()
          require('todo-comments').jump_next()
        end,
        desc = 'Next TODO comment',
      },
      {
        '[t',
        function()
          require('todo-comments').jump_prev()
        end,
        desc = 'Previous TODO comment',
      },
    },
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },

  -- vim.input and vim.select replacement
  {
    'stevearc/dressing.nvim',
    enabled = false,
    event = { 'VeryLazy' },
    opts = {},
    config = function()
      require('dressing').setup({
        select = {
          get_config = function(opts)
            if opts.kind == 'codeaction' or 'Package Info' then
              return {
                backend = 'builtin',
              }
            end
          end,
        },
      })
    end,
  },

  -- indents
  {
    'shellRaining/hlchunk.nvim',
    enabled = false,
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('hlchunk').setup({
        chunk = {
          enable = true,
          priority = 15,
          style = {
            { fg = '#806d9c' }, -- TODO: link to some highlight?
            { link = 'DiagnosticSignError' },
          },
          use_treesitter = true,
          chars = {
            horizontal_line = '─',
            vertical_line = '│',
            left_top = '╭',
            left_bottom = '╰',
            right_arrow = '>',
          },
          textobject = '',
          max_file_size = 1024 * 1024,
          error_sign = true,
          -- animation related
          duration = 0,
          delay = 0,
        },
        indent = {
          enable = true,
          priority = 10,
          style = {
            { link = 'Whitespace' },
          },
          use_treesitter = false,
          chars = { '┊' },
          ahead_lines = 5,
          delay = 100,
        },
        line_num = {
          enable = false,
          style = '#806d9c',
        },
      })
    end,
  },
}
