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
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    enabled = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
      'MunifTanjim/nui.nvim',
    },
    cmd = 'Neotree',
    keys = {
      { '_', '<cmd>Neotree reveal<cr>', desc = 'NeoTree reveal' },
    },
    opts = {},
    config = function()
      -- Open telescope grep/find in the selected node
      -- local function getTelescopeOpts(state, path)
      --   return {
      --     cwd = path,
      --     search_dirs = { path },
      --     attach_mappings = function(prompt_bufnr, map)
      --       local actions = require('telescope.actions')
      --       actions.select_default:replace(function()
      --         actions.close(prompt_bufnr)
      --         local action_state = require('telescope.actions.state')
      --         local selection = action_state.get_selected_entry()
      --         local filename = selection.filename
      --         if filename == nil then
      --           filename = selection[1]
      --         end
      --         -- any way to open the file without triggering auto-close event of neo-tree?
      --         require('neo-tree.sources.filesystem').navigate(state, state.path, filename)
      --       end)
      --       return true
      --     end,
      --   }
      -- end

      require('neo-tree').setup({
        close_if_last_window = false,
        auto_clean_after_session_restore = true,
        source_selector = {
          winbar = false,
          statusline = false,
        },
        filesystem = {
          filtered_items = {
            visible = false, -- when true, they will just be displayed differently than normal items
            hide_dotfiles = false,
            hide_gitignored = false,
            hide_hidden = false, -- only works on Windows for hidden files/directories
            hide_by_name = {
              '.git',
              'node_modules',
            },
          },
          window = {
            position = 'right',
            width = 40,
            mappings = {
              ['_'] = 'close_window',
              ['P'] = { 'toggle_preview', config = { use_float = false, use_image_nvim = true } },
              ['<C-u>'] = { 'scroll_preview', config = { direction = 10 } },
              ['<C-d>'] = { 'scroll_preview', config = { direction = -10 } },
              -- ['f'] = 'telescope_find',
              -- ['g'] = 'telescope_grep',
            },
          },
        },
        event_handlers = {
          -- Close NeoTree on file open
          {
            event = 'file_opened',
            handler = function()
              require('neo-tree.command').execute({ action = 'close' })
            end,
          },
          -- Show preview automatically after rendering
          -- {
          --   event = 'after_render',
          --   handler = function()
          --     local state = require('neo-tree.sources.manager').get_state('filesystem')
          --     if not require('neo-tree.sources.common.preview').is_active() then
          --       state.config = { use_float = false }
          --       state.commands.toggle_preview(state)
          --     end
          --   end,
          -- },
        },
        -- commands = {
        --   telescope_find = function(state)
        --     local node = state.tree:get_node()
        --     local path = node:get_id()
        --     require('telescope.builtin').find_files(getTelescopeOpts(state, path))
        --   end,
        --   telescope_grep = function(state)
        --     local node = state.tree:get_node()
        --     local path = node:get_id()
        --     require('telescope.builtin').live_grep(getTelescopeOpts(state, path))
        --   end,
        -- },
      })
    end,
  },
}
