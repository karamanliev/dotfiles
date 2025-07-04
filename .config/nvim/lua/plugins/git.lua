return {
  -- Gitsigns
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      numhl = false,
      signcolumn = true,
      preview_config = {
        border = 'single',
        style = 'minimal',
        row = 1,
        col = 1,
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
        map('n', 'gs', gitsigns.preview_hunk_inline, { desc = 'git preview hunk' })
        map('n', '<leader>hp', function()
          gitsigns.toggle_linehl()
          gitsigns.toggle_deleted()
          gitsigns.toggle_word_diff()
        end, { desc = 'git toggle preview file hunk' })
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
      { '<leader>gdd', '<cmd>DiffviewOpen<cr>', desc = 'Workspace Diff' },
      { '<leader>gdf', '<cmd>DiffviewFileHistory --follow %<cr>', desc = 'File Diff' },
      { '<leader>gdF', '<cmd>DiffviewFileHistory .<cr>', desc = 'All Files/Commits Diff' },
      { '<leader>gdv', "<Esc><Cmd>'<,'>DiffviewFileHistory --follow<CR>", desc = 'Visual Selection Diff', mode = { 'v' } },
      { '<leader>gdl', '<Cmd>.DiffviewFileHistory --follow<CR>', desc = 'Line Diff' },
      {
        '<leader>gdb',
        function()
          local user_input = vim.fn.input('Diff HEAD with Branch: ')
          vim.cmd('DiffviewOpen origin/' .. user_input .. '..HEAD')
        end,
        desc = 'Diff with Branch',
      },
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
            {
              'n',
              'o',
              actions.goto_file_edit,
              desc = 'Open the file in a new tab',
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
        view = {
          default = {
            layout = 'diff2_horizontal',
            winbar_info = true,
            disable_diagnostics = false,
          },
          merge_tool = {
            layout = 'diff3_mixed',
            disable_diagnostics = false,
            winbar_info = true,
          },
          file_history = {
            layout = 'diff2_horizontal',
            winbar_info = true,
            disable_diagnostics = false,
          },

          file_panel = {
            win_config = 'right',
            width = 35,
          },
        },
      })
    end,
  },
}
