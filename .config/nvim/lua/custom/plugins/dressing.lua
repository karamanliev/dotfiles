return {
  'stevearc/dressing.nvim',
  event = 'VeryLazy',
  opts = {},
  config = function()
    require('dressing').setup {
      input = {
        get_config = function()
          if vim.api.nvim_buf_get_option(0, 'filetype') == 'NvimTree' then
            return { enabled = false }
          end
        end,
      },
    }
  end,
}
