-- Fuzzy Finder (files, lsp, etc)
return {
  {
    'nvim-telescope/telescope.nvim',
    event = { 'VeryLazy' },
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
      local actions = require('telescope.actions')
      local misc = require('utils.telescope.misc')

      require('telescope').setup({
        defaults = {
          path_display = { 'smart' },
          sorting_strategy = 'ascending',
          layout_strategy = 'vertical',
          layout_config = {
            prompt_position = 'top',
            horizontal = {
              anchor = 'CENTER',
              mirror = false,
            },
            vertical = {
              anchor = 'CENTER',
              mirror = true,
              preview_height = 0.65,
            },
          },
          -- `hidden = true` is not supported in text grep commands.
          dynamic_preview_title = true,
          vimgrep_arguments = misc.vimgrep_arguments,
          mappings = {
            i = {
              ['<c-n>'] = 'move_selection_next',
              ['<c-p>'] = 'move_selection_previous',
              ['<M-n>'] = 'cycle_history_next',
              ['<M-p>'] = 'cycle_history_prev',
              ['<C-x>'] = function()
                misc.open_ssh_file({ is_folder = false })
              end,
              ['<C-S-x>'] = function()
                misc.open_ssh_file({ is_folder = true })
              end,
              ['<C-f>'] = misc.focus_preview,
            },
            n = {
              ['<C-x>'] = function()
                misc.open_ssh_file({ is_folder = false })
              end,
              ['<C-S-x>'] = function()
                misc.open_ssh_file({ is_folder = true })
              end,
            },
          },
          preview = {
            filesize_limit = 5,
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
          },
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
            initial_mode = 'normal',
            sort_mru = true,
            mappings = {
              i = {
                ['<M-d>'] = actions.delete_buffer + actions.move_to_top,
              },
            },
          },
          marks = {
            initial_mode = 'normal',
            layout_strategy = 'vertical',
            mark_type = 'all',
          },
          colorscheme = {
            enable_preview = true,
            ignore_builtins = true,
            initial_mode = 'normal',
            mappings = {
              i = {
                ['<CR>'] = misc.set_colorscheme,
              },
              n = {
                ['<CR>'] = misc.set_colorscheme,
              },
            },
          },
        },
        extensions = {},
      })

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')

      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Find Help' })
      vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = 'Find Keymaps' })
      vim.keymap.set('n', '<leader>.', builtin.find_files, { desc = 'Find Files' })
      vim.keymap.set('v', '<leader>.', "\"zy<cmd>exec 'Telescope find_files default_text=' . escape(@z, ' ')<cr>", { desc = 'Find Files (Visual)' })
      vim.keymap.set('n', '<leader>fs', builtin.builtin, { desc = 'Find Select Telescope' })
      vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = 'Find current Word' })
      vim.keymap.set('n', '<leader>,', '<cmd>Telescope live_grep_args<cr>', { desc = 'Find by Grep' })
      vim.keymap.set('v', '<leader>,', "\"zy<cmd>exec 'Telescope grep_string default_text=' . escape(@z, ' ')<cr>", { desc = 'Find by Grep (Visual)' })
      vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = 'Find Diagnostics' })
      vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = 'Find Resume' })
      vim.keymap.set('n', '<leader>f.', builtin.oldfiles, { desc = 'Find Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader>ft', '<cmd>TodoTelescope<cr>', { desc = 'Find Todo Comments' })
      vim.keymap.set({ 'n', 'v' }, '<leader><leader>', builtin.buffers, { desc = 'Opened buffers' })
      vim.keymap.set('n', '<leader>yy', '<cmd>Telescope neoclip layout_strategy=vertical initial_mode=normal<cr>', { desc = 'Neoclip' })
      vim.keymap.set('n', '<leader>gb', '<cmd>Telescope git_branches<cr>', { desc = 'Git Branches' })
      vim.keymap.set('n', '<leader>fg', '<cmd>AdvancedGitSearch<cr>', { desc = 'AdvancedGitSearch' })
      vim.keymap.set('n', '<leader>f/', function()
        builtin.live_grep({
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        })
      end, { desc = 'Grep in active buffers' })
      vim.keymap.set('n', '<leader>fm', builtin.marks, { desc = 'Find Marks' })

      vim.keymap.set('n', '<leader>fn', function()
        builtin.find_files({ cwd = vim.fn.stdpath('config') })
      end, { desc = 'Find Neovim files' })

      -- line wrap in telescope previewer
      vim.api.nvim_create_autocmd('User', {
        pattern = 'TelescopePreviewerLoaded',
        callback = function()
          vim.wo.wrap = true
        end,
      })
    end,
  },

  {
    'nvim-telescope/telescope-live-grep-args.nvim',
    keys = {
      { '<leader>,', '<cmd>Telescope live_grep_args<cr>' },
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
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('neoclip').setup({
        default_register_macros = 'Q',
        history = 1000,
        filter = nil,
        preview = true,
        keys = {
          telescope = {
            i = {
              paste = '<m-p>',
              delete = '<m-d>',
              paste_behind = '<c-o>',
            },
          },
        },
      })

      require('telescope').load_extension('neoclip')
    end,
  },

  {
    'debugloop/telescope-undo.nvim',
    keys = {
      {
        '<leader>u',
        '<cmd>Telescope undo<cr>',
        desc = 'Undo',
      },
    },
    opts = {
      extensions = {
        undo = {
          use_delta = true,
          use_custom_command = nil, -- setting this implies `use_delta = false`. Accepted format is: { "bash", "-c", "echo '$DIFF' | delta" }
          side_by_side = true,
          vim_diff_opts = {
            ctxlen = vim.o.scrolloff,
          },
          entry_format = 'state #$ID, $STAT, $TIME',
          time_format = '',
          saved_only = false,
          initial_mode = 'normal',
          layout_strategy = 'vertical',
          layout_config = {
            width = 0.9,
            height = 0.9,
            prompt_position = 'top',
          },
        },
      },
    },
    config = function(_, opts)
      require('telescope').setup(opts)
      require('telescope').load_extension('undo')
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
