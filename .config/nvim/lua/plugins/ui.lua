return {
  -- Highlight colors HEX/RGB/HSV/HSL
  {
    'brenoprata10/nvim-highlight-colors',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('nvim-highlight-colors').setup({
        -- render = 'virtual',
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
    enabled = false,
    keys = {
      'u',
      '<C-r>',
      'p',
      'P',
    },
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

  -- indents
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
            { link = 'DiagnosticSignError' },
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

  -- Highlight search results
  {
    'kevinhwang91/nvim-hlslens',
    enabled = false,
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

  -- Folding
  {
    'kevinhwang91/nvim-ufo',
    enabled = false,
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

  -- Make cursorline span to the signcolumn
  {
    'jake-stewart/force-cul.nvim',
    enabled = false,
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('force-cul').setup()
    end,
  },
}
