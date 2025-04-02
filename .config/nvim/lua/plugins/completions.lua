return {
  -- AI completion
  {
    'supermaven-inc/supermaven-nvim',
    enabled = true,
    event = 'InsertEnter',
    config = function()
      require('supermaven-nvim').setup({
        keymaps = {
          accept_suggestion = '<Tab>',
          clear_suggestion = '<C-c>',
          accept_word = '<C-j>',
        },
        ignore_filetypes = { cpp = true }, -- or { "cpp", }
        -- color = {
        --   suggestion_color = "#FFFFFF",
        --   cterm = 244,
        -- },
        log_level = 'off',
        disable_inline_completion = true,
        disable_keymaps = true,
        condition = function()
          return string.match(vim.fn.expand('%:t'), '.env')
        end,
      })
    end,
  },

  -- Blink autocompletion engine
  {
    'saghen/blink.cmp',
    version = '1.*',
    dependencies = {
      'rafamadriz/friendly-snippets',
      -- 'huijiro/blink-cmp-supermaven',
      -- 'onsails/lspkind.nvim',
      'supermaven-inc/supermaven-nvim',
      {
        'saghen/blink.compat',
        version = '*',
        lazy = true,
        opts = {
          impersonate_nvim_cmp = false,
        },
      },
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = 'default',
        ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
        ['<C-s>'] = { 'show_signature', 'hide_signature', 'fallback' },
      },
      snippets = {
        preset = 'default',
      },
      appearance = {
        nerd_font_variant = 'mono',
        use_nvim_cmp_as_default = true,
      },
      completion = {
        menu = {
          border = 'single',
          winhighlight = 'Normal:CmpNormal,CursorLine:CursorLine,FloatBorder:CmpBorder',
          scrollbar = false,
          draw = {
            columns = { { 'kind_icon' }, { 'label', 'label_description' }, { 'source_name' } },
            gap = 2,
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 0,
          window = {
            border = 'single',
            winhighlight = 'Normal:CmpDoc,FloatBorder:CmpDocBorder',
          },
        },
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'supermaven', 'buffer' },
        providers = {
          supermaven = {
            name = 'supermaven',
            module = 'blink.compat.source',
            async = true,

            transform_items = function(ctx, items)
              for _, item in ipairs(items) do
                item.kind_icon = ''
                item.kind_name = 'Supermaven'
                item.source_name = 'AI'
                item.kind_hl = 'BlinkCmpKindEnum'
              end
              return items
            end,
          },
        },
      },
      cmdline = {
        completion = {
          menu = { auto_show = true },
        },
      },
      signature = {
        enabled = true,
        window = {
          border = 'single',
          show_documentation = false,
        },
      },

      fuzzy = { implementation = 'prefer_rust_with_warning' },
    },
    opts_extend = { 'sources.default' },
  },

  -- AI Panel
  {
    'yetone/avante.nvim',
    enabled = false,
    build = 'make',
    keys = {
      {
        '<leader>ia',
        function()
          require('avante.api').ask()
        end,
        desc = 'avante: ask',
        mode = { 'n', 'v' },
      },
      {
        '<leader>ir',
        function()
          require('avante.api').refresh()
        end,
        desc = 'avante: refresh',
      },
      {
        '<leader>ie',
        function()
          require('avante.api').edit()
        end,
        desc = 'avante: edit',
        mode = 'v',
      },
    },
    opts = {
      provider = 'openai',
      openai = {
        endpoint = 'https://api.openai.com/v1',
        model = 'gpt-4o',
        timeout = 30000,
        temperature = 0,
        max_tokens = 4096,
        api_key_name = 'cmd:cat ' .. vim.env.HOME .. '/.openai_api_key',
      },
      hints = { enabled = false },
    },
    dependencies = {
      'stevearc/dressing.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'nvim-tree/nvim-web-devicons',
      -- 'zbirenbaum/copilot.lua',
      {
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { 'Avante' },
        },
        ft = { 'Avante' },
      },
    },
  },

  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    enabled = false,
    event = { 'InsertEnter' },
    dependencies = {
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'onsails/lspkind.nvim',
      'hrsh7th/cmp-path',
      'supermaven-inc/supermaven-nvim',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      local lspkind = require('lspkind')

      -- copilot-cmp stuff
      -- require('copilot_cmp').setup()
      -- lspkind.presets.default.Copilot = ''
      lspkind.presets.default.Supermaven = ''
      vim.api.nvim_set_hl(0, 'CmpItemKindSupermaven', { fg = '#6CC644' })
      -- vim.api.nvim_set_hl(0, 'CmpItemKindCopilot', { fg = '#A48CF2' })

      luasnip.config.setup({})

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = {
          completeopt = 'menu,menuone,noinsert,preview',
          -- autocomplete = false,
        },

        formatting = {
          format = function(entry, item)
            local color_item = require('nvim-highlight-colors').format(entry, { kind = item.kind })
            local icons = lspkind.symbol_map
            item.menu = item.kind
            item.menu_hl_group = 'CmpItemKind' .. (item.kind or '')

            item.kind = item.kind and icons[item.kind] .. ' ' or ''
            item.menu = ' ' .. item.menu

            -- if cmp_ui.format_colors.tailwind then
            --   format_kk.tailwind(entry, item)
            -- end

            if color_item.abbr_hl_group then
              item.kind_hl_group = color_item.abbr_hl_group
              item.menu_hl_group = color_item.abbr_hl_group
              -- item.kind = color_item.abbr
              item.kind = ' '
            end

            return item
          end,

          fields = { 'kind', 'abbr', 'menu' },
        },

        window = {
          completion = {
            scrollbar = false,
            side_padding = 0,
            winhighlight = 'Normal:CmpNormal,CursorLine:CursorLine,FloatBorder:CmpBorder',
            border = 'single',
          },

          documentation = {
            border = 'single',
            winhighlight = 'Normal:CmpDoc,FloatBorder:CmpDocBorder',
          },
        },

        sorting = {
          priority_weight = 2,
          comparators = {
            -- prioritize copilot suggestions
            -- require('copilot_cmp.comparators').prioritize,

            -- Below is the default comparitor list and order for nvim-cmp
            cmp.config.compare.offset,
            -- cmp.config.compare.scopes, --this is commented in nvim-cmp too
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            cmp.config.compare.locality,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
        },
        mapping = cmp.mapping.preset.insert({
          -- Select the [n]ext item
          ['<C-n>'] = cmp.mapping.select_next_item(),
          -- Select the [p]revious item
          ['<C-p>'] = cmp.mapping.select_prev_item(),

          -- Abort the completion
          ['<C-e>'] = cmp.mapping.abort(),

          -- Scroll the documentation window [b]ack / [f]orward
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),

          -- Accept ([y]es) the completion.
          ['<C-y>'] = cmp.mapping.confirm({ select = true }),

          -- Manually trigger a completion from nvim-cmp.
          ['<C-Space>'] = cmp.mapping.complete({}),

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
        }),
        sources = {
          { name = 'nvim_lsp' },
          { name = 'buffer', max_item_count = 5 },
          { name = 'luasnip', max_item_count = 3 },
          { name = 'path', max_item_count = 8 },
          { name = 'supermaven' },
        },
        -- experimental = {
        --   ghost_text = true,
        -- },
      })
    end,
  },

  -- snippets
  {
    'L3MON4D3/LuaSnip',
    enabled = true,
    event = { 'InsertEnter' },
    build = (function()
      if vim.fn.has('win32') == 1 or vim.fn.executable('make') == 0 then
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

  -- Cmdline completion
  {
    'hrsh7th/cmp-cmdline',
    enabled = false,
    event = { 'CmdlineEnter' },
    after = 'nvim-cmp',
    config = function()
      local cmp = require('cmp')

      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline({
          ['<C-p>'] = {
            c = function()
              if cmp.visible() then
                cmp.select_prev_item()
              else
                cmp.complete()
              end
            end,
          },
          ['<C-n>'] = {
            c = function()
              if cmp.visible() then
                cmp.select_next_item()
              else
                cmp.complete()
              end
            end,
          },
        }),

        sources = {
          { name = 'buffer', max_item_count = 5 },
        },
      })

      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline({
          ['<C-p>'] = {
            c = function()
              if cmp.visible() then
                cmp.select_prev_item()
              else
                cmp.complete()
              end
            end,
          },
          ['<C-n>'] = {
            c = function()
              if cmp.visible() then
                cmp.select_next_item()
              else
                cmp.complete()
              end
            end,
          },
        }),
        sources = cmp.config.sources({
          { name = 'path' },
          { name = 'cmdline' },
        }),
      })
    end,
  },

  -- Autopairs
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function()
      require('nvim-autopairs').setup({})
      -- If you want to automatically add `(` after selecting a function or method
      -- local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      -- local cmp = require('cmp')
      -- cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
    end,
  },

  -- Autotag
  {
    'windwp/nvim-ts-autotag',
    ft = { 'html', 'javascriptreact', 'typescriptreact', 'svelte', 'vue', 'php' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    enabled = true,
    config = function()
      require('nvim-ts-autotag').setup({
        opts = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true,
        },
      })
    end,
  },
}
