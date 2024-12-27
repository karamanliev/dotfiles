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

  {
    'abecodes/tabout.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('tabout').setup({
        tabkey = '<Tab>', -- key to trigger tabout, set to an empty string to disable
        backwards_tabkey = '<S-Tab>', -- key to trigger backwards tabout, set to an empty string to disable
        act_as_tab = true, -- shift content if tab out is not possible
        act_as_shift_tab = false, -- reverse shift content if tab out is not possible (if your keyboard/terminal supports <S-Tab>)
        default_tab = '<C-t>', -- shift default action (only at the beginning of a line, otherwise <TAB> is used)
        default_shift_tab = '<C-d>', -- reverse shift default action,
        enable_backwards = true, -- well ...
        completion = false, -- if the tabkey is used in a completion pum
        tabouts = {
          { open = "'", close = "'" },
          { open = '"', close = '"' },
          { open = '`', close = '`' },
          { open = '(', close = ')' },
          { open = '[', close = ']' },
          { open = '{', close = '}' },
          { open = '<', close = '>' },
        },
        ignore_beginning = true, --[[ if the cursor is at the beginning of a filled element it will rather tab out than shift the content ]]
        exclude = {}, -- tabout will ignore these filetypes
      })
    end,
    dependencies = { -- These are optional
      'nvim-treesitter/nvim-treesitter',
      'L3MON4D3/LuaSnip',
      'hrsh7th/nvim-cmp',
    },
    opt = true, -- Set this to true if the plugin is optional
  },
}
