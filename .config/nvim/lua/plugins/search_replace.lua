return {
  -- Subsitute motions
  {
    'gbprod/substitute.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local substitute = require 'substitute'
      substitute.setup()

      -- keymaps
      vim.keymap.set('n', 's', substitute.operator, { desc = 'Substitute with motion' })
      vim.keymap.set('n', 'ss', substitute.line, { desc = 'Substitute line' })
      vim.keymap.set('n', 'S', substitute.eol, { desc = 'Substitute to end of line' })
      vim.keymap.set('x', 's', substitute.visual, { desc = 'Substitute in visual mode' })
    end,
  },
  {
    'nvim-pack/nvim-spectre',
    cmd = {
      'Spectre',
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    keys = {
      {
        '<Leader>ss',
        function()
          require('spectre').toggle()
        end,
        desc = 'Spectre',
      },
      {
        '<Leader>sw',
        function()
          require('spectre').open_visual { select_word = true }
        end,
        desc = 'Spectre Word',
      },
      {
        '<Leader>sf',
        function()
          require('spectre').open_file_search { select_word = true }
        end,
        desc = 'Spectre File',
      },
    },
    config = function()
      require('spectre').setup {
        mapping = {
          ['esc'] = {
            map = '<esc>',
            cmd = "<cmd>lua require('spectre').close()<cr>",
            desc = 'Close',
          },
          ['q'] = {
            map = 'q',
            cmd = "<cmd>lua require('spectre').close()<cr>",
            desc = 'Close',
          },
        },
      }
    end,
  },
}
