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
        map('v', '<leader>gs', function()
          gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, { desc = 'stage git hunk' })
        map('v', '<leader>gr', function()
          gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, { desc = 'reset git hunk' })
        -- normal mode
        map('n', '<leader>gs', gitsigns.stage_hunk, { desc = 'git stage hunk' })
        map('n', '<leader>gr', gitsigns.reset_hunk, { desc = 'git reset hunk' })
        map('n', '<leader>gS', gitsigns.stage_buffer, { desc = 'git Stage buffer' })
        map('n', '<leader>gu', gitsigns.undo_stage_hunk, { desc = 'git undo stage hunk' })
        map('n', '<leader>gR', gitsigns.reset_buffer, { desc = 'git Reset buffer' })
        map('n', 'gs', gitsigns.preview_hunk_inline, { desc = 'git preview hunk' })
        map('n', '<leader>gp', function()
          gitsigns.toggle_linehl()
          gitsigns.toggle_deleted()
          gitsigns.toggle_word_diff()
        end, { desc = 'git toggle preview file hunk' })
        map('n', '<leader>gq', gitsigns.setqflist, { desc = 'git qflist hunk' })
        map('n', '<leader>dt', gitsigns.diffthis, { desc = 'diff against index' })
        map('n', '<leader>dT', function()
          gitsigns.diffthis('@')
        end, { desc = 'diff against last commit' })
        -- Toggles
        map('n', '<leader>gb', gitsigns.blame_line, { desc = 'Blame line' })
        map('n', '<leader>gB', gitsigns.blame, { desc = 'Blame panel' })
        map('n', '<leader>gd', gitsigns.toggle_deleted, { desc = 'Git show deleted' })
        map('n', '<leader>gl', gitsigns.toggle_linehl, { desc = 'Git show line highlights' })
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
      { '<leader>dd', '<cmd>DiffviewOpen<cr>', desc = 'Workspace Diff' },
      { '<leader>df', '<cmd>DiffviewFileHistory --follow %<cr>', desc = 'File Diff' },
      { '<leader>dF', '<cmd>DiffviewFileHistory .<cr>', desc = 'All Files/Commits Diff' },
      { '<leader>dv', "<Esc><Cmd>'<,'>DiffviewFileHistory --follow<CR>", desc = 'Visual Selection Diff', mode = { 'v' } },
      { '<leader>dl', '<Cmd>.DiffviewFileHistory --follow<CR>', desc = 'Line Diff' },
      {
        '<leader>db',
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
              '<C-d>',
              actions.scroll_view(0.25),
              { desc = 'Scroll preview down' },
            },
            {
              'n',
              '<C-u>',
              actions.scroll_view(-0.25),
              { desc = 'Scroll preview up' },
            },
            {
              'n',
              'j',
              actions.select_next_entry,
              { desc = 'Move cursor down' },
            },
            {
              'n',
              'k',
              actions.select_prev_entry,
              { desc = 'Move cursor up' },
            },
            {
              'n',
              '<cr>',
              actions.focus_entry,
              { desc = 'Focus the diff' },
            },
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
            -- {
            --   'n',
            --   '<Esc>',
            --   '<cmd>set hidden<cr><cmd>DiffviewClose<cr><cmd>set nohidden<cr>',
            --   { desc = 'Close the diffview' },
            -- },
            {
              'n',
              'o',
              function()
                actions.goto_file_edit()
                vim.cmd('tabclose #')
              end,
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
        },
        file_panel = {
          listing_style = 'list',
          win_config = {
            position = 'top',
            height = 15,
          },
        },
      })
    end,
  },
}
