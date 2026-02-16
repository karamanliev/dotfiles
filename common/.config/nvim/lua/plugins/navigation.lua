return {
  -- Tmux Navigator
  {
    'alexghergh/nvim-tmux-navigation',
    keys = {
      { '<C-h>', '<cmd>NvimTmuxNavigateLeft<cr>', desc = 'Nvim Tmux Navigate Left' },
      { '<C-j>', '<cmd>NvimTmuxNavigateDown<cr>', desc = 'Nvim Tmux Navigate Down' },
      { '<C-k>', '<cmd>NvimTmuxNavigateUp<cr>', desc = 'Nvim Tmux Navigate Up' },
      { '<C-l>', '<cmd>NvimTmuxNavigateRight<cr>', desc = 'Nvim Tmux Navigate Right' },
    },
    config = function()
      local nvim_tmux_nav = require('nvim-tmux-navigation')

      nvim_tmux_nav.setup({
        disable_when_zoomed = true, -- defaults to false
      })

      vim.keymap.set('n', '<C-h>', nvim_tmux_nav.NvimTmuxNavigateLeft)
      vim.keymap.set('n', '<C-j>', nvim_tmux_nav.NvimTmuxNavigateDown)
      vim.keymap.set('n', '<C-k>', nvim_tmux_nav.NvimTmuxNavigateUp)
      vim.keymap.set('n', '<C-l>', nvim_tmux_nav.NvimTmuxNavigateRight)
      vim.keymap.set('n', '<C-\\>', nvim_tmux_nav.NvimTmuxNavigateLastActive)
    end,
  },
}
