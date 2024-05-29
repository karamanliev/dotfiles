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

  -- Move lines and blocks up and down
  {
    'matze/vim-move',
    event = { 'BufReadPre', 'BufNewFile' },
    init = function()
      -- Because keymaps <M-h> and <M-l> are used for prev/next buffer
      vim.g.move_map_keys = 0

      vim.keymap.set('v', '<M-k>', '<Plug>MoveBlockUp')
      vim.keymap.set('v', '<M-j>', '<Plug>MoveBlockDown')
      vim.keymap.set('n', '<M-k>', '<Plug>MoveLineUp')
      vim.keymap.set('n', '<M-j>', '<Plug>MoveLineDown')
    end,
  },
}
