return {
  -- Search & Replace file/project
  {
    'nvim-pack/nvim-spectre',
    cmd = {
      'Spectre',
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    keys = {
      {
        '<Leader>ss',
        function()
          require('spectre').toggle()
        end,
        desc = 'Spectre',
      },
      {
        '<Leader>sw',
        function()
          require('spectre').open_visual({ select_word = true })
        end,
        desc = 'Spectre Word',
      },
      {
        '<Leader>sf',
        function()
          require('spectre').open_file_search({ select_word = true })
        end,
        desc = 'Spectre File',
      },
    },
    config = function()
      require('spectre').setup({
        mapping = {
          ['esc'] = {
            map = '<esc>',
            cmd = "<cmd>lua require('spectre').close()<cr>",
            desc = 'Close',
          },
          ['q'] = {
            map = 'q',
            cmd = "<cmd>lua require('spectre').close()<cr>",
            desc = 'Close',
          },
        },
      })
    end,
  },

  -- C+d from VSCode
  {
    'mg979/vim-visual-multi',
    event = { 'BufReadPre', 'BufNewFile' },
    branch = 'master',
    init = function()
      vim.g.VM_leader = '<space>s'
      vim.g.VM_set_statusline = 0
      vim.g.VM_theme = 'neon'
    end,
  },
}
