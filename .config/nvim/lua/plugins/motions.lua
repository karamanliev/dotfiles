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
    'echasnovski/mini.move',
    version = false,
    keys = {
      '<M-j>',
      '<M-k>',
      '<M-h>',
      '<M-l>',
    },
    config = function()
      require('mini.move').setup({
        mappings = {
          line_left = '<nop>',
          line_right = '<nop>',
        },
      })
    end,
  },

  -- Yank
  {
    'ibhagwan/smartyank.nvim',
    config = function()
      require('smartyank').setup({
        highlight = {
          enabled = true, -- highlight yanked text
          higroup = 'IncSearch', -- highlight group of yanked text
          timeout = 650, -- timeout for clearing the highlight
        },
        clipboard = {
          enabled = true,
        },
        tmux = {
          enabled = true,
          -- remove `-w` to disable copy to host client's clipboard
          cmd = { 'tmux', 'set-buffer', '-w' },
        },
        osc52 = {
          enabled = true,
          -- escseq = 'tmux',     -- use tmux escape sequence, only enable if
          -- you're using tmux and have issues (see #4)
          ssh_only = true, -- false to OSC52 yank also in local sessions
          silent = false, -- true to disable the "n chars copied" echo
          echo_hl = 'Directory', -- highlight group of the OSC52 echo message
        },
        -- By default copy is only triggered by "intentional yanks" where the
        -- user initiated a `y` motion (e.g. `yy`, `yiw`, etc). Set to `false`
        -- if you wish to copy indiscriminately:
        -- validate_yank = false,
        --
        -- For advanced customization set to a lua function returning a boolean
        -- for example, the default condition is:
        -- validate_yank = function() return vim.v.operator == "y" end,
      })
    end,
  },
}
