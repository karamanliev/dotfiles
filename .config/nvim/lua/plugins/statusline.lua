return {
  'nvim-lualine/lualine.nvim',
  -- enabled = false,
  event = 'VeryLazy',
  dependencies = { 'nvim-tree/nvim-web-devicons', 'AndreM222/copilot-lualine' },
  config = function()
    -- use gitsigns as diff_source
    local function diff_source()
      local gitsigns = vim.b.gitsigns_status_dict
      if gitsigns then
        return {
          added = gitsigns.added,
          modified = gitsigns.changed,
          removed = gitsigns.removed,
        }
      end
    end

    -- count buffers
    local function buff_count()
      return '  ' .. vim.fn.len(vim.fn.getbufinfo { buflisted = 1 })
    end

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
            -- 'neo-tree',
          },
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
          statusline = 1000,
        },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = {
          { 'b:gitsigns_head', icon = ' ' },
          {
            'diff',
            diff_color = {
              added = { fg = colors.git.add },
              modified = { fg = colors.git.change },
              removed = { fg = colors.git.delete },
            },
            source = diff_source,
          },
          { 'diagnostics', icons_enabled = true },
        },
        lualine_c = {
          { 'filename', file_status = true, path = 4 },
          -- { 'buffers', icons_enabled = false, use_mode_colors = true },
        },
        lualine_x = {
          'copilot',
          'fileformat',
          'encoding',
          'filetype',
        },
        lualine_y = {
          buff_count,
          'progress',
        },
        lualine_z = {
          'searchcount',
          'location',
        },
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
