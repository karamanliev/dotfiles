return {
  'nvim-lualine/lualine.nvim',
  -- enabled = false,
  event = { 'BufReadPre', 'BufNewFile' },
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

    local lint_progress = function()
      local linters = require('lint').get_running()
      if #linters == 0 then
        return '󰦕'
      end
      return '󱉶 ' .. table.concat(linters, ', ')
    end

    local colors = require('tokyonight.colors').setup()
    local noice = require 'noice'

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
        globalstatus = true,
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
        },
        lualine_c = {
          {
            'filetype',
            icon_only = true,
            padding = {
              left = 1,
              right = 0,
            },
          },
          {
            'filename',
            file_status = true,
            path = 1,
          },
          -- 'searchcount',
          -- { 'buffers', icons_enabled = false, use_mode_colors = true },
        },
        lualine_x = {
          -- show macro recording
          {
            noice.api.statusline.mode.get,
            cond = noice.api.statusline.mode.has,
            color = { fg = colors.red },
          },
          { 'diagnostics', icons_enabled = true },
          lint_progress,
          'copilot',
          buff_count,
          -- 'fileformat',
          -- 'encoding',
        },
        lualine_y = {
          'progress',
        },
        lualine_z = {
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
