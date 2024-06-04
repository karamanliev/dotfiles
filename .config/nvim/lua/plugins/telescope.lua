-- Fuzzy Finder (files, lsp, etc)
return {
  'nvim-telescope/telescope.nvim',
  cmd = { 'Telescope' },
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
    { 'nvim-telescope/telescope-live-grep-args.nvim' },
    {
      'AckslD/nvim-neoclip.lua',
      config = function()
        require('neoclip').setup({
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
      end,
    },
    { 'nvim-tree/nvim-web-devicons' },
  },
  config = function()
    local actions = require('telescope.actions')
    local telescopeConfig = require('telescope.config')

    -- Clone the default Telescope configuration
    local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

    -- I want to search in hidden/dot files.
    table.insert(vimgrep_arguments, '--hidden')

    -- Remove indentation from results
    table.insert(vimgrep_arguments, '--trim')
    -- I don't want to search in the `.git` directory.
    table.insert(vimgrep_arguments, '--glob')
    table.insert(vimgrep_arguments, '!**/.git/*')

    require('telescope').setup({
      defaults = {
        path_display = { 'smart' },
        -- `hidden = true` is not supported in text grep commands.
        dynamic_preview_title = true,
        vimgrep_arguments = vimgrep_arguments,
        mappings = {
          i = {
            ['<c-n>'] = 'move_selection_next',
            ['<c-p>'] = 'move_selection_previous',
            ['<M-n>'] = 'cycle_history_next',
            ['<M-p>'] = 'cycle_history_prev',
            -- ['<esc>'] = 'close',
          },
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
          mappings = {
            i = {
              ['<M-x>'] = actions.delete_buffer + actions.move_to_top,
            },
          },
        },
      },
      -- extensions = {},
    })

    -- Enable Telescope extensions if they are installed
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'live_grep_args')
    pcall(require('telescope').load_extension, 'neoclip')

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
    vim.keymap.set('n', '<leader>fc', '<cmd>Telescope neoclip theme=dropdown winblend=15<cr>', { desc = 'Find [c]lipboard contents' })
    vim.keymap.set('n', '<leader>gb', '<cmd>Telescope git_branches<cr>', { desc = 'Git [B]ranches' })

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
}
