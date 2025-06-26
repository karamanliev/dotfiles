return {
  -- Make HTTP requests with curl from Neovim
  {
    'mistweaverco/kulala.nvim',
    enabled = false,
    ft = 'http',
    keys = {
      {
        '<leader>oK',
        function()
          require('kulala').scratchpad()
        end,
        desc = 'Kulala Scratchpad',
      },
    },
    opts = {
      winbar = true,
    },
  },
}
