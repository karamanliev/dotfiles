-- LSP Configuration & Plugins
return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      -- Remove default nvim 0.11 lsp mappings
      vim.keymap.del('n', 'grr')
      vim.keymap.del('n', 'gri')
      vim.keymap.del('n', 'gra')
      vim.keymap.del('n', 'grn')

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          local map = function(keys, func, desc, mode)
            vim.keymap.set(mode and mode or 'n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Keybinds are only enabled for tsserver files
          -- NOTE: for some reason `if client.name == 'tsserver'` doesn't work well and <gd> gets reasigned to default go_to_definition instead
          local ts_ft = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx' }

          if not vim.tbl_contains(ts_ft, vim.bo.filetype) then
            map('gd', require('telescope.builtin').lsp_definitions, 'Goto Definition')
          end

          map('gr', require('telescope.builtin').lsp_references, 'Goto References')
          map('gI', require('telescope.builtin').lsp_implementations, 'Goto Implementation')
          map('<leader>cd', require('telescope.builtin').lsp_type_definitions, 'Type Definition')
          map('<leader>cr', vim.lsp.buf.rename, 'Rename Word')
          map('<leader>cc', vim.lsp.buf.code_action, 'Code Action', { 'n', 'v' })

          map('K', function()
            vim.lsp.buf.hover({
              border = 'single',
            })
          end, 'Hover Info')
          map('<C-s>', function()
            vim.lsp.buf.signature_help({
              border = 'single',
            })
          end, 'Signature Help', { 'n', 'i' })

          -- Highlight references
          if client and client.server_capabilities.documentHighlightProvider then
            local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
              callback = function(evt)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = 'lsp-highlight', buffer = evt.buf })
              end,
            })
          end
        end,
      })

      local servers = {
        bashls = {},
        eslint = {
          settings = {
            workingDirectories = { mode = 'auto' },
            rulesCustomizations = {
              { rule = 'prettier/prettier', severity = 'off' },
              { rule = '@typescript-eslint/no-unused-vars', severity = 'off' },
            },
            format = false,
          },
        },
        tailwindcss = {
          root_dir = function(fname)
            local root_pattern = require('lspconfig').util.root_pattern('tailwind.config.cjs', 'tailwind.config.js', 'postcss.config.js', 'tailwind.config.mjs')
            return root_pattern(fname)
          end,
        },
        jsonls = {
          settings = {
            json = {
              schemas = require('schemastore').json.schemas({}),
              validate = { enable = true },
            },
          },
        },
        yamlls = {
          settings = {
            yaml = {
              schemaStore = {
                enable = false,
                url = '',
              },
              schemas = require('schemastore').yaml.schemas(),
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                library = vim.api.nvim_get_runtime_file('', true),
              },
            },
          },
        },
        gopls = {
          settings = {
            gopls = {
              analyses = {
                unusedparams = true,
                shadow = true,
                unusedwrite = true,
                unreachable = false,
              },
              staticcheck = true,
            },
          },
        },
      }

      for server_name, config in pairs(servers) do
        vim.lsp.config(server_name, config)
        vim.lsp.enable(server_name)
      end
    end,
  },

  {
    'williamboman/mason.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {},
  },

  -- ts-tools
  {
    'pmizio/typescript-tools.nvim',
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

  -- Show definitions in a popup
  {
    'rmagatti/goto-preview',
    keys = {
      { 'gpd', desc = 'Preview definition' },
      { 'gpD', desc = 'Preview declaration' },
      { 'gpi', desc = 'Preview implementation' },
      { 'gpr', desc = 'Preview references' },
      { 'gpt', desc = 'Preview type definition' },
      { 'gP', desc = 'Close preview windows' },
    },
    config = function()
      require('goto-preview').setup({
        width = 120,
        height = 20,
        default_mappings = true,
        post_open_hook = function(buff, win)
          vim.keymap.set('n', 'q', function()
            if vim.api.nvim_win_is_valid(win) then
              vim.api.nvim_win_close(win, true)
            end
          end, { buffer = buff })
        end,
      })
    end,
  },

  -- NPM package info
  {
    'vuki656/package-info.nvim',
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

  -- Illuminate the current word under the cursor and next/prev reference
  {
    'RRethy/vim-illuminate',
    enabled = false,
    event = { 'BufReadPost', 'BufNewFile', 'BufWritePre' },
    opts = {
      delay = 200,
      large_file_cutoff = 2000,
      large_file_overrides = {
        providers = { 'lsp' },
      },
      filetypes_denylist = {
        'dirbuf',
        'dirvish',
        'fugitive',
        'TelescopePrompt',
        'spectre_panel',
        'DiffviewFiles',
        'DressingInput',
      },
    },
    config = function(_, opts)
      require('illuminate').configure(opts)

      local function map(key, dir, buffer)
        vim.keymap.set('n', key, function()
          require('illuminate')['goto_' .. dir .. '_reference'](true)
        end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. ' Reference', buffer = buffer })
      end

      map(']]', 'next')
      map('[[', 'prev')

      -- also set it after loading ftplugins, since a lot overwrite [[ and ]]
      vim.api.nvim_create_autocmd('FileType', {
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()
          map(']]', 'next', buffer)
          map('[[', 'prev', buffer)
        end,
      })
    end,
    keys = {
      { ']]', desc = 'Next Reference' },
      { '[[', desc = 'Prev Reference' },
    },
  },

  -- Turbo console.log
  {
    'Goose97/timber.nvim',
    keys = {
      'gl',
    },
    config = function()
      require('timber').setup({
        log_templates = {
          watcher = {
            javascript = [[console.log('%watcher_marker_start', JSON.stringify(%log_target, null, 2), '%watcher_marker_end')]],
            typescript = [[console.log('%watcher_marker_start', JSON.stringify(%log_target, null, 2), '%watcher_marker_end')]],
            jsx = [[console.log('%watcher_marker_start', JSON.stringify(%log_target, null, 2), '%watcher_marker_end')]],
            tsx = [[console.log('%watcher_marker_start', JSON.stringify(%log_target, null, 2), '%watcher_marker_end')]],
          },
          default = {
            javascript = [[console.log('%log_marker%log_target', %log_target)]],
            typescript = [[console.log('%log_marker%log_target', %log_target)]],
            jsx = [[console.log('%log_marker%log_target', %log_target)]],
            tsx = [[console.log('%log_marker%log_target', %log_target)]],
          },
          json = {
            javascript = [[console.log('%log_marker%log_target', JSON.stringify(%log_target, null, 2))]],
            typescript = [[console.log('%log_marker%log_target', JSON.stringify(%log_target, null, 2))]],
            jsx = [[console.log('%log_marker%log_target', JSON.stringify(%log_target, null, 2))]],
            tsx = [[console.log('%log_marker%log_target', JSON.stringify(%log_target, null, 2))]],
          },
        },
        log_watcher = {
          enabled = true,
          sources = {
            ts = {
              type = 'filesystem',
              name = 'Log file',
              path = '/tmp/watcher.log',
              buffer = {
                syntax = 'json',
              },
            },
          },
          preview_snippet_length = 64,
        },
        keymaps = {
          insert_log_below = 'glo',
          insert_log_above = 'glO',
          insert_plain_log_below = false,
          insert_plain_log_above = false,
          insert_batch_log = 'glb',
          add_log_targets_to_batch = 'gla',
          insert_log_below_operator = 'g<S-l>o',
          insert_log_above_operator = 'g<S-l>O',
          insert_batch_log_operator = 'g<S-l>b',
          add_log_targets_to_batch_operator = 'g<S-l>a',
        },
        default_keymaps_enabled = true,
        log_summary = {
          win = {
            position = 'right',
          },
        },
      })

      vim.keymap.set('n', 'glj', function()
        return require('timber.actions').insert_log({ position = 'below', template = 'json' })
      end, {
        desc = 'Log JSON (below)',
      })

      vim.keymap.set('n', 'glJ', function()
        return require('timber.actions').insert_log({ position = 'above', template = 'json' })
      end, {
        desc = 'Log JSON (above)',
      })

      vim.keymap.set('n', 'gls', function()
        require('timber.actions').insert_log({
          templates = { before = 'default', after = 'default' },
          position = 'surround',
        })
      end, { desc = 'Log Surround' })

      vim.keymap.set('n', 'glf', function()
        return require('timber.buffers').open_float({ sort = 'newest_first' })
      end, { desc = 'Open log float' })

      vim.keymap.set('n', 'glc', function()
        return require('timber.actions').clear_log_statements({ global = false })
      end, {
        desc = 'Clear logs',
      })

      vim.keymap.set('n', 'glC', function()
        return require('timber.actions').clear_log_statements({ global = true })
      end, {
        desc = 'Clear logs (global)',
      })

      vim.keymap.set('n', 'gll', function()
        return require('timber.actions').insert_log({ position = 'below', operator = true }) .. '_'
      end, {
        desc = 'Line log statement',
        expr = true,
      })

      vim.keymap.set('n', 'glw', function()
        require('timber.actions').insert_log({ template = 'watcher', position = 'below' })
      end, { desc = 'Log watcher (JS)' })

      vim.keymap.set('n', 'glW', function()
        require('timber.actions').insert_log({ template = 'watcher', position = 'above' })
      end, { desc = 'Log watcher (JS)' })

      vim.keymap.set('n', 'glS', function()
        require('timber.summary').open({ focus = true })
      end, { desc = 'Log Summary' })

      vim.keymap.set('n', 'glt', function()
        require('timber.actions').search_log_statements()
      end, { desc = 'Search Logs (Telescope)' })
    end,
  },

  -- JSON/YAML Schemas definitions
  {
    'b0o/schemastore.nvim',
    ft = { 'json', 'yaml', 'yml' },
  },
}
