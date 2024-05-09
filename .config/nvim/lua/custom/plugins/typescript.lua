return {
  'pmizio/typescript-tools.nvim',
  dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
  opts = {
    setup = function()
      require('typescript-tools').setup {
        lsp = {
          on_attach = require('lsp').on_attach,
          capabilities = require('lsp').capabilities,
        },
      }
    end,
  },
}
