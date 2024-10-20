return {
  -- Highlight colors HEX/RGB/HSV/HSL
  {
    'brenoprata10/nvim-highlight-colors',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('nvim-highlight-colors').setup({
        render = 'virtual',
        virtual_symbol = '■',
        enable_tailwind = true,
        exclude_filetypes = {
          'bigfile',
        },
      })
    end,
  },

  -- Highlight undo/redo changes
  {
    'tzachar/highlight-undo.nvim',
    enabled = true,
    config = function()
      require('highlight-undo').setup({
        duration = 650,
        keymaps = {
          undo = {
            desc = 'Undo',
            hlgroup = 'Undo',
            mode = 'n',
            lhs = 'u',
            rhs = 'u',
            opts = {},
          },
          redo = {
            desc = 'Redo',
            hlgroup = 'Redo',
            mode = 'n',
            lhs = '<C-r>',
            rhs = '<C-r>',
            opts = {},
          },
          paste = {
            desc = 'Paste',
            hlgroup = 'Paste',
            mode = 'n',
            lhs = 'p',
            rhs = 'p',
            opts = {},
          },
          Paste = {
            desc = 'Paste',
            hlgroup = 'Paste',
            mode = 'n',
            lhs = 'P',
            rhs = 'P',
            opts = {},
          },
        },
      })

      vim.cmd('hi! link Undo DiffChange')
      vim.cmd('hi! link Redo DiffChange')
      vim.cmd('hi! link Paste DiffAdd')
    end,
  },

  -- Highlight todo, notes, etc in comments
  {
    'folke/todo-comments.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    keys = {
      {
        ']t',
        function()
          require('todo-comments').jump_next()
        end,
        desc = 'Next TODO comment',
      },
      {
        '[t',
        function()
          require('todo-comments').jump_prev()
        end,
        desc = 'Previous TODO comment',
      },
    },
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },

  -- vim.input and vim.select replacement
  {
    'stevearc/dressing.nvim',
    event = { 'VeryLazy' },
    opts = {},
    config = function()
      require('dressing').setup({
        select = {
          get_config = function(opts)
            if opts.kind == 'codeaction' or 'Package Info' then
              return {
                backend = 'builtin',
              }
            end
          end,
        },
      })
    end,
  },

  -- Colorized indents
  {
    'nvimdev/indentmini.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    enabled = false,
    config = function()
      require('indentmini').setup({
        char = '┊',
        exclude = {
          'bigfile',
        },
      })
    end,
  },

  {
    'shellRaining/hlchunk.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('hlchunk').setup({
        chunk = {
          enable = true,
          priority = 15,
          style = {
            { fg = '#806d9c' }, -- TODO: link to some highlight?
            { link = 'Error' },
          },
          use_treesitter = true,
          chars = {
            horizontal_line = '─',
            vertical_line = '│',
            left_top = '╭',
            left_bottom = '╰',
            right_arrow = '>',
          },
          textobject = '',
          max_file_size = 1024 * 1024,
          error_sign = true,
          -- animation related
          duration = 0,
          delay = 0,
        },
        indent = {
          enable = true,
          priority = 10,
          style = {
            { link = 'Whitespace' },
          },
          use_treesitter = false,
          chars = { '┊' },
          ahead_lines = 5,
          delay = 100,
        },
        line_num = {
          enable = false,
          style = '#806d9c',
        },
      })
    end,
  },
  -- Scrollbar
  {
    'petertriho/nvim-scrollbar',
    enabled = false,
    event = { 'BufReadPre', 'BufNewFile' },
    init = function()
      -- show buffer marks in scrollbar
      local function get_curr_buf_marks(bufnr)
        local marks = {}
        local local_marks = vim.fn.getmarklist(bufnr)
        local global_marks = vim.fn.getmarklist()

        local function insert_marks(marks_list)
          for _, mark in ipairs(marks_list) do
            if mark.mark:match('%a') and mark.pos[1] == bufnr and mark.pos[2] > 0 then
              table.insert(marks, {
                text = mark.mark:gsub("'", ''),
                line = mark.pos[2],
                type = 'Misc',
                level = 2,
              })
            end
          end
        end

        insert_marks(local_marks)
        insert_marks(global_marks)

        return marks
      end

      require('scrollbar.handlers').register('marks', get_curr_buf_marks)
    end,
    config = function()
      local colors = require('tokyonight.colors').setup()

      require('scrollbar').setup({
        show_in_active_only = false,
        set_highlights = true,
        handle = {
          color = colors.fg_gutter,
          -- highlight = "ScrollbarHandle"
        },
        marks = {
          Search = {
            text = { '-', '-' },
            color = colors.orange,
          },
          Error = {
            color = colors.error,
          },
          Warn = {
            color = colors.warning,
          },
          Info = {
            text = { '', '' },
          },
          Hint = {
            text = { '', '' },
          },
          GitChange = { color = colors.blue0 },
          GitDelete = { text = '┆' },
          Misc = {
            color = colors.fg_dark,
            priority = 2,
          },
        },
        handlers = {
          cursor = false,
          search = true,
          gitsigns = true,
        },
        excluded_buftypes = {
          'terminal',
        },
        excluded_filetypes = {
          'cmp_docs',
          'cmp_menu',
          'noice',
          'prompt',
          'TelescopePrompt',
          'alpha',
          'mason',
          'lazy',
          'bigfile',
        },
      })
    end,
  },

  -- Highlight search results
  {
    'kevinhwang91/nvim-hlslens',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('hlslens').setup({
        calm_down = true,
        nearest_only = true,

        -- make scrollbar show the search result
        -- build_position_cb = function(plist, _, _, _)
        --   require('scrollbar.handlers.search').handler.show(plist.start_pos)
        -- end,
      })

      local kopts = { noremap = true, silent = true }

      vim.api.nvim_set_keymap('n', 'n', [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]], kopts)
      vim.api.nvim_set_keymap('n', 'N', [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]], kopts)
      vim.api.nvim_set_keymap('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
      vim.api.nvim_set_keymap('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
      vim.api.nvim_set_keymap('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
      vim.api.nvim_set_keymap('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)

      -- hide search results in scrollbar when search is done
      -- vim.cmd([[
      --   augroup scrollbar_search_hide
      --       autocmd!
      --       autocmd CmdlineLeave : lua require('scrollbar.handlers.search').handler.hide()
      --   augroup END
      -- ]])
    end,
  },

  -- Noice (nice cmd/search line ui + notifications)
  {
    'folke/noice.nvim',
    event = { 'VeryLazy' },
    enabled = false,
    dependencies = {
      'MunifTanjim/nui.nvim',
    },
    keys = {
      {
        '<leader>nf',
        '<cmd>NoiceTelescope<CR>',
        desc = 'Noice Telescope',
      },
      {
        '<leader>na',
        '<cmd>NoiceAll<CR>',
        desc = 'Noice All',
      },
      {
        '<leader>nl',
        '<cmd>NoiceLast<CR>',
        desc = 'Noice Last',
      },
      {
        '<leader>ne',
        '<cmd>NoiceErrors<CR>',
        desc = 'Noice Errors',
      },
      {
        '<leader>nh',
        '<cmd>NoiceHistory<CR>',
        desc = 'Noice History',
      },
    },
    config = function()
      require('noice').setup({
        cmdline = {
          view = 'cmdline_popup', -- change to 'cmdline_popup' for previous style
          format = {
            cmdline = { icon = '', title = '' },
            search_down = { icon = ' ⌄', title = '' },
            search_up = { icon = ' ⌃', title = '' },
            filter = { icon = '$', title = '' },
            lua = { title = '' },
            help = { icon = '?', title = '' },
            input = { title = '' },
          },
        },
        views = {
          cmdline = {
            position = {
              row = -1,
            },
          },
          cmdline_popup = {
            border = {
              style = 'none',
              padding = { 0, 1 },
            },
            position = {
              row = '25%',
              col = '50%',
            },
          },
          popupmenu = {
            enabled = false,
          },
          mini = {
            win_options = {
              winblend = 0,
              winhighlight = {
                Normal = 'NormalFloat',
                FloatBorder = 'NormalFloat',
              },
            },
          },
        },
        lsp = {
          -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
          override = {
            ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
            ['vim.lsp.util.stylize_markdown'] = true,
            ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp
          },
          -- progress = {
          --   enabled = false,
          -- },
        },
        -- you can enable a preset for easier configuration
        presets = {
          bottom_search = false, -- use a classic bottom cmdline for search
          command_palette = false, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false, -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = true, -- add a border to hover docs and signature help
        },
        -- hide search virtual text
        routes = {
          {
            filter = {
              event = 'lsp',
              kind = 'progress',
              cond = function(message)
                local client = vim.tbl_get(message.opts, 'progress', 'client')
                return client == 'lua_ls' -- skip lua lsp progress
              end,
            },
            opts = { skip = true },
          },
          {
            filter = {
              event = 'msg_show',
              kind = 'search_count',
            },
            opts = { skip = true },
          },
          {
            filter = {
              event = 'msg_show',
              any = {
                { find = '%d+L, %d+B' },
                { find = '; after #%d+' },
                { find = '; before #%d+' },
                { find = '%d fewer lines' },
                { find = '%d more lines' },
                { find = 'written' },
                { find = 'Agent service not initialized' },
              },
            },
            opts = { skip = true },
          },
        },
      })
    end,
  },

  -- Folding
  {
    'kevinhwang91/nvim-ufo',
    dependencies = {
      'kevinhwang91/promise-async',
    },
    event = { 'VeryLazy' },
    config = function()
      local handler = function(virtText, lnum, endLnum, width, truncate)
        local alignLimitByTextWidth = true -- limit the alignment of the fold text by:
        -- true: the textwidth value, false: the width of the current window
        local alignLimiter = alignLimitByTextWidth and vim.opt.textwidth['_value'] or vim.api.nvim_win_get_width(0)
        local newVirtText = {}
        local totalLines = vim.api.nvim_buf_line_count(0)
        local foldedLines = endLnum - lnum
        local suffix = (' --- %d / %d%%'):format(foldedLines, foldedLines / totalLines * 100)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        local rAlignAppndx = math.max(math.min(alignLimiter, width - 1) - curWidth - sufWidth, 0)
        suffix = (' '):rep(rAlignAppndx) .. suffix
        table.insert(newVirtText, { suffix, 'MoreMsg' })
        return newVirtText
      end
      require('ufo').setup({
        fold_virt_text_handler = handler,
        open_fold_hl_timeout = 150,
        preview = {
          win_config = {
            border = 'single',
            winhighlight = 'Normal:NormalFloat',
            winblend = 0,
          },
          mappings = {
            scrollD = '<C-d>',
            scrollU = '<C-u>',
            jumpTop = '[',
            jumpBot = ']',
          },
        },
      })

      vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
      vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
      vim.keymap.set('n', 'zr', require('ufo').openFoldsExceptKinds)
      vim.keymap.set('n', 'zm', function()
        require('ufo').closeFoldsWith(1)
      end)

      -- disable ufo and fold column for Neogit and etc
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'Neogit*' },
        callback = function()
          require('ufo').detach()
          vim.opt_local.foldenable = false
          vim.opt_local.foldcolumn = '0'
        end,
      })
    end,
  },

  -- make the statusline fold indicator more bearable
  {
    'luukvbaal/statuscol.nvim',
    enabled = false,
    opts = function()
      local builtin = require('statuscol.builtin')
      return {
        setopt = true,
        bt_ignore = { 'nofile', 'terminal' },
        segments = {
          { text = { ' ' }, click = 'v:lua.ScFa' },
          { text = { builtin.foldfunc, ' ' }, click = 'v:lua.ScFa' },
          {
            text = { builtin.lnumfunc, ' ' },
            condition = { true, builtin.not_empty },
            click = 'v:lua.ScLa',
          },
          { text = { '%s' } },
        },
      }
    end,
  },
}
