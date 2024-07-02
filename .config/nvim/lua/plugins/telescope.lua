-- Fuzzy Finder (files, lsp, etc)
return {
  {
    'nvim-telescope/telescope.nvim',
    event = { 'VeryLazy' },
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        build = 'make',
        cond = function()
          return vim.fn.executable('make') == 1
        end,
      },
      { 'nvim-tree/nvim-web-devicons' },
    },
    config = function()
      local telescopeConfig = require('telescope.config')
      local actions = require('telescope.actions')
      local actions_state = require('telescope.actions.state')
      local from_entry = require('telescope.from_entry')
      local harpoon = require('utils.telescope.harpoon')
      local image = require('utils.telescope.image')

      -- Clone the default Telescope configuration
      local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

      -- I want to search in hidden/dot files.
      table.insert(vimgrep_arguments, '--hidden')

      -- Remove indentation from results
      table.insert(vimgrep_arguments, '--trim')
      -- I don't want to search in the `.git` directory.
      table.insert(vimgrep_arguments, '--glob')
      table.insert(vimgrep_arguments, '!**/.git/*')

      -- Open the selected file/dir with OpenSshFile command
      local open_ssh_file = function(opts)
        local entry = actions_state.get_selected_entry()
        if entry then
          local file_path = from_entry.path(entry, true)
          local dir = file_path and file_path:match('(.*/)')
          local path = opts.is_folder and dir or file_path

          vim.cmd('OpenSshFile ' .. path)
        end
      end

      require('telescope').setup({
        defaults = {
          path_display = { 'smart' },
          sorting_strategy = 'ascending',
          layout_config = {
            prompt_position = 'top',
          },
          -- `hidden = true` is not supported in text grep commands.
          dynamic_preview_title = true,
          vimgrep_arguments = vimgrep_arguments,
          mappings = {
            i = {
              ['<c-n>'] = 'move_selection_next',
              ['<c-p>'] = 'move_selection_previous',
              ['<M-n>'] = 'cycle_history_next',
              ['<M-p>'] = 'cycle_history_prev',
              ['<C-s>'] = harpoon.mark,
              ['<C-x>'] = function()
                open_ssh_file({ is_folder = false })
              end,
              ['<C-S-x>'] = function()
                open_ssh_file({ is_folder = true })
              end,
              -- ['<esc>'] = 'close',
            },
            n = {
              ['<C-s>'] = harpoon.mark,
              ['<C-x>'] = function()
                open_ssh_file({ is_folder = false })
              end,
              ['<C-S-x>'] = function()
                open_ssh_file({ is_folder = true })
              end,
            },
          },
          preview = {
            -- mime_hook = function(filepath, bufnr, opts)
            --   local is_image = function(filepath)
            --     local image_extensions = { 'png', 'jpg' } -- Supported image formats
            --     local split_path = vim.split(filepath:lower(), '.', { plain = true })
            --     local extension = split_path[#split_path]
            --     return vim.tbl_contains(image_extensions, extension)
            --   end
            --   if is_image(filepath) then
            --     local term = vim.api.nvim_open_term(bufnr, {})
            --     local function send_output(_, data, _)
            --       for _, d in ipairs(data) do
            --         vim.api.nvim_chan_send(term, d .. '\r\n')
            --       end
            --     end
            --     vim.fn.jobstart({
            --       'catimg', -- Terminal image viewer command
            --       filepath,
            --     }, { on_stdout = send_output, stdout_buffered = true, pty = true })
            --   else
            --     require('telescope.previewers.utils').set_preview_message(bufnr, opts.winid, 'Binary cannot be previewed')
            --   end
            -- end,
            filesize_limit = 5,
          },
          buffer_previewer_maker = image.buffer_previewer_maker,
        },
        pickers = {
          lsp_references = {
            show_line = false,
          },
          find_files = {
            -- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
            find_command = { 'rg', '--files', '--hidden', '--glob', '!**/.git/*' },
          },
          help_tags = {
            mappings = {
              i = {
                ['<CR>'] = actions.file_vsplit,
              },
            },
          },
          buffers = {
            ignore_current_buffer = true,
            sort_mru = true,
            mappings = {
              i = {
                ['<M-d>'] = actions.delete_buffer + actions.move_to_top,
              },
            },
          },
        },
        extensions = {},
      })

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')

      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = '[F]ind [H]elp' })
      vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = '[F]ind [K]eymaps' })
      vim.keymap.set('n', '<leader>.', builtin.find_files, { desc = '[F]ind [F]iles' })
      vim.keymap.set('n', '<leader>fs', builtin.builtin, { desc = '[F]ind [S]elect Telescope' })
      vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = '[F]ind current [W]ord' })
      vim.keymap.set('n', '<leader>,', '<cmd>Telescope live_grep_args<cr>', { desc = '[F]ind by [G]rep' })
      vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = '[F]ind [D]iagnostics' })
      vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = '[F]ind [R]esume' })
      vim.keymap.set('n', '<leader>f.', builtin.oldfiles, { desc = '[F]ind Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader>ft', '<cmd>TodoTelescope<cr>', { desc = '[F]ind [T]odo Comments' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
      vim.keymap.set('n', '<leader>fc', '<cmd>Telescope neoclip theme=dropdown<cr>', { desc = 'Find [c]lipboard contents' })
      vim.keymap.set('n', '<leader>gb', '<cmd>Telescope git_branches<cr>', { desc = 'Git [B]ranches' })
      vim.keymap.set('n', '<leader>fg', '<cmd>AdvancedGitSearch<cr>', { desc = 'AdvancedGit[S]earch' })

      vim.keymap.set('n', '<leader>f/', function()
        builtin.live_grep({
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        })
      end, { desc = '[F]ind [/] in Open Files' })

      vim.keymap.set('n', '<leader>fn', function()
        builtin.find_files({ cwd = vim.fn.stdpath('config') })
      end, { desc = '[F]ind [N]eovim files' })

      -- line wrap in telescope previewer
      vim.api.nvim_create_autocmd('User', {
        pattern = 'TelescopePreviewerLoaded',
        callback = function(args)
          vim.wo.wrap = true
        end,
      })
    end,
  },

  {
    'nvim-telescope/telescope-live-grep-args.nvim',
    keys = {
      { 'n', '<leader>,' },
    },
    config = function()
      require('telescope').setup({
        extensions = {
          live_grep_args = {
            auto_quoting = true,
          },
        },
      })
      require('telescope').load_extension('live_grep_args')
    end,
  },

  {
    'AckslD/nvim-neoclip.lua',
    keys = {
      { 'n', '<leader>fc' },
    },
    config = function()
      require('neoclip').setup({
        layout_strategy = 'vertical',
        history = 1000,
        filter = nil,
        preview = true,
        keys = {
          telescope = {
            i = {
              paste_behind = '<c-o>',
            },
          },
        },
      })

      require('telescope').load_extension('neoclip')
    end,
  },

  {
    'aaronhallaert/advanced-git-search.nvim',
    cmd = { 'AdvancedGitSearch' },
    dependencies = {
      'sindrets/diffview.nvim',
    },
    config = function()
      local theme = {
        layout_strategy = 'vertical',
        layout_config = {
          width = 0.9,
          height = 0.9,
          prompt_position = 'top',
          mirror = true,
          preview_height = 0.65,
        },
      }

      require('telescope').setup({
        extensions = {
          advanced_git_search = {
            diff_plugin = 'diffview',
            show_builtin_git_pickers = true,
            telescope_theme = {
              search_log_content = theme,
              checkout_reflog = theme,
              diff_commit_file = theme,
              diff_branch_file = theme,
              diff_commit_line = theme,
              changed_on_branch = theme,
              search_log_content_file = theme,

              show_custom_functions = {
                layout_config = { width = 0.4, height = 0.4 },
              },
            },
          },
        },
      })

      require('telescope').load_extension('advanced_git_search')
    end,
  },
}
