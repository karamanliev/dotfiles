return {
  -- Visualizie motions
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    config = function()
      local wk = require('which-key')
      wk.setup({
        preset = 'modern',
      })

      -- Document existing key chains
      wk.add({
        { '<leader>b', group = 'Bookmarks' },
        { '<leader>c', group = 'Code' },
        { '<leader>d', group = 'Document' },
        { '<leader>f', group = 'Find' },
        { '<leader>g', group = 'Git' },
        { '<leader>h', group = 'Git Hunk' },
        { '<leader>l', group = 'List' },
        { '<leader>s', group = 'Search' },
        { '<leader>t', group = 'Toggle' },
        { '<leader>y', group = 'Yank' },
      })
      -- visual mode
      wk.add({
        { '<leader>h', desc = 'Git Hunk', mode = 'v' },
      })

      wk.add({
        { '\\D', '<cmd>bd!<CR>', desc = 'Buffer delete without saving' },
        { '\\C', '<cmd>close!<CR>', desc = 'Close without saving' },
        { '\\Q', '<cmd>q!<CR>', desc = 'Quit without saving' },
        { '\\X', '<cmd>qa!<CR>', desc = 'Quit all without saving' },
        { '\\Z', '<cmd>ClearBuffers!<CR>', desc = 'Clear all buffers (unsaved also), but this one' },
        { '\\a', '<cmd>e #<CR>', desc = 'Last buffer' },
        { '\\d', '<cmd>bd<CR>', desc = 'Buffer delete' },
        { '\\c', '<cmd>close<CR>', desc = 'Close' },
        { '\\q', '<cmd>q<CR>', desc = 'Quit' },
        { '\\w', '<cmd>w<CR>', desc = 'Write' },
        { '\\x', '<cmd>qa<CR>', desc = 'Quit all' },
        { '\\z', '<cmd>ClearBuffers<CR>', desc = 'Clear all buffers, but this one' },
      })

      wk.add({
        { '\\H', '<C-w>H', desc = 'Move window to left' },
        { '\\J', '<C-w>J', desc = 'Move window to bottom' },
        { '\\K', '<C-w>K', desc = 'Move window to top' },
        { '\\L', '<C-w>L', desc = 'Move window to right' },
        { '\\h', '<cmd>leftabove vsplit<CR>', desc = 'Split vertical left' },
        { '\\j', '<cmd>split<CR>', desc = 'Split horizontal down' },
        { '\\k', '<cmd>top split<CR>', desc = 'Split horizontal up' },
        { '\\l', '<cmd>vsplit<CR>', desc = 'Split vertical right' },
      })
    end,
  },
}
