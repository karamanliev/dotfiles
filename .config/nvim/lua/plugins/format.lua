return {
  -- Detect tabstop and shiftwidth automatically
  {
    'tpope/vim-sleuth',
    enabled = false,
    event = { 'BufReadPre', 'BufNewFile' },
  },

  -- Autoformat on save
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>df',
        function()
          require('conform').format({ async = true, lsp_fallback = true })
        end,
        mode = '',
        desc = 'Format document',
      },
      {
        '<leader>tf',
        '<cmd>ToggleBufferAutoformat<CR>',
        mode = '',
        desc = 'Toggle buffer autoformatting',
      },
      {
        '<leader>tF',
        '<cmd>ToggleGlobalAutoformat<CR>',
        mode = '',
        desc = 'Toggle global autoformatting',
      },
      {
        '<leader>tE',
        '<cmd>FormatEnable<CR>',
        mode = '',
        desc = 'Enable autoformatting (buf & global)',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true, markdown = true }
        if vim.b.dont_format_on_write or vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return {
          timeout_ms = 500,
          lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
        }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        javascript = { 'prettierd' },
        typescript = { 'prettierd' },
        javascriptreact = { 'prettierd' },
        typescriptreact = { 'prettierd' },
        css = { 'prettierd' },
        html = { 'prettierd' },
        json = { 'prettierd' },
        yaml = { 'prettierd' },
        graphql = { 'prettierd' },
        zsh = { 'shfmt' },
        sh = { 'shfmt' },
      },
    },
  },
}
