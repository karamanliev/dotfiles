return {
  'nvim-lualine/lualine.nvim',
  -- enabled = false,
  event = 'VeryLazy',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local colors = require('tokyonight.colors').setup()
    require('lualine').setup {
      options = {
        icons_enabled = true,
        theme = 'tokyonight',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
          statusline = {
            'alpha',
            --[[ 'neo-tree' ]]
          },
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = true,
        refresh = {
          statusline = 1000,
        },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = {
          'branch',
          {
            'diff',
            diff_color = {
              added = { fg = colors.git.add },
              modified = { fg = colors.git.change },
              removed = { fg = colors.git.delete },
            },
          },
          { 'diagnostics', icons_enabled = true },
        },
        lualine_c = {
          { 'filename', file_status = true, path = 4, shorting_target = 100 },
          -- { 'buffers', icons_enabled = false, use_mode_colors = true },
        },
        lualine_x = { 'searchcount', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { 'filename', file_status = true, path = 4 } },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {},
      },
      extensions = { 'neo-tree' },
    }
  end,
}
