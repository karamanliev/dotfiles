return {
  -- Blink autocompletion engine
  {
    'saghen/blink.cmp',
    version = '1.*',
    dependencies = {
      'rafamadriz/friendly-snippets',
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = 'default',
        ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
        ['<C-l>'] = { 'snippet_forward', 'fallback' },
        ['<C-h>'] = { 'snippet_backward', 'fallback' },
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
        default = { 'lsp', 'path', 'snippets', 'buffer' },
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

  -- Custom Snippets
  {
    'L3MON4D3/LuaSnip',
    enabled = false,
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
}
