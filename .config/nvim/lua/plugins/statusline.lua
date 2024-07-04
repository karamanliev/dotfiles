return {
  'nvim-lualine/lualine.nvim',
  -- enabled = false,
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    'AndreM222/copilot-lualine',
    'letieu/harpoon-lualine',
  },
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
      return '  ' .. vim.fn.len(vim.fn.getbufinfo({ buflisted = 1 }))
    end

    local lint_progress = function()
      local linters = require('lint').get_running()
      if #linters == 0 then
        return '󰦕'
      end
      return '󱉶 ' .. table.concat(linters, ', ')
    end

    local colors = require('tokyonight.colors').setup()
    local noice = require('noice')

    -- custom filename component (color if not saved and mofified)
    local custom_fname = require('lualine.components.filename'):extend()
    local highlight = require('lualine.highlight')
    local default_status_colors = { saved = colors.fg_sidebar, modified = colors.magenta }

    function custom_fname:init(options)
      custom_fname.super.init(self, options)
      self.status_colors = {
        saved = highlight.create_component_highlight_group({ fg = default_status_colors.saved }, 'filename_status_saved', self.options),
        modified = highlight.create_component_highlight_group({ fg = default_status_colors.modified }, 'filename_status_modified', self.options),
      }
      if self.options.color == nil then
        self.options.color = ''
      end
    end

    function custom_fname:update_status()
      local data = custom_fname.super.update_status(self)
      data = highlight.component_format_highlight(vim.bo.modified and self.status_colors.modified or self.status_colors.saved) .. data
      return data
    end

    require('lualine').setup({
      options = {
        theme = 'tokyonight',
        icons_enabled = true,
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
            'harpoon2',
            color = { bg = colors.bg_highlight, fg = colors.fg_float, gui = 'none' },
            icon = '',
            padding = {
              right = 1,
              left = 0,
            },
          },
          {
            'filetype',
            icon_only = true,
            padding = {
              left = 1,
              right = 0,
            },
          },
          {
            custom_fname,
            file_status = true,
            path = 1,
            padding = {
              left = 0,
            },
          },
          -- {
          --   'filename',
          --   file_status = true,
          --   path = 1,
          -- },
          -- '%=', -- center the rest
          -- 'searchcount',
          -- { 'buffers', icons_enabled = false, use_mode_colors = true },
        },
        lualine_x = {
          -- show macro recording
          {
            noice.api.status.mode.get,
            cond = noice.api.status.mode.has,
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
          {
            'location',
            -- padding = {
            --   left = 1,
            --   right = 0,
            -- },
          },
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
    })
  end,
}
