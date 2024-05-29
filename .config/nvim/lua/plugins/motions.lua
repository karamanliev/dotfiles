return {
  -- Visualizie motions
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    config = function() -- This is the function that runs, AFTER loading
      local wk = require 'which-key'
      wk.setup()

      -- Document existing key chains
      wk.register {
        ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
        ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
        ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
        ['<leader>f'] = { name = '[F]ind', _ = 'which_key_ignore' },
        ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
        ['<leader>t'] = { name = '[T]oggle', _ = 'which_key_ignore' },
        ['<leader>l'] = { name = '[L]ist', _ = 'which_key_ignore' },
        ['<leader>h'] = { name = 'Git [H]unk', _ = 'which_key_ignore' },
        ['<leader>x'] = { name = 'Trouble', _ = 'which_key_ignore' },
      }
      -- visual mode
      wk.register({
        ['<leader>h'] = { 'Git [H]unk' },
      }, { mode = 'v' })

      wk.register({
        q = {
          name = 'Buffer',
          q = { '<cmd>q<CR>', 'Quit' },
          Q = { '<cmd>q!<CR>', 'Quit without saving' },
          w = { '<cmd>w<CR>', 'Write' },
          W = { '<cmd>wq<CR>', 'Write and quit' },
          x = { '<cmd>qa<CR>', 'Quit all' },
          X = { '<cmd>qa!<CR>', 'Quit all without saving' },
          s = { '<cmd>wa<CR>', 'Save all' },
          S = { '<cmd>waq<CR>', 'Save all and quit' },
          z = { '<cmd>ClearBuffers<CR>', 'Clear all buffers, but this one' },
          h = { '<cmd>leftabove vsplit<CR>', 'Split vertical left' },
          l = { '<cmd>vsplit<CR>', 'Split vertical right' },
          j = { '<cmd>split<CR>', 'Split horizontal down' },
          k = { '<cmd>top split<CR>', 'Split horizontal up' },
        },
      }, { prefix = '<leader>' })
    end,
  },

  -- Comment motions
  {
    'numToStr/Comment.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'JoosepAlviste/nvim-ts-context-commentstring' },
    config = function()
      local ts_context_commentstring = require 'ts_context_commentstring.integrations.comment_nvim'
      ---@diagnostic disable-next-line: missing-fields
      require('Comment').setup {
        pre_hook = ts_context_commentstring.create_pre_hook(),
      }
    end,
  },

  -- Surround motions
  {
    'kylechui/nvim-surround',
    version = '*', -- Use for stability; omit to use `main` branch for the latest features
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('nvim-surround').setup {}
    end,
  },
  {
    'mg979/vim-visual-multi',
    event = { 'BufReadPre', 'BufNewFile' },
    branch = 'master',
  },
}
