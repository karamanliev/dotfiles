return {
  {
    'kdheepak/lazygit.nvim',
    enabled = false,
    cmd = {
      'LazyGit',
      'LazyGitConfig',
      'LazyGitCurrentFile',
      'LazyGitFilter',
      'LazyGitFilterCurrentFile',
    },
    keys = {
      { '<leader>gL', '<cmd>LazyGit<cr>', desc = 'LazyGit' },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
  },
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      numhl = true,
      signcolumn = true,
      preview_config = {
        border = 'rounded',
      },
      signs = {
        add = { text = '┃' },
        change = { text = '┃' },
        delete = { text = '┃' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
        untracked = { text = '┆' },
      },

      on_attach = function(bufnr)
        local gitsigns = require('gitsigns')

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']h', function()
          if vim.wo.diff then
            vim.cmd.normal({ ']h', bang = true })
          else
            gitsigns.nav_hunk('next')
          end
        end, { desc = 'Jump to next git hunk' })

        map('n', '[h', function()
          if vim.wo.diff then
            vim.cmd.normal({ '[h', bang = true })
          else
            gitsigns.nav_hunk('prev')
          end
        end, { desc = 'Jump to previous git hunk' })

        -- Actions
        -- visual mode
        map('v', '<leader>hs', function()
          gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, { desc = 'stage git hunk' })
        map('v', '<leader>hr', function()
          gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, { desc = 'reset git hunk' })
        -- normal mode
        map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git stage hunk' })
        map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git reset hunk' })
        map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git Stage buffer' })
        map('n', '<leader>hu', gitsigns.undo_stage_hunk, { desc = 'git undo stage hunk' })
        map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git Reset buffer' })
        map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'git preview hunk' })
        map('n', '<leader>hb', gitsigns.blame_line, { desc = 'git blame line' })
        map('n', '<leader>hq', gitsigns.setqflist, { desc = 'git qflist hunk' })
        map('n', '<leader>gt', gitsigns.diffthis, { desc = 'git diff against index' })
        map('n', '<leader>gT', function()
          gitsigns.diffthis('@')
        end, { desc = 'git diff against last commit' })
        -- Toggles
        map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = 'Toggle git show blame line' })
        map('n', '<leader>tB', gitsigns.blame, { desc = 'Toggle Blame panel' })
        map('n', '<leader>tD', gitsigns.toggle_deleted, { desc = 'Toggle git show Deleted' })
        map('n', '<leader>tl', gitsigns.toggle_linehl, { desc = 'Toggle git show Line highlights' })
      end,
    },
  },

  -- Diffview
  {
    'sindrets/diffview.nvim',
    cmd = {
      'DiffviewClose',
      'DiffviewFileHistory',
      'DiffviewFocusFiles',
      'DiffviewLog',
      'DiffviewOpen',
      'DiffviewRefresh',
      'DiffviewToggleFiles',
    },
    keys = {
      { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = 'Workspace Diff View' },
      { '<leader>gD', '<cmd>DiffviewFileHistory %<cr>', desc = 'File History Diff' },
    },
    config = function()
      local actions = require('diffview.actions')

      require('diffview').setup({
        enhanced_diff_hl = true,
        key_bindings = {
          view = {
            {
              'n',
              'q',
              actions.focus_files,
              { desc = 'Focus the files panel' },
            },
            {
              'n',
              '<Esc>',
              actions.focus_files,
              { desc = 'Focus the files panel' },
            },
            {
              'n',
              '[h',
              '<cmd>Gitsigns prev_hunk<cr>',
              { desc = 'Navigate to the previous hunk' },
            },
            {
              'n',
              ']h',
              '<cmd>Gitsigns next_hunk<cr>',
              { desc = 'Navigate to the next hunk' },
            },
          },
          file_panel = {
            {
              'n',
              '[h',
              actions.view_windo(function(layout_name, sym)
                if sym == 'b' then
                  vim.cmd(':Gitsigns prev_hunk')
                end
              end),
              { desc = 'Navigate to the previous hunk' },
            },
            {
              'n',
              ']h',
              actions.view_windo(function(layout_name, sym)
                if sym == 'b' then
                  vim.cmd(':Gitsigns next_hunk')
                end
              end),
              { desc = 'Navigate to the next hunk' },
            },
            {
              'n',
              's',
              actions.view_windo(function(layout_name, sym)
                if sym == 'b' then
                  vim.cmd(':Gitsigns stage_hunk')
                end
              end),
              { desc = 'Stage the selected hunk' },
            },
            {
              'n',
              'u',
              actions.view_windo(function(layout_name, sym)
                if sym == 'b' then
                  vim.cmd(':Gitsigns undo_stage_hunk')
                end
              end),
              { desc = 'Unstage the selected hunk' },
            },
            {
              'n',
              'x',
              actions.view_windo(function(layout_name, sym)
                if sym == 'b' then
                  vim.cmd(':Gitsigns reset_hunk')
                end
              end),
              { desc = 'Reset the selected hunk' },
            },
            {
              'n',
              'S',
              actions.toggle_stage_entry,
              { desc = 'Stage / Unstage the selected file' },
            },
            {
              'n',
              'q',
              '<cmd>set hidden<cr><cmd>DiffviewClose<cr><cmd>set nohidden<cr>',
              { desc = 'Close the diffview' },
            },
            {
              'n',
              '<Esc>',
              '<cmd>set hidden<cr><cmd>DiffviewClose<cr><cmd>set nohidden<cr>',
              { desc = 'Close the diffview' },
            },
          },
          file_history_panel = {
            {
              'n',
              'q',
              '<cmd>set hidden<cr><cmd>DiffviewClose<cr><cmd>set nohidden<cr>',
              { desc = 'Close the file history panel' },
            },
            {
              'n',
              '<Esc>',
              '<cmd>set hidden<cr><cmd>DiffviewClose<cr><cmd>set nohidden<cr>',
              { desc = 'Close the file history panel' },
            },
          },
        },
      })
    end,
  },
  {
    'NeogitOrg/neogit',
    cmd = 'Neogit',
    keys = {
      { '<leader>gg', '<cmd>Neogit<cr>', desc = 'NeoGit' },
      { '<leader>gv', '<cmd>Neogit kind=vsplit<cr>', desc = 'NeoGit vsplit' },
      { '<leader>gl', '<cmd>Neogit log<cr>', desc = 'Log' },
      { '<leader>gs', '<cmd>Neogit stash<cr>', desc = 'Stash' },
      { '<leader>gf', '<cmd>Neogit fetch<cr>', desc = 'Fetch' },
      { '<leader>gp', '<cmd>Neogit pull<cr>', desc = 'Pull' },
      { '<leader>gP', '<cmd>Neogit push<cr>', desc = 'Pull' },
      { '<leader>gc', '<cmd>Neogit commit<cr>', desc = 'Commit' },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'sindrets/diffview.nvim',
    },
    opts = {
      kind = 'replace',
      integrations = {
        diffview = true,
      },
      highlight = {
        italic = false,
      },
    },
  },
}
