return {
  -- Theme
  {
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      require('tokyonight').setup({
        style = 'moon',
        transparent = false,
        dim_inactive = true,

        styles = {
          keywords = { italic = false },
          comments = { italic = false },
        },
        on_highlights = function(hl, c)
          hl.FoldColumn = { bg = 'none' }
          hl.SignColumn = { bg = 'none' }
        end,
      })

      vim.cmd.colorscheme('tokyonight')
    end,
  },

  -- Highlight colors HEX/RGB/HSV/HSL
  {
    'brenoprata10/nvim-highlight-colors',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('nvim-highlight-colors').setup()
    end,
  },

  -- Highlight undo/redo changes
  {
    'tzachar/highlight-undo.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('highlight-undo').setup({})
    end,
  },

  -- Highlight todo, notes, etc in comments
  {
    'folke/todo-comments.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },

  -- vim.input and vim.select replacement
  {
    'stevearc/dressing.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {},
    config = function()
      require('dressing').setup({
        input = {
          get_config = function()
            if vim.api.nvim_buf_get_option(0, 'filetype') == 'NvimTree' then
              return { enabled = false }
            end
          end,
        },
      })
    end,
  },

  -- Colorized indents
  {
    'lukas-reineke/indent-blankline.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    main = 'ibl',
    enabled = false,
    config = function()
      require('ibl').setup({
        scope = {
          show_start = false,
        },
        indent = {
          char = '┊',
          tab_char = '┊',
          smart_indent_cap = true,
        },
        whitespace = {
          remove_blankline_trail = true,
        },
      })
    end,
  },
  {
    'nvimdev/indentmini.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    enabled = true,
    config = function()
      require('indentmini').setup({
        char = '┊',
      })
    end,
  },

  -- Scrollbar
  {
    'petertriho/nvim-scrollbar',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { { 'kevinhwang91/nvim-hlslens' } },
    config = function()
      local colors = require('tokyonight.colors').setup()

      require('scrollbar').setup({
        handle = {
          color = colors.bg_highlight,
        },
        marks = {
          Search = { color = colors.orange },
          Error = { color = colors.error },
          Warn = { color = colors.warning },
          Info = { color = colors.info },
          Hint = { color = colors.hint },
          Misc = { color = colors.purple },
          GitAdd = { color = colors.info },
        },
        handlers = {
          cursor = false,
          search = true,
          gitsigns = true,
        },
      })
    end,
  },

  -- Noice (nice cmd/search line ui + notifications)
  {
    'folke/noice.nvim',
    event = { 'VeryLazy' },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      'MunifTanjim/nui.nvim',
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      -- 'rcarriga/nvim-notify',
    },
    keys = {
      {
        '<leader>ll',
        '<cmd>NoiceTelescope<CR>',
        desc = 'List [L]ogs',
      },
    },
    config = function()
      require('noice').setup({
        cmdline = {
          format = {
            cmdline = { icon = '>' },
            search_down = { icon = ' ⌄' },
            search_up = { icon = ' ⌃' },
            filter = { icon = '$' },
            -- lua = { icon = '☾' },
            help = { icon = '?' },
          },
        },
        views = {
          cmdline_popup = {
            border = {
              style = 'rounded',
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
    event = 'VeryLazy',
    init = function()
      vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
      vim.o.foldcolumn = '1' -- '0' is not bad
      vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
    end,
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
            border = 'rounded',
            winblend = 15,
          },
          mappings = {
            scrollD = '<C-f>',
            scrollU = '<C-b>',
            jumpTop = '[',
            jumpBot = ']',
          },
        },
      })

      vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
      vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
      vim.keymap.set('n', 'zr', require('ufo').openFoldsExceptKinds)

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
