return {
  -- Linting
  {
    'mfussenegger/nvim-lint',
    enabled = true,
    event = { 'BufEnter', 'BufWritePost', 'InsertLeave' },
    config = function()
      local lint = require('lint')
      local eslint_d = require('lint').linters.eslint_d

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
      vim.list_extend(eslint_d.args, {
        '--rule=@typescript-eslint/no-unused-vars: off',
        '--rule=prettier/prettier: off',
      })

      -- Custom diagnostic settings for eslint_d
      -- local ns = require('lint').get_namespace('eslint_d')
      -- vim.diagnostic.config({ virtual_text = true }, ns)

      -- Create autocommand which carries out the actual linting
      -- on the specified events.
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({
        'BufEnter',
        'BufWritePost',
        'InsertLeave',
        -- update on every change
        'TextChanged',
      }, {
        group = lint_augroup,
        callback = function()
          if vim.opt_local.modifiable:get() then
            lint.try_lint()
          end
        end,
      })

      vim.keymap.set('n', '<leader>dl', function()
        lint.try_lint()
      end, { desc = 'Lint document' })
    end,
  },
}
