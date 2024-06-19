return {
  {
    'christoomey/vim-tmux-navigator',
    cmd = {
      'TmuxNavigateLeft',
      'TmuxNavigateDown',
      'TmuxNavigateUp',
      'TmuxNavigateRight',
      'TmuxNavigatePrevious',
    },
    keys = {
      { '<c-h>', '<cmd><C-U>TmuxNavigateLeft<cr>' },
      { '<c-j>', '<cmd><C-U>TmuxNavigateDown<cr>' },
      { '<c-k>', '<cmd><C-U>TmuxNavigateUp<cr>' },
      { '<c-l>', '<cmd><C-U>TmuxNavigateRight<cr>' },
      { '<c-\\>', '<cmd><C-U>TmuxNavigatePrevious<cr>' },
    },
  },

  {
    'ThePrimeagen/harpoon',
    event = { 'BufReadPre', 'BufNewFile' },
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local harpoon = require('harpoon')

      harpoon:setup()

      vim.keymap.set('n', '<leader>a', function()
        harpoon:list():add()
      end, { desc = '[A]dd to Harpoon' })

      vim.keymap.set('n', '<C-e>', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = 'Toggle Harpoon' })

      vim.keymap.set('n', '<M-1>', function()
        harpoon:list():select(1)
      end, { desc = 'Select 1st Harpoon' })
      vim.keymap.set('n', '<M-2>', function()
        harpoon:list():select(2)
      end, { desc = 'Select 2nd Harpoon' })
      vim.keymap.set('n', '<M-3>', function()
        harpoon:list():select(3)
      end, { desc = 'Select 3rd Harpoon' })
      vim.keymap.set('n', '<M-4>', function()
        harpoon:list():select(4)
      end, { desc = 'Select 4th Harpoon' })

      vim.keymap.set('n', '<leader><M-1>', function()
        harpoon:list():replace_at(1)
      end, { desc = 'Replace 1st Harpoon' })
      vim.keymap.set('n', '<leader><M-2>', function()
        harpoon:list():replace_at(2)
      end, { desc = 'Replace 2nd Harpoon' })
      vim.keymap.set('n', '<leader><M-3>', function()
        harpoon:list():replace_at(3)
      end, { desc = 'Replace 3rd Harpoon' })
      vim.keymap.set('n', '<leader><M-4>', function()
        harpoon:list():replace_at(4)
      end, { desc = 'Replace 4th Harpoon' })

      -- Toggle previous & next buffers stored within Harpoon list
      vim.keymap.set('n', '<C-S-p>', function()
        harpoon:list():prev({ ui_nav_wrap = true })
      end, { desc = 'Previous Harpoon' })
      vim.keymap.set('n', '<C-S-n>', function()
        harpoon:list():next({ ui_nav_wrap = true })
      end, { desc = 'Next Harpoon' })
    end,
  },
}
