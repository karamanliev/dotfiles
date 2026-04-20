return {
  -- Neogit
  {
    'NeogitOrg/neogit',
    enabled = false,
    cmd = { 'Neogit' },
    keys = {
      { 'gh', '<cmd>DiffviewClose<cr><cmd>Neogit<cr>', desc = 'Neogit' },
      {
        'gL',
        '<cmd>Neogit log<cr>',
        desc = 'Neogit Log',
      },
      {
        '<leader>gc',
        '<cmd>lua require("neogit").action("commit", "commit", { "--verbose" })<cr>',
        desc = 'Neogit Commit',
      },
    },
    config = function()
      local neogit = require('neogit')

      neogit.setup({
        graph_style = 'kitty',
        process_spinner = true,
        remember_settings = true,
        use_per_project_settings = true,
        kind = 'tab',
        disable_line_numbers = false,
        disable_relative_line_numbers = false,
      })

      -- Focus Neogit on current buffer
      local function open_neogit_on_current_buffer()
        local function cursor_to_line(pattern)
          local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
          local esccaped_pattern = string.gsub(pattern, '[%p]', '%%%1')
          for i, line in ipairs(lines) do
            if line:match(esccaped_pattern) then
              vim.api.nvim_win_set_cursor(0, { i, 0 }) -- If pattern is found, move the cursor to the matching line
              return
            end
          end
        end

        local function open_callback(augroup_id, file_rel)
          vim.api.nvim_del_augroup_by_id(augroup_id)
          -- Send a tab to open the file
          -- local keys = vim.api.nvim_replace_termcodes('<tab>', true, false, true)
          -- vim.api.nvim_feedkeys(keys, 'i', false) -- Is insert mode!!
          cursor_to_line(file_rel)
        end

        local filename = vim.api.nvim_buf_get_name(0)
        if filename ~= '' then
          local file_rel = vim.fn.fnamemodify(vim.fn.expand('%'), ':.')
          -- local escaped_file = vim.fn.escape(file_rel, '\\/.*$^~[]')
          local MyNeogitGroup = vim.api.nvim_create_augroup('MyNeogitGroup', { clear = true })
          vim.api.nvim_create_autocmd('User', {
            desc = 'A temp autocmd to open neogit on current buffer',
            pattern = 'NeogitStatusRefreshed',
            group = MyNeogitGroup,
            callback = function()
              open_callback(MyNeogitGroup, file_rel)
            end,
          })
        end
        require('neogit').open()
      end

      vim.keymap.set('n', 'gh', function()
        vim.cmd('DiffviewClose')
        open_neogit_on_current_buffer()
      end, { noremap = true, desc = 'Neogit' })

      vim.keymap.set('n', '<leader>gc', neogit.action('commit', 'commit', { '--verbose' }), { desc = 'Neogit Commit' })
    end,
  },
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

        -- Navigation (unstaged)
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal({ ']c', bang = true })
          else
            gitsigns.nav_hunk('next', {
              navigation_message = true,
              foldopen = true,
              target = 'all',
            })
          end
        end, { desc = 'Jump to next git hunk (unstaged)' })

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal({ '[c', bang = true })
          else
            gitsigns.nav_hunk('prev', {
              navigation_message = true,
              foldopen = true,
              target = 'all',
            })
          end
        end, { desc = 'Jump to previous git hunk (unstaged)' })

        -- Navigation (all)
        map('n', ']C', function()
          gitsigns.nav_hunk('next', {
            navigation_message = true,
            foldopen = true,
            target = 'unstaged',
          })
        end, { desc = 'Jump to next git hunk (all)' })

        map('n', '[C', function()
          gitsigns.nav_hunk('prev', {
            navigation_message = true,
            foldopen = true,
            target = 'unstaged',
          })
        end, { desc = 'Jump to previous git hunk (all)' })

        -- Navigation (staged)
        map('n', ']s', function()
          gitsigns.nav_hunk('next', {
            navigation_message = true,
            foldopen = true,
            target = 'staged',
          })
        end, { desc = 'Jump to next git hunk (all)' })

        map('n', '[s', function()
          gitsigns.nav_hunk('prev', {
            navigation_message = true,
            foldopen = true,
            target = 'staged',
          })
        end, { desc = 'Jump to previous git hunk (all)' })

        -- Actions
        -- visual mode
        map('v', '<leader>gs', function()
          gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, { desc = 'stage git hunk' })
        map('v', '<leader>gr', function()
          gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, { desc = 'reset git hunk' })
        -- normal mode
        map('n', '<leader>gs', gitsigns.stage_hunk, { desc = 'git toggle stage hunk' })
        map('n', '<leader>gr', gitsigns.reset_hunk, { desc = 'git reset hunk' })
        map('n', '<leader>gS', gitsigns.stage_buffer, { desc = 'git Stage buffer' })
        map('n', '<leader>gU', gitsigns.reset_buffer_index, { desc = 'git undo stage buffer' })
        map('n', '<leader>gR', gitsigns.reset_buffer, { desc = 'git Reset buffer' })
        map('n', 'gs', gitsigns.preview_hunk_inline, { desc = 'git preview hunk (inline)' })
        map('n', 'gS', gitsigns.preview_hunk, { desc = 'git preview hunk (floating)' })
        map('n', '<leader>gp', function()
          gitsigns.toggle_linehl()
          gitsigns.toggle_deleted()
          gitsigns.toggle_word_diff()
        end, { desc = 'git toggle preview file hunk' })
        map('n', '<leader>qg', gitsigns.setqflist, { desc = 'Git hunks in qflist' })
        map('n', '<leader>dt', gitsigns.diffthis, { desc = 'diff against index' })
        map('n', '<leader>dT', function()
          gitsigns.diffthis('@')
        end, { desc = 'diff against last commit' })
        -- Toggles
        map('n', '<leader>gb', gitsigns.blame_line, { desc = 'Blame line' })
        map('n', '<leader>gB', gitsigns.blame, { desc = 'Blame panel' })
        map('n', '<leader>gd', gitsigns.toggle_deleted, { desc = 'Git show deleted' })
        map('n', '<leader>gl', gitsigns.toggle_linehl, { desc = 'Git show line highlights' })
        map({ 'o', 'x' }, 'ih', '<cmd>lua require("gitsigns").select_hunk()<cr>', { desc = 'Select hunk' })
      end,
    },
  },
  -- Diffview
  {
    'sindrets/diffview.nvim',
    enabled = false,
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

  {
    'esmuellert/codediff.nvim',
    cmd = 'CodeDiff',
    keys = {
      { '<leader>dd', '<cmd>CodeDiff<cr>', desc = 'Workspace Diff' },
      { '<leader>df', '<cmd>CodeDiff history %<cr>', desc = 'File Diff' },
      { '<leader>dF', '<cmd>CodeDiff history<cr>', desc = 'All Files/Commits Diff' },
      { '<leader>dv', "<Esc><Cmd>'<,'>CodeDiff history<CR>", desc = 'Visual Selection Diff', mode = { 'v' } },
      {
        '<leader>db',
        function()
          local user_input = vim.fn.input('Diff HEAD with Branch: ')
          vim.cmd('CodeDiff ' .. user_input .. ' HEAD')
        end,
        desc = 'Diff with Branch',
      },
    },
    opts = {
      -- Highlight configuration
      highlights = {
        -- Line-level: accepts highlight group names or hex colors (e.g., "#2ea043")
        line_insert = 'DiffAdd', -- Line-level insertions
        line_delete = 'DiffDelete', -- Line-level deletions

        -- Character-level: accepts highlight group names or hex colors
        -- If specified, these override char_brightness calculation
        char_insert = nil, -- Character-level insertions (nil = auto-derive)
        char_delete = nil, -- Character-level deletions (nil = auto-derive)

        -- Brightness multiplier (only used when char_insert/char_delete are nil)
        -- nil = auto-detect based on background (1.4 for dark, 0.92 for light)
        char_brightness = nil, -- Auto-adjust based on your colorscheme

        -- Conflict sign highlights (for merge conflict views)
        -- Accepts highlight group names or hex colors (e.g., "#f0883e")
        -- nil = use default fallback chain
        conflict_sign = nil, -- Unresolved: DiagnosticSignWarn -> #f0883e
        conflict_sign_resolved = nil, -- Resolved: Comment -> #6e7681
        conflict_sign_accepted = nil, -- Accepted: GitSignsAdd -> DiagnosticSignOk -> #3fb950
        conflict_sign_rejected = nil, -- Rejected: GitSignsDelete -> DiagnosticSignError -> #f85149
      },

      -- Diff view behavior
      diff = {
        layout = 'side-by-side', -- Diff layout: "side-by-side" (two panes) or "inline" (single pane with virtual lines)
        disable_inlay_hints = true, -- Disable inlay hints in diff windows for cleaner view
        max_computation_time_ms = 5000, -- Maximum time for diff computation (VSCode default)
        ignore_trim_whitespace = false, -- Ignore leading/trailing whitespace changes (like diffopt+=iwhite)
        hide_merge_artifacts = false, -- Hide merge tool temp files (*.orig, *.BACKUP.*, *.BASE.*, *.LOCAL.*, *.REMOTE.*)
        original_position = 'left', -- Position of original (old) content: "left" or "right"
        conflict_ours_position = 'right', -- Position of ours (:2) in conflict view: "left" or "right"
        conflict_result_position = 'bottom', -- "bottom" (default): result below diff panes or "center": result between diff panes (three columns)
        conflict_result_height = 30, -- Height of result pane in bottom layout (% of total height)
        conflict_result_width_ratio = { 1, 1, 1 }, -- Width ratio for center layout panes {left, center, right} (e.g., {1, 2, 1} for wider result)
        cycle_next_hunk = true, -- Wrap around when navigating hunks (]c/[c): false to stop at first/last
        cycle_next_file = true, -- Wrap around when navigating files (]f/[f): false to stop at first/last
        jump_to_first_change = true, -- Auto-scroll to first change when opening a diff: false to stay at same line
        highlight_priority = 100, -- Priority for line-level diff highlights (increase to override LSP highlights)
        compute_moves = false, -- Detect moved code blocks (opt-in, matches VSCode experimental.showMoves)
      },

      -- Explorer panel configuration
      explorer = {
        position = 'left', -- "left" or "bottom"
        width = 40, -- Width when position is "left" (columns)
        height = 15, -- Height when position is "bottom" (lines)
        indent_markers = true, -- Show indent markers in tree view (│, ├, └)
        initial_focus = 'explorer', -- Initial focus: "explorer", "original", or "modified"
        icons = {
          folder_closed = '', -- Nerd Font folder icon (customize as needed)
          folder_open = '', -- Nerd Font folder-open icon
        },
        view_mode = 'list', -- "list" or "tree"
        flatten_dirs = true, -- Flatten single-child directory chains in tree view
        file_filter = {
          ignore = { '.git/**', '.jj/**' }, -- Glob patterns to hide (e.g., {"*.lock", "dist/*"})
        },
        focus_on_select = false, -- Jump to modified pane after selecting a file (default: stay in explorer)
        visible_groups = { -- Which groups to show (can be toggled at runtime)
          staged = true,
          unstaged = true,
          conflicts = true,
        },
      },

      -- History panel configuration (for :CodeDiff history)
      history = {
        position = 'bottom', -- "left" or "bottom" (default: bottom)
        width = 40, -- Width when position is "left" (columns)
        height = 15, -- Height when position is "bottom" (lines)
        initial_focus = 'history', -- Initial focus: "history", "original", or "modified"
        view_mode = 'list', -- "list" or "tree" for files under commits
      },

      -- Keymaps in diff view
      keymaps = {
        view = {
          quit = 'q', -- Close diff tab
          toggle_explorer = '<leader>b', -- Toggle explorer visibility (explorer mode only)
          focus_explorer = '<leader>e', -- Focus explorer panel (explorer mode only)
          next_hunk = ']c', -- Jump to next change
          prev_hunk = '[c', -- Jump to previous change
          next_file = ']f', -- Next file in explorer/history mode
          prev_file = '[f', -- Previous file in explorer/history mode
          diff_get = 'do', -- Get change from other buffer (like vimdiff)
          diff_put = 'dp', -- Put change to other buffer (like vimdiff)
          open_in_prev_tab = 'gf', -- Open current buffer in previous tab (or create one before)
          close_on_open_in_prev_tab = false, -- Close codediff tab after gf opens file in previous tab
          toggle_stage = '-', -- Stage/unstage current file (works in explorer and diff buffers)
          stage_hunk = '<leader>hs', -- Stage hunk under cursor to git index
          unstage_hunk = '<leader>hu', -- Unstage hunk under cursor from git index
          discard_hunk = '<leader>hr', -- Discard hunk under cursor (working tree only)
          hunk_textobject = 'ih', -- Textobject for hunk (vih to select, yih to yank, etc.)
          show_help = 'g?', -- Show floating window with available keymaps
          align_move = 'gm', -- Temporarily align moved code blocks across panes
          toggle_layout = 't', -- Toggle between side-by-side and inline layout
        },
        explorer = {
          select = '<CR>', -- Open diff for selected file
          hover = 'K', -- Show file diff preview
          refresh = 'R', -- Refresh git status
          toggle_view_mode = 'i', -- Toggle between 'list' and 'tree' views
          stage_all = 'S', -- Stage all files
          unstage_all = 'U', -- Unstage all files
          restore = 'X', -- Discard changes (restore file)
          toggle_changes = 'gu', -- Toggle Changes (unstaged) group visibility
          toggle_staged = 'gs', -- Toggle Staged Changes group visibility
          -- Fold keymaps (Vim-style)
          fold_open = 'zo', -- Open fold (expand current node)
          fold_open_recursive = 'zO', -- Open fold recursively (expand all descendants)
          fold_close = 'zc', -- Close fold (collapse current node)
          fold_close_recursive = 'zC', -- Close fold recursively (collapse all descendants)
          fold_toggle = 'za', -- Toggle fold (expand/collapse current node)
          fold_toggle_recursive = 'zA', -- Toggle fold recursively
          fold_open_all = 'zR', -- Open all folds in tree
          fold_close_all = 'zM', -- Close all folds in tree
        },
        history = {
          select = '<CR>', -- Select commit/file or toggle expand
          toggle_view_mode = 'i', -- Toggle between 'list' and 'tree' views
          refresh = 'R', -- Refresh history (re-fetch commits)
          -- Fold keymaps (Vim-style, apply to directory nodes only)
          fold_open = 'zo', -- Open fold (expand current node)
          fold_open_recursive = 'zO', -- Open fold recursively (expand all descendants)
          fold_close = 'zc', -- Close fold (collapse current node)
          fold_close_recursive = 'zC', -- Close fold recursively (collapse all descendants)
          fold_toggle = 'za', -- Toggle fold (expand/collapse current node)
          fold_toggle_recursive = 'zA', -- Toggle fold recursively
          fold_open_all = 'zR', -- Open all folds in tree
          fold_close_all = 'zM', -- Close all folds in tree
        },
        conflict = {
          accept_incoming = '<leader>ct', -- Accept incoming (theirs/left) change
          accept_current = '<leader>co', -- Accept current (ours/right) change
          accept_both = '<leader>cb', -- Accept both changes (incoming first)
          discard = '<leader>cx', -- Discard both, keep base
          -- Accept all (whole file) - uppercase versions
          accept_all_incoming = '<leader>cT', -- Accept ALL incoming changes
          accept_all_current = '<leader>cO', -- Accept ALL current changes
          accept_all_both = '<leader>cB', -- Accept ALL both changes
          discard_all = '<leader>cX', -- Discard ALL, reset to base
          next_conflict = ']x', -- Jump to next conflict
          prev_conflict = '[x', -- Jump to previous conflict
          diffget_incoming = '2do', -- Get hunk from incoming (left/theirs) buffer
          diffget_current = '3do', -- Get hunk from current (right/ours) buffer
        },
      },
    },
  },
}
