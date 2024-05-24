return {
  -- Copilot
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = { 'InsertEnter' },
    config = function()
      local colors = require('tokyonight.colors').setup()
      vim.api.nvim_set_hl(0, 'CopilotSuggestion', { fg = colors.fg_dark })

      require('copilot').setup {
        panel = {
          keymap = {
            open = '<M-p>',
          },
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = false,
          },
        },
        filetypes = {
          yaml = true,
          markdown = true,
          ['.'] = true,
        },
      }

      -- Enable <Tab> to indent if no suggestions are available
      vim.keymap.set('i', '<Tab>', function()
        if require('copilot.suggestion').is_visible() then
          require('copilot.suggestion').accept()
        else
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, false, true), 'n', false)
        end
      end, { desc = 'Super Tab', silent = true })
    end,
  },

  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          {
            'rafamadriz/friendly-snippets',
            config = function()
              require('luasnip.loaders.from_vscode').lazy_load()
            end,
          },
        },
      },
      'saadparwaiz1/cmp_luasnip',

      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'onsails/lspkind.nvim',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
    },
    config = function()
      local cmp = require 'cmp'
      local cmp_window = require 'cmp.config.window'
      local luasnip = require 'luasnip'
      local lspkind = require 'lspkind'

      luasnip.config.setup {}

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert,preview' },

        ---@diagnostic disable-next-line: missing-fields
        formatting = {
          format = lspkind.cmp_format {
            mode = 'text',
            maxwidth = 50,
            ellipsis_char = '...',

            before = function(entry, vim_item)
              vim_item.kind = vim_item.kind
              vim_item.menu = ({
                nvim_lsp = '[LSP]',
                buffer = '[BUF]',
                path = '[PATH]',
                luasnip = '[SNIP]',
              })[entry.source.name]
              vim_item.abbr = lspkind.presets.default[vim_item.kind] .. '  ' .. vim_item.abbr

              return vim_item
            end,
          },
        },

        window = {
          completion = cmp_window.bordered(),
          documentation = cmp_window.bordered(),
        },

        mapping = cmp.mapping.preset.insert {
          -- Select the [n]ext item
          ['<C-j>'] = cmp.mapping.select_next_item(),
          -- Select the [p]revious item
          ['<C-k>'] = cmp.mapping.select_prev_item(),

          -- Abort the completion
          ['<C-e>'] = cmp.mapping.abort(),

          -- Scroll the documentation window [b]ack / [f]orward
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),

          -- Accept ([y]es) the completion.
          ['<C-y>'] = cmp.mapping.confirm { select = true },

          -- Manually trigger a completion from nvim-cmp.
          ['<C-Space>'] = cmp.mapping.complete {},

          -- <c-l> will move you to the right of each of the expansion locations.
          -- <c-h> is similar, except moving you backwards.
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),

          -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
          --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'buffer', max_item_count = 5 },
          { name = 'luasnip', max_item_count = 3 },
          { name = 'path', max_item_count = 3 },
        },
      }

      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline {
          ['<C-k>'] = {
            c = function()
              if cmp.visible() then
                cmp.select_prev_item()
              else
                cmp.complete()
              end
            end,
          },
          ['<C-j>'] = {
            c = function()
              if cmp.visible() then
                cmp.select_next_item()
              else
                cmp.complete()
              end
            end,
          },
        },

        sources = {
          { name = 'buffer' },
        },
      })

      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline {
          ['<C-k>'] = {
            c = function()
              if cmp.visible() then
                cmp.select_prev_item()
              else
                cmp.complete()
              end
            end,
          },
          ['<C-j>'] = {
            c = function()
              if cmp.visible() then
                cmp.select_next_item()
              else
                cmp.complete()
              end
            end,
          },
        },
        sources = cmp.config.sources {
          { name = 'path' },
          { name = 'cmdline' },
        },
      })
    end,
  },

  -- Autopairs
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    dependencies = { 'hrsh7th/nvim-cmp' },
    config = function()
      require('nvim-autopairs').setup {}
      -- If you want to automatically add `(` after selecting a function or method
      local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
      local cmp = require 'cmp'
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
    end,
  },
}
