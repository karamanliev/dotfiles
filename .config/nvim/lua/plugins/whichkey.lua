return {
  -- Visualizie motions
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    config = function()
      local wk = require('which-key')
      wk.setup({
        preset = 'helix',
        win = {
          border = 'none',
          padding = { 1, 2 },
        },
      })

      -- Document existing key chains
      wk.add({
        { '<leader>c', group = 'Code' },
        { '<leader>d', group = 'Document' },
        { '<leader>f', group = 'Find' },
        { '<leader>g', group = 'Git' },
        { '<leader>d', group = 'Diff' },
        { '<leader>s', group = 'Session' },
        { '<leader>t', group = 'Toggle' },
      })
      -- visual mode
      wk.add({
        { '<leader>g', desc = 'Git', mode = 'v' },
      })

      wk.add({
        { '\\Z', '<cmd>ClearBuffers!<CR>', desc = 'Clear all buffers (unsaved also), but this one' },
        { '\\W', '<cmd>WriteWithoutFormat<CR>', desc = 'Write (No Autoformat)' },
        { '\\z', '<cmd>ClearBuffers<CR>', desc = 'Clear all buffers, but this one' },
      })
    end,
  },
}
