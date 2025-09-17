-- Fuzzy Finder (files, lsp, etc)
return {
  {
    'nvim-telescope/telescope.nvim',
    enabled = false,
    cmd = 'Telescope',
    keys = {
      {
        '<leader>fh',
        function()
          require('telescope.builtin').help_tags()
        end,
        desc = 'Find Help',
      },
      {
        '<leader>fk',
        function()
          require('telescope.builtin').keymaps()
        end,
        desc = 'Find Keymaps',
      },
      { '<leader>.', "zy<cmd>exec 'Telescope find_files default_text=' . escape(@z, ' ')<cr>", mode = 'v', desc = 'Find Files (Visual)' },
      { '<leader>,', '<cmd>Telescope live_grep_args<cr>', desc = 'Find by Grep' },
      {
        '<leader>fd',
        function()
          require('telescope.builtin').diagnostics()
        end,
        desc = 'Find Diagnostics',
      },
      {
        '<leader>;',
        function()
          require('telescope.builtin').resume()
        end,
        desc = 'Find Resume',
      },
      {
        '<leader>>',
        function()
          require('telescope.builtin').oldfiles()
        end,
        desc = 'Find Recent Files ("." for repeat)',
      },
      { '<leader>ft', '<cmd>TodoTelescope<cr>', desc = 'Find Todo Comments' },
      {
        '<C-Space>',
        function()
          require('telescope.builtin').buffers()
        end,
        mode = { 'n', 'v' },
        desc = 'Opened buffers',
      },
      {
        '<leader><leader>',
        function()
          require('telescope.builtin').buffers()
        end,
        mode = { 'n', 'v' },
        desc = 'Opened buffers',
      },
      { '<leader>/', '<cmd>Telescope current_buffer_fuzzy_find theme=ivy<cr>', mode = { 'n', 'v' }, desc = 'Fuzzy find current buffer' },
      {
        '<leader><',
        function()
          require('telescope.builtin').live_grep({
            grep_open_files = true,
            prompt_title = 'Live Grep in Open Files',
          })
        end,
        desc = 'Grep in active buffers',
      },
      {
        '<leader>fm',
        function()
          require('telescope.builtin').marks()
        end,
        desc = 'Find Marks',
      },
      {
        '<leader>fg',
        function()
          require('telescope.builtin').git_status({
            use_file_path = true,
          })
        end,
        desc = 'Show Git Status',
      },
      {
        '<leader>fn',
        function()
          require('telescope.builtin').find_files({ cwd = vim.fn.stdpath('config') })
        end,
        desc = 'Find Neovim files',
      },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
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
      local image_utils = require('utils.telescope.image')

      require('telescope').setup({
        defaults = {
          path_display = { 'filename_first' },
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
              -- ['<C-q>'] = require('trouble.sources.telescope').open,
            },
            n = {
              ['<C-x>'] = function()
                misc.open_ssh_file({ is_folder = false })
              end,
              ['<C-S-x>'] = function()
                misc.open_ssh_file({ is_folder = true })
              end,
              -- ['<C-q>'] = require('trouble.sources.telescope').open,
            },
          },
          preview = {
            filesize_limit = 5,
          },
          buffer_previewer_maker = image_utils.buffer_previewer_maker,
        },
        pickers = {
          lsp_references = {
            initial_mode = 'normal',
            show_line = false,
          },
          lsp_definitions = {
            initial_mode = 'normal',
          },
          find_files = {
            -- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
            find_command = { 'rg', '--files', '--hidden', '--glob', '!**/.git/*' },
          },
          git_status = {
            initial_mode = 'normal',
            mappings = {
              n = {
                ['<Tab>'] = actions.toggle_selection,
              },
              i = {
                ['<Tab>'] = actions.toggle_selection,
              },
            },
          },
          help_tags = {
            mappings = {
              i = {
                ['<CR>'] = actions.file_vsplit,
              },
            },
          },
          buffers = {
            ignore_current_buffer = false,
            initial_mode = 'normal',
            sort_mru = true,
            previewer = false,
            sort_lastused = true,
            select_current = false,
            theme = 'dropdown',
            mappings = {
              i = {
                ['<C-d>'] = actions.delete_buffer,
              },
              n = {
                ['<C-d>'] = actions.delete_buffer,
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
    enabled = false,
    keys = {
      { '<leader>,', '<cmd>Telescope live_grep_args<cr>' },
      {
        '<leader>fw',
        function()
          require('telescope-live-grep-args.shortcuts').grep_word_under_cursor()
        end,
        desc = 'Find current Word',
      },
      {
        '<leader>,',
        function()
          require('telescope-live-grep-args.shortcuts').grep_visual_selection()
        end,
        desc = 'Find by Grep (Visual)',
        mode = 'v',
      },
    },
    config = function()
      local lga_actions = require('telescope-live-grep-args.actions')
      local actions = require('telescope.actions')

      require('telescope').setup({
        extensions = {
          live_grep_args = {
            auto_quoting = true,
            mappings = {
              i = {
                ['<C-k>'] = lga_actions.quote_prompt(),
                ['<C-o>'] = lga_actions.quote_prompt({ postfix = ' -F ' }),
                ['<C-i>'] = lga_actions.quote_prompt({ postfix = ' --iglob ' }),
                -- freeze the current list and start a fuzzy search in the frozen list
                ['<C-space>'] = actions.to_fuzzy_refine,
              },
            },
          },
        },
      })
      require('telescope').load_extension('live_grep_args')
    end,
  },

  {
    'nvim-telescope/telescope-frecency.nvim',
    enabled = false,
    keys = {
      { '<leader>.', '<cmd>Telescope frecency workspace=CWD<cr>', desc = 'Find files' },
    },
    config = function()
      require('telescope').load_extension('frecency')
      require('frecency.config').setup({
        default_workspace = 'CWD',
        disable_devicons = false,
        enable_prompt_mappings = true,
        hide_current_buffer = false,
        show_filter_column = false,
        show_scores = false,
        -- workspaces = {
        --   ['conf'] = '~/.config',
        --   ['dots'] = '~/dotfiles',
        --   ['projects'] = '~/Projects',
        -- },
      })
    end,
  },
}
