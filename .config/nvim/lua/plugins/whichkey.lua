return {
  -- Visualizie motions
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    config = function() -- This is the function that runs, AFTER loading
      local wk = require('which-key')
      wk.setup()

      -- Document existing key chains
      wk.register({
        ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
        ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
        -- ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
        ['<leader>f'] = { name = '[F]ind', _ = 'which_key_ignore' },
        ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
        ['<leader>t'] = { name = '[T]oggle', _ = 'which_key_ignore' },
        ['<leader>l'] = { name = '[L]ist', _ = 'which_key_ignore' },
        ['<leader>h'] = { name = 'Git [H]unk', _ = 'which_key_ignore' },
        ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
        ['<leader>y'] = { name = '[Y]ank', _ = 'which_key_ignore' },
      })
      -- visual mode
      wk.register({
        ['<leader>h'] = { 'Git [H]unk' },
      }, { mode = 'v' })

      wk.register({
        a = { '<cmd>e #<CR>', 'Last buffer' },
        q = { '<cmd>q<CR>', 'Quit' },
        Q = { '<cmd>q!<CR>', 'Quit without saving' },
        b = { '<cmd>bd<CR>', 'Buffer delete' },
        B = { '<cmd>bd!<CR>', 'Buffer delete without saving' },
        c = { '<cmd>close<CR>', 'Close' },
        C = { '<cmd>close!<CR>', 'Close without saving' },
        w = { '<cmd>w<CR>', 'Write' },
        z = { '<cmd>ClearBuffers<CR>', 'Clear all buffers, but this one' },
        Z = { '<cmd>ClearBuffers!<CR>', 'Clear all buffers (unsaved also), but this one' },
        x = { '<cmd>qa<CR>', 'Quit all' },
        X = { '<cmd>qa!<CR>', 'Quit all without saving' },
      }, { prefix = '\\' })

      wk.register({
        h = { '<cmd>leftabove vsplit<CR>', 'Split vertical left' },
        l = { '<cmd>vsplit<CR>', 'Split vertical right' },
        j = { '<cmd>split<CR>', 'Split horizontal down' },
        k = { '<cmd>top split<CR>', 'Split horizontal up' },
        L = { '<C-w>L', 'Move window to right' },
        H = { '<C-w>H', 'Move window to left' },
        J = { '<C-w>J', 'Move window to bottom' },
        K = { '<C-w>K', 'Move window to top' },
      }, { prefix = '\\' })
    end,
  },
}
