return {
  {
    'stevearc/oil.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local oil = require('oil')

      local open_ssh = function(opts)
        local dir = oil.get_current_dir()
        local entry = oil.get_cursor_entry()

        if not entry then
          return
        end

        local path = opts.is_dir and dir or dir .. entry.parsed_name
        vim.cmd('OpenSshFile ' .. path)
      end

      oil.setup({
        default_file_explorer = true,
        skip_confirm_for_simple_edits = true,
        view_options = {
          show_hidden = true,
        },
        float = {
          padding = 2,
          max_width = 140,
          max_height = 35,
        },
        keymaps = {
          ['q'] = 'actions.close',
          ['-'] = 'actions.close',
          ['<bs>'] = 'actions.parent',
          ['<c-d>'] = 'actions.preview_scroll_down',
          ['<c-u>'] = 'actions.preview_scroll_up',
          ['gd'] = {
            desc = 'Toggle file detail view',
            callback = function()
              detail = not detail
              if detail then
                require('oil').set_columns({ 'icon', 'permissions', 'size', 'mtime' })
              else
                require('oil').set_columns({ 'icon' })
              end
            end,
          },
          ['<c-x>'] = {
            desc = 'Open SSH file locally',
            callback = function()
              open_ssh({ is_dir = false })
            end,
          },

          ['<c-s-x>'] = {
            desc = 'Open SSH dir locally',
            callback = function()
              open_ssh({ is_dir = true })
            end,
          },
        },
      })

      vim.keymap.set('n', '-', '<CMD>Oil --float<CR>', { desc = 'Open Oil' })
    end,
  },
}
