return {
  -- Linting
  {
    'mfussenegger/nvim-lint',
    enabled = false,
    event = { 'BufEnter', 'BufWritePost', 'InsertLeave' },
    config = function()
      local lint = require('lint')
      local eslint_d = require('lint.linters.eslint_d')

      lint.linters_by_ft = {
        javascript = { 'eslint_d' },
        typescript = { 'eslint_d' },
        javascriptreact = { 'eslint_d' },
        typescriptreact = { 'eslint_d' },
        html = { 'htmlhint' },
        json = { 'jsonlint' },
      }

      -- Disable this rule as it's managed by tsserver
      eslint_d.args = eslint_d.args or {} -- Ensure args is initialized
      vim.list_extend(eslint_d.args, { '--rule', '@typescript-eslint/no-unused-vars: off' })

      -- Create autocommand which carries out the actual linting
      -- on the specified events.
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })

      vim.keymap.set('n', '<leader>dl', function()
        lint.try_lint()
      end, { desc = 'Lint document' })
    end,
  },
}
