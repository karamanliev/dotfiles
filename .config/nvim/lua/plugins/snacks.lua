return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      bigfile = {
        enabled = true,
        size = 0.8 * 1024 * 1024, -- 800 KB
        setup = function(ctx)
          if vim.fn.exists(':NoMatchParen') ~= 0 then
            vim.cmd([[NoMatchParen]])
          end
          if vim.fn.exists(':Gitsigns') ~= 0 then
            vim.cmd([[Gitsigns detach]])
          end
          Snacks.util.wo(0, { foldmethod = 'manual', statuscolumn = '', conceallevel = 0 })
          vim.b.minianimate_disable = true
          vim.schedule(function()
            if vim.api.nvim_buf_is_valid(ctx.buf) then
              vim.bo[ctx.buf].syntax = ctx.ft
            end
          end)
        end,
      },
      dashboard = { enabled = false },
      explorer = { enabled = false, replace_netrw = false },
      indent = {
        enabled = true,
        animate = {
          enabled = false,
        },
        chunk = {
          enabled = true,
        },
        indent = {
          enabled = true,
          width = 2,
          char = '┊',
          hl = 'Whitespace',
        },
        scope = {
          enabled = false,
        },
      },
      input = {
        enabled = true,
        prompt_pos = false,
        icon_pos = false,
      },
      image = {
        enabled = true,
      },
      notifier = {
        enabled = false,
        timeout = 3000,
      },
      picker = {
        enabled = true,
        formatters = {
          file = {
            filename_first = true,
          },
        },
        win = {
          preview = {
            wo = {
              foldcolumn = '0',
              number = true,
              numberwidth = 4,
              relativenumber = false,
              signcolumn = 'no',
              statuscolumn = '',
            },
          },
        },
        previewers = {
          diff = {
            builtin = false,
            cmd = { 'delta' },
          },
        },
        layouts = {
          vertical = {
            layout = {
              box = 'horizontal',
              backdrop = false,
              width = 0.8,
              height = 0.8,
              border = 'none',
              {
                box = 'vertical',
                { win = 'input', height = 1, border = 'single', title = '{title} {live} {flags}', title_pos = 'center' },
                { win = 'list', title = ' Results ', title_pos = 'center', border = 'single' },
                { win = 'preview', title = '{preview:Preview}', height = 0.65, border = 'single', title_pos = 'center' },
              },
            },
          },
        },
      },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = false },
      statuscolumn = {
        enabled = false,
        left = { 'git', 'sign' },
        right = { 'fold' },
      },
      words = { enabled = true },
      toggle = {
        which_key = false,
      },
      styles = {
        input = {
          border = 'single',
          relative = 'cursor',
          row = -4,
          col = 0,
          wo = {
            winhighlight = 'NormalFloat:Normal,FloatBorder:LineNr,FloatTitle:LineNr,FloatPrompt:LineNr',
          },
        },
      },
    },
    keys = {
      -- Top Pickers & Explorer
      {
        '<leader>.',
        function()
          Snacks.picker.smart()
        end,
        desc = 'Smart Find Files',
      },
      {
        '<leader><space>',
        function()
          Snacks.picker.buffers({
            current = false,
            layout = {
              preset = 'select',
              -- auto_hide = { 'preview' },
              -- cycle = true,
            },
            previewers = { enabled = false },
            focus = 'list',
          })
        end,
        desc = 'Buffers',
      },
      {
        '<leader>,',
        function()
          Snacks.picker.grep()
        end,
        desc = 'Grep',
      },
      {
        '<leader>;',
        function()
          Snacks.picker.resume()
        end,
        desc = 'Resume',
      },
      -- find
      {
        '<leader>fn',
        function()
          Snacks.picker.files({ cwd = vim.fn.stdpath('config') })
        end,
        desc = 'Find Config File',
      },
      {
        '<leader>fp',
        function()
          Snacks.picker.projects()
        end,
        desc = 'Projects',
      },
      {
        '<leader>>',
        function()
          Snacks.picker.recent()
        end,
        desc = 'Recent',
      },
      {
        '<leader><',
        function()
          Snacks.picker.grep_buffers()
        end,
        desc = 'Grep Open Buffers',
      },
      -- git
      {
        '<leader>fg',
        function()
          Snacks.picker.git_diff()
        end,
        desc = 'Git Status',
      },
      -- {
      --   '<leader>gL',
      --   function()
      --     Snacks.picker.git_log_line()
      --   end,
      --   desc = 'Git Log Line',
      -- },
      -- {
      --   '<leader>gs',
      --   function()
      --     Snacks.picker.git_status()
      --   end,
      --   desc = 'Git Status',
      -- },
      -- {
      --   '<leader>gS',
      --   function()
      --     Snacks.picker.git_stash()
      --   end,
      --   desc = 'Git Stash',
      -- },
      -- {
      --   '<leader>gd',
      --   function()
      --     Snacks.picker.git_diff()
      --   end,
      --   desc = 'Git Diff (Hunks)',
      -- },
      -- {
      --   '<leader>gf',
      --   function()
      --     Snacks.picker.git_log_file()
      --   end,
      --   desc = 'Git Log File',
      -- },
      -- Grep
      {
        '<leader>/',
        function()
          Snacks.picker.lines()
        end,
        desc = 'Buffer Lines',
      },
      {
        '<leader>fw',
        function()
          Snacks.picker.grep_word()
        end,
        desc = 'Visual selection or word',
        mode = { 'n', 'x' },
      },
      -- search
      -- {
      --   '<leader>s"',
      --   function()
      --     Snacks.picker.registers()
      --   end,
      --   desc = 'Registers',
      -- },
      -- {
      --   '<leader>s/',
      --   function()
      --     Snacks.picker.search_history()
      --   end,
      --   desc = 'Search History',
      -- },
      -- {
      --   '<leader>sa',
      --   function()
      --     Snacks.picker.autocmds()
      --   end,
      --   desc = 'Autocmds',
      -- },
      -- {
      --   '<leader>sb',
      --   function()
      --     Snacks.picker.lines()
      --   end,
      --   desc = 'Buffer Lines',
      -- },
      -- {
      --   '<leader>sc',
      --   function()
      --     Snacks.picker.command_history()
      --   end,
      --   desc = 'Command History',
      -- },
      -- {
      --   '<leader>sC',
      --   function()
      --     Snacks.picker.commands()
      --   end,
      --   desc = 'Commands',
      -- },
      -- {
      --   '<leader>sd',
      --   function()
      --     Snacks.picker.diagnostics()
      --   end,
      --   desc = 'Diagnostics',
      -- },
      -- {
      --   '<leader>sD',
      --   function()
      --     Snacks.picker.diagnostics_buffer()
      --   end,
      --   desc = 'Buffer Diagnostics',
      -- },
      {
        '<leader>fh',
        function()
          Snacks.picker.help()
        end,
        desc = 'Help Pages',
      },
      -- {
      --   '<leader>sH',
      --   function()
      --     Snacks.picker.highlights()
      --   end,
      --   desc = 'Highlights',
      -- },
      -- {
      --   '<leader>si',
      --   function()
      --     Snacks.picker.icons()
      --   end,
      --   desc = 'Icons',
      -- },
      -- {
      --   '<leader>sj',
      --   function()
      --     Snacks.picker.jumps()
      --   end,
      --   desc = 'Jumps',
      -- },
      {
        '<leader>fk',
        function()
          Snacks.picker.keymaps()
        end,
        desc = 'Keymaps',
      },
      -- {
      --   '<leader>sl',
      --   function()
      --     Snacks.picker.loclist()
      --   end,
      --   desc = 'Location List',
      -- },
      {
        '<leader>fm',
        function()
          Snacks.picker.marks()
        end,
        desc = 'Marks',
      },
      -- {
      --   '<leader>sM',
      --   function()
      --     Snacks.picker.man()
      --   end,
      --   desc = 'Man Pages',
      -- },
      -- {
      --   '<leader>sp',
      --   function()
      --     Snacks.picker.lazy()
      --   end,
      --   desc = 'Search for Plugin Spec',
      -- },
      -- {
      --   '<leader>sq',
      --   function()
      --     Snacks.picker.qflist()
      --   end,
      --   desc = 'Quickfix List',
      -- },
      -- {
      --   '<leader>sR',
      --   function()
      --     Snacks.picker.resume()
      --   end,
      --   desc = 'Resume',
      -- },
      {
        '<leader>fu',
        function()
          Snacks.picker.undo()
        end,
        desc = 'Undo History',
      },
      -- {
      --   '<leader>uC',
      --   function()
      --     Snacks.picker.colorschemes()
      --   end,
      --   desc = 'Colorschemes',
      -- },
      -- LSP
      -- {
      --   '<leader>ss',
      --   function()
      --     Snacks.picker.lsp_symbols()
      --   end,
      --   desc = 'LSP Symbols',
      -- },
      -- {
      --   '<leader>sS',
      --   function()
      --     Snacks.picker.lsp_workspace_symbols()
      --   end,
      --   desc = 'LSP Workspace Symbols',
      -- },
      -- Other
      -- {
      --   '<leader>z',
      --   function()
      --     Snacks.zen()
      --   end,
      --   desc = 'Toggle Zen Mode',
      -- },
      -- {
      --   '<leader>Z',
      --   function()
      --     Snacks.zen.zoom()
      --   end,
      --   desc = 'Toggle Zoom',
      -- },
      {
        '<leader>ss',
        function()
          Snacks.scratch()
        end,
        desc = 'Toggle Scratch Buffer',
      },
      {
        '<leader>sS',
        function()
          Snacks.scratch.select()
        end,
        desc = 'Select Scratch Buffer',
      },
      -- {
      --   '<leader>bd',
      --   function()
      --     Snacks.bufdelete()
      --   end,
      --   desc = 'Delete Buffer',
      -- },
      -- {
      --   '<leader>cR',
      --   function()
      --     Snacks.rename.rename_file()
      --   end,
      --   desc = 'Rename File',
      -- },
      {
        '<leader>gB',
        function()
          Snacks.gitbrowse()
        end,
        desc = 'Git Browse',
        mode = { 'n', 'v' },
      },
      -- {
      --   '<leader>gg',
      --   function()
      --     Snacks.lazygit()
      --   end,
      --   desc = 'Lazygit',
      -- },
      -- {
      --   '<leader>un',
      --   function()
      --     Snacks.notifier.hide()
      --   end,
      --   desc = 'Dismiss All Notifications',
      -- },
      -- {
      --   '<c-/>',
      --   function()
      --     Snacks.terminal()
      --   end,
      --   desc = 'Toggle Terminal',
      -- },
      -- {
      --   '<c-_>',
      --   function()
      --     Snacks.terminal()
      --   end,
      --   desc = 'which_key_ignore',
      -- },
      {
        ']]',
        function()
          Snacks.words.jump(vim.v.count1)
        end,
        desc = 'Next Reference',
        mode = { 'n', 't' },
      },
      {
        '[[',
        function()
          Snacks.words.jump(-vim.v.count1)
        end,
        desc = 'Prev Reference',
        mode = { 'n', 't' },
      },
      -- {
      --   '<leader>N',
      --   desc = 'Neovim News',
      --   function()
      --     Snacks.win({
      --       file = vim.api.nvim_get_runtime_file('doc/news.txt', false)[1],
      --       width = 0.6,
      --       height = 0.6,
      --       wo = {
      --         spell = false,
      --         wrap = false,
      --         signcolumn = 'yes',
      --         statuscolumn = ' ',
      --         conceallevel = 3,
      --       },
      --     })
      --   end,
      -- },
    },
    init = function()
      vim.api.nvim_create_autocmd('User', {
        pattern = 'VeryLazy',
        callback = function()
          -- Setup some globals for debugging (lazy-loaded)
          _G.dd = function(...)
            Snacks.debug.inspect(...)
          end
          _G.bt = function()
            Snacks.debug.backtrace()
          end

          -- Override print to use snacks for `:=` command
          if vim.fn.has('nvim-0.11') == 1 then
            vim._print = function(_, ...)
              dd(...)
            end
          else
            vim.print = _G.dd
          end

          -- Create some toggle mappings
          -- Snacks.toggle.option('spell', { name = 'Spelling' }):map('<leader>us')
          -- Snacks.toggle.option('wrap', { name = 'Wrap' }):map('<leader>uw')
          -- Snacks.toggle.option('relativenumber', { name = 'Relative Number' }):map('<leader>uL')
          -- Snacks.toggle.diagnostics():map('<leader>ud')
          -- Snacks.toggle.line_number():map('<leader>ul')
          -- Snacks.toggle.option('conceallevel', { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map('<leader>uc')
          -- Snacks.toggle.treesitter():map('<leader>uT')
          -- Snacks.toggle.option('background', { off = 'light', on = 'dark', name = 'Dark Background' }):map('<leader>ub')
          -- Snacks.toggle.inlay_hints():map('<leader>uh')
          -- Snacks.toggle.indent():map('<leader>ug')
          -- Snacks.toggle.dim():map('<leader>uD')
        end,
      })
    end,
  },
}
