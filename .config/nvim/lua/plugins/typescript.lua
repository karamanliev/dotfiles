return {
  -- TSTools LSP
  {
    'pmizio/typescript-tools.nvim',
    enabled = false,
    ft = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx' },
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    keys = {
      { 'gd', '<cmd>TSToolsGoToSourceDefinition<cr>', desc = 'Goto Source Definition' },
      -- { 'gS', ' <cmd>lua vim.cmd "vsplit" vim.cmd "TSToolsGoToSourceDefinition"<cr>', desc = 'Goto Source Definition (vsplit)' },
      { '<leader>co', '<cmd>TSToolsOrganizeImports<cr>', desc = 'Organize Imports' },
      { '<leader>cu', '<cmd>TSToolsRemoveUnused<cr>', desc = 'Remove Unused Imports' },
      { '<leader>cs', '<cmd>TSToolsSortImports<cr>', desc = 'Sort Imports' },
      { '<leader>ci', '<cmd>TSToolsAddMissingImports<cr>', desc = 'Add Missing Imports' },
      { '<leader>cR', '<cmd>TSToolsRenameFile<cr>', desc = 'Rename File and Update Imports' },
      { '<leader>cf', '<cmd>TSToolsFileReferences<cr>', desc = 'Show File References' },
      { '<leader>cF', '<cmd>TSToolsFixAll<cr>', desc = 'Fix All' },
    },
    config = function()
      require('typescript-tools').setup({
        on_attach = function(client, _)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end,
        handlers = {},

        settings = {
          separate_diagnostic_server = true,
          publish_diagnostic_on = 'change',
          expose_as_code_action = {},
          tsserver_path = nil,
          tsserver_plugins = {
            '@styled/typescript-styled-plugin',
          },
          tsserver_max_memory = 'auto',
          tsserver_format_options = {},
          tsserver_file_preferences = {
            includeInlayParameterNameHints = 'none',
            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
            includeInlayFunctionParameterTypeHints = false,
            includeInlayVariableTypeHints = false,
            includeInlayVariableTypeHintsWhenTypeMatchesName = false,
            includeInlayPropertyDeclarationTypeHints = false,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayEnumMemberValueHints = true,
          },
          tsserver_locale = 'en',
          complete_function_calls = true,
          include_completions_with_insert_text = true,
          code_lens = 'off',
          disable_member_code_lens = true,
          jsx_close_tag = {
            enable = true,
            filetypes = { 'javascriptreact', 'typescriptreact' },
          },
        },
      })
    end,
  },

  -- Global project lint with TSC
  {
    'dmmulroy/tsc.nvim',
    ft = { 'typescript', 'typescriptreact' },
    config = function()
      require('tsc').setup({
        use_trouble_qflist = false,
        auto_open_qflist = true,
        auto_focus_qflist = true,
        pretty_errors = true,
      })

      vim.keymap.set('n', '<leader>cT', '<cmd>TSC<cr>', { desc = 'Typecheck Project' })
      vim.keymap.set('n', '<leader>ct', '<cmd>TSCOpen<cr>', { desc = 'TSC Panel Open' })
    end,
  },

  -- Better errors for TypeScript
  {
    'dmmulroy/ts-error-translator.nvim',
    ft = { 'typescript', 'typescriptreact' },
    -- opts = {
    --   auto_override_publish_diagnostics = false,
    -- },
    config = function()
      require('ts-error-translator').setup()
    end,
  },
  -- NPM package info
  {
    'vuki656/package-info.nvim',
    enabled = false,
    dependencies = { 'MunifTanjim/nui.nvim' },
    event = 'BufRead package.json',
    config = function()
      require('package-info').setup({
        icons = {
          enable = true,
          style = {
            up_to_date = '|  ',
            outdated = '|  ',
            invalid = '|  ',
          },
        },
        autostart = true,
        hide_up_to_date = true,
        hide_unstable_versions = true,
        package_manager = 'yarn',
      })

      -- add keymap with ui select for package.json
      local augroup = vim.api.nvim_create_augroup('package-info', { clear = true })
      local wk = require('which-key')
      vim.api.nvim_create_autocmd('BufReadPre', {
        pattern = 'package.json',
        callback = function()
          wk.add({
            '<leader>cp',
            function()
              local actions = {
                { label = 'Change Package Version', func = require('package-info').change_version },
                { label = 'Update Package', func = require('package-info').update },
                { label = 'Delete Package', func = require('package-info').delete },
                { label = 'Install New Package', func = require('package-info').install },
                {
                  label = 'Reload Plugin',
                  func = function()
                    require('package-info').show({ force = true })
                  end,
                },
              }

              local options = vim.tbl_map(function(item)
                return item.label
              end, actions)

              vim.ui.select(options, { prompt = 'Package Info' }, function(_, index)
                if index then
                  actions[index].func()
                end
              end)
            end,
            buffer = 0,
            icon = ' ',
            mode = 'n',
            desc = 'package.json',
          })
        end,
        group = augroup,
        desc = 'Load package-info keys',
      })

      vim.cmd('hi! link PackageInfoOutdatedVersion DiagnosticHint')

      -- add package.json to statusline
      local statusline_modules = require('custom.statusline').custom_modules

      statusline_modules.package_info = function()
        local loading_status = require('package-info.ui.generic.loading-status')
        local spinner = loading_status and loading_status.state.current_spinner or ''
        local status = require('package-info').get_status() or ''

        if loading_status and loading_status.state.is_running then
          return table.concat({ '%#PackageInfoOutdatedVersionStatusLine#' .. spinner, ' ', status })
        end

        return ''
      end
    end,
  },

  -- Autotag
  {
    'windwp/nvim-ts-autotag',
    ft = { 'html', 'javascriptreact', 'typescriptreact', 'svelte', 'vue', 'php' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    enabled = false,
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
