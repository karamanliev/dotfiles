return {
  -- Comment motions
  {
    'numToStr/Comment.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'JoosepAlviste/nvim-ts-context-commentstring' },
    config = function()
      local ts_context_commentstring = require('ts_context_commentstring.integrations.comment_nvim')
      ---@diagnostic disable-next-line: missing-fields
      require('Comment').setup({
        pre_hook = ts_context_commentstring.create_pre_hook(),
      })
    end,
  },

  -- Surround motions
  {
    'kylechui/nvim-surround',
    version = '*', -- Use for stability; omit to use `main` branch for the latest features
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('nvim-surround').setup({})
    end,
  },

  -- Subsitute motions
  {
    'gbprod/substitute.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local substitute = require('substitute')
      substitute.setup()

      -- keymaps
      vim.keymap.set('n', 's', substitute.operator, { desc = 'Substitute with motion' })
      vim.keymap.set('n', 'ss', substitute.line, { desc = 'Substitute line' })
      vim.keymap.set('n', 'S', substitute.eol, { desc = 'Substitute to end of line' })
      vim.keymap.set('x', 's', substitute.visual, { desc = 'Substitute in visual mode' })
    end,
  },
}
