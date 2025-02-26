-- LSP Configuration & Plugins
return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      {
        'williamboman/mason.nvim',
        cmd = {
          'Mason',
          'MasonLog',
          'MasonUpdate',
          'MasonInstall',
          'MasonUninstall',
          'MasonUninstallAll',
        },
        config = true,
      }, -- NOTE: Must be loaded before dependants
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
    },
    config = function()
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

          --[[ if vim.tbl_contains(ts_ft, vim.bo.filetype) and client and client.name == 'ts_ls' then
            -- NOTE: for tsserver
            -- Go to source definition
            map('gd', '<cmd>GoToSourceDefinition<cr>', 'Goto Source Definition')

            -- Open source definition in a vertical split
            map('gps', '<cmd>lua vim.cmd "vsplit" vim.cmd "GoToSourceDefinition"<cr>', 'Goto Source Definition (vsplit)')

            -- Organize imports
            map('<leader>co', '<cmd>OrganizeImports<cr>', 'Organize Imports')

            -- Remove unused imports
            map('<leader>cu', '<cmd>RemoveUnusedImports<cr>', 'Remove Unused Imports')

            -- Sort imports
            map('<leader>cs', '<cmd>SortImports<cr>', 'Sort Imports')

            -- Add missing imports
            map('<leader>ci', '<cmd>AddMissingImports<cr>', 'Add Missing Imports')

            -- Rename file and update imports
            map('<leader>cR', '<cmd>RenameFile<cr>', 'Rename File and Update Imports')

            -- TSC
            map('<leader>cT', '<cmd>TSC<cr>', 'Typecheck Project')
            map('<leader>ct', '<cmd>TSCOpen<cr>', 'TSC Panel Open')
          end ]]

          --[[ if vim.tbl_contains(ts_ft, vim.bo.filetype) and client and client.name == 'vtsls' then
            -- NOTE: Keybinds for vtsls
            -- Go to source definition
            map('gd', '<cmd>VtsExec goto_source_definition<cr>', 'Goto Source Definition')

            -- Open source definition in a vertical split
            map('gS', '<cmd>lua vim.cmd "vsplit" vim.cmd "VtsExec goto_source_definition"<cr>', 'Goto Source Definition (vsplit)')

            -- Organize imports
            map('<leader>co', '<cmd>VtsExec organize_imports<cr>', 'Organize Imports')

            -- Remove unused imports
            map('<leader>cu', '<cmd>VtsExec remove_unused_imports<cr>', 'Remove Unused Imports')

            -- Remove unused imports
            map('<leader>cU', '<cmd>VtsExec remove_unused<cr>', 'Remove Unused (Imports and Variables)')

            -- Sort imports
            map('<leader>cs', '<cmd>VtsExec sort_imports<cr>', 'Sort Imports')

            -- Add missing imports
            map('<leader>ci', '<cmd>VtsExec add_missing_imports<cr>', 'Add Missing Imports')

            -- Rename file and update imports
            map('<leader>cR', '<cmd>VtsExec rename_file<cr>', 'Rename File and Update Imports')

            -- Show File References
            map('<leader>cf', '<cmd>VtsExec file_references<cr>', 'Show File References')

            --  Fix ALL
            map('<leader>cF', '<cmd>VtsExec fix_all<cr>', 'Fix All')

            -- Select TS Version
            map('<leader>cv', '<cmd>VtsExec select_ts_version<cr>', 'Select TS Version')

            -- Source Actions (same as above)
            map('<leader>cS', '<cmd>VtsExec source_actions<cr>', 'Source Actions')
          end ]]

          if not vim.tbl_contains(ts_ft, vim.bo.filetype) then
            map('gd', require('telescope.builtin').lsp_definitions, 'Goto Definition')
          end

          -- map('gd', require('telescope.builtin').lsp_definitions, 'Goto Definition')
          map('gr', require('telescope.builtin').lsp_references, 'Goto References')
          map('gI', require('telescope.builtin').lsp_implementations, 'Goto Implementation')
          map('<leader>cd', require('telescope.builtin').lsp_type_definitions, 'Type Definition')
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, 'Document Symbols')
          map('<leader>cr', vim.lsp.buf.rename, 'Rename Word')
          map('<leader>cc', vim.lsp.buf.code_action, 'Code Action', { 'n', 'v' })
          -- map('<leader>cL', vim.lsp.codelens.refresh, 'CodeLens Refresh')
          -- map('<leader>cl', vim.lsp.codelens.run, 'CodeLens Run')
          -- map('K', function()
          --   local winid = require('ufo').peekFoldedLinesUnderCursor()
          --   if not winid then
          --     vim.lsp.buf.hover()
          --   end
          -- end, 'Hover Info / Fold Peek')
          map('K', vim.lsp.buf.hover, 'Hover Info')
          map('<C-s>', vim.lsp.buf.signature_help, 'Signature Help', { 'n', 'i' })

          -- Toggle inlay hints
          if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            map('<leader>th', function()
              ---@diagnostic disable-next-line: missing-parameter
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
            end, 'Toggle Inlay Hints')
          end

          -- Highlight references
          -- if client and client.server_capabilities.documentHighlightProvider then
          --   local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
          --   vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          --     buffer = event.buf,
          --     group = highlight_augroup,
          --     callback = vim.lsp.buf.document_highlight,
          --   })
          --
          --   vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          --     buffer = event.buf,
          --     group = highlight_augroup,
          --     callback = vim.lsp.buf.clear_references,
          --   })
          --
          --   vim.api.nvim_create_autocmd('LspDetach', {
          --     group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
          --     callback = function(event)
          --       vim.lsp.buf.clear_references()
          --       vim.api.nvim_clear_autocmds({ group = 'lsp-highlight', buffer = event.buf })
          --     end,
          --   })
          -- end
        end,
      })

      -- Enhance LSP capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      }

      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- add border to hover and signature help
      -- local default_handlers = {
      --   ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'single' }),
      --   ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'single' }),
      -- }

      local servers = {
        bashls = {
          filetypes = { 'sh', 'zsh' },
        },
        hyprls = {
          filetypes = { 'conf', 'hyprlang' },
        },
        intelephense = {
          filetypes = { 'php', 'blade' },
          settings = {
            intelephense = {
              filetypes = { 'php', 'blade' },
              files = {
                associations = { '*php', '*.blade.php' },
                maxSize = 5000000,
              },
              stubs = {
                'bcmath',
                'bz2',
                'calendar',
                'Core',
                'curl',
                'date',
                'dba',
                'dom',
                'enchant',
                'fileinfo',
                'filter',
                'ftp',
                'gd',
                'gettext',
                'hash',
                'iconv',
                'imap',
                'intl',
                'json',
                'ldap',
                'libxml',
                'mbstring',
                'mcrypt',
                'mysql',
                'mysqli',
                'password',
                'pcntl',
                'pcre',
                'PDO',
                'pdo_mysql',
                'Phar',
                'readline',
                'recode',
                'Reflection',
                'regex',
                'session',
                'SimpleXML',
                'soap',
                'sockets',
                'sodium',
                'SPL',
                'standard',
                'superglobals',
                'sysvsem',
                'sysvshm',
                'tokenizer',
                'xml',
                'xdebug',
                'xmlreader',
                'xmlwriter',
                'yaml',
                'zip',
                'zlib',
                'wordpress',
                'woocommerce',
                'acf-pro',
                'acf-stubs',
                'wordpress-globals',
                'wp-cli',
                'genesis',
                'polylang',
                'sbi',
              },
            },
          },
        },
        vtsls = {
          enabled = false,
          cmd = { 'vtsls', '--stdio' },
          filetypes = {
            'javascript',
            'javascriptreact',
            'javascript.jsx',
            'typescript',
            'typescriptreact',
            'typescript.tsx',
          },
          root_dir = function(fname)
            return require('lspconfig.util').root_pattern('tsconfig.json', 'jsconfig.json')(fname)
              or require('lspconfig.util').root_pattern('package.json', '.git')(fname)
          end,
          single_file_support = true,
          settings = {
            complete_function_calls = true,
            vtsls = {
              enableMoveToFileCodeAction = true,
              autoUseWorkspaceTsdk = true,
              experimental = {
                completion = {
                  enableServerSideFuzzyMatch = true,
                },
              },
            },
            typescript = {
              updateImportsOnFileMove = { enabled = 'always' },
              suggest = {
                completeFunctionCalls = true,
              },
              referencesCodeLens = {
                enabled = false,
                showOnAllFunctions = true,
              },
              implementationsCodeLens = {
                enabled = false,
                showOnInterfaceMethods = true,
              },
              inlayHints = {
                enumMemberValues = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                parameterNames = { enabled = 'literals' },
                parameterTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                variableTypes = { enabled = false },
              },
            },
            javascript = {
              updateImportsOnFileMove = { enabled = 'always' },
              suggest = {
                completeFunctionCalls = true,
              },
              inlayHints = {
                enumMemberValues = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                parameterNames = { enabled = 'literals' },
                parameterTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                variableTypes = { enabled = false },
              },
            },
          },
          on_attach = function(client, _)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end,
        },
        eslint = {
          enabled = false,
          settings = {
            workingDirectories = { mode = 'auto' },
            rulesCustomizations = {
              { rule = 'prettier/prettier', severity = 'off' },
              { rule = '@typescript-eslint/no-unused-vars', severity = 'off' },
            },
            format = false,
          },
        },
        ts_ls = {
          enabled = false,
          commands = {
            -- Organize Imports
            OrganizeImports = {
              function()
                local params = {
                  command = '_typescript.organizeImports',
                  arguments = { vim.api.nvim_buf_get_name(0) },
                  title = '',
                }
                vim.lsp.buf.execute_command(params)
              end,
              description = 'Organize Imports',
            },

            -- Go to Source Definition
            GoToSourceDefinition = {
              function()
                vim.lsp.buf.execute_command({
                  command = '_typescript.goToSourceDefinition',
                  arguments = {
                    vim.api.nvim_buf_get_name(0),
                    vim.lsp.util.make_position_params().position,
                  },
                })
              end,
              description = 'Go to Source Definition',
            },

            RenameFile = {
              function()
                local function prompt_ts_rename(prompt_path)
                  local source_file = prompt_path or vim.api.nvim_buf_get_name(0)
                  local target_file

                  vim.ui.input({
                    prompt = 'Target : ',
                    completion = 'file',
                    default = source_file,
                  }, function(input)
                    if not input or input == '' then
                      vim.notify('The file was not renamed. Please provide a target file.', vim.log.levels.INFO, { ttl = 5000 })
                      return
                    end
                    target_file = input
                    local params = {
                      command = '_typescript.applyRenameFile',
                      arguments = {
                        {
                          sourceUri = source_file,
                          targetUri = target_file,
                        },
                      },
                      title = '',
                    }

                    vim.lsp.util.rename(source_file, target_file)
                    vim.lsp.buf.execute_command(params)
                    vim.notify('Imports updated! Use :wa to save the changes.', vim.log.levels.INFO, { ttl = 5000 })
                  end)
                end

                prompt_ts_rename()
              end,
              description = 'Rename File and Update Imports',
            },

            -- Remove Unused Imports
            RemoveUnusedImports = {
              function()
                vim.lsp.buf.code_action({
                  apply = true,
                  context = {
                    ---@diagnostic disable-next-line: assign-type-mismatch
                    only = { 'source.removeUnused.ts' },
                    diagnostics = {},
                  },
                })
              end,
              description = 'Remove Unused Imports',
            },

            -- Sort Imports
            SortImports = {
              function()
                vim.lsp.buf.code_action({
                  apply = true,
                  context = {
                    ---@diagnostic disable-next-line: assign-type-mismatch
                    only = { 'source.sortImports.ts' },
                    diagnostics = {},
                  },
                })
              end,
              description = 'Sort Imports',
            },

            -- Add Missing Imports
            AddMissingImports = {
              function()
                vim.lsp.buf.code_action({
                  apply = true,
                  context = {
                    ---@diagnostic disable-next-line: assign-type-mismatch
                    only = { 'source.addMissingImports.ts' },
                    diagnostics = {},
                  },
                })
              end,
              description = 'Add Missing Imports',
            },
          },
          handlers = {
            ['workspace/executeCommand'] = function(_, result, ctx, _)
              if ctx.params.command == '_typescript.goToSourceDefinition' and result ~= nil and #result > 0 then
                -- wanna open in vsplit? Try and maybe change to buffer.
                -- vim.cmd 'vsplit'
                vim.lsp.util.jump_to_location(result[1], 'utf-8')
              end
            end,
            -- add ts-error-translator to diagnostics
            -- ['textDocument/publishDiagnostics'] = function(err, result, ctx, config)
            --   require('ts-error-translator').translate_diagnostics(err, result, ctx, config)
            --   vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
            --     virtual_text = {
            --       spacing = 4,
            --     },
            --   })(err, result, ctx, config)
            -- end,
          },
          settings = {
            typescript = {
              format = {
                enable = false,
              },
              updateImportsOnFileMove = {
                enabled = 'always',
              },
              workspace = {
                didChangeWatchedFiles = {
                  dynamicRegistration = true,
                },
              },
              inlayHints = {
                includeInlayParameterNameHints = 'literal', -- 'none' | 'literals' | 'all'
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayVariableTypeHints = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHintsWhenTypeMatchesName = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
            javascript = {
              format = {
                enable = false,
              },
              updateImportsOnFileMove = {
                enabled = 'always',
              },
              workspace = {
                didChangeWatchedFiles = {
                  dynamicRegistration = true,
                },
              },
              inlayHints = {
                includeInlayParameterNameHints = 'literal', -- 'none' | 'literals' | 'all'
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayVariableTypeHints = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHintsWhenTypeMatchesName = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
            flags = {
              allow_incremental_sync = false,
            },
            completions = {
              completeFunctionCalls = true,
            },
            diagnostics = {
              ignoredCodes = {},
            },
          },
        },
        html = {},
        cssls = {},
        graphql = {},
        tailwindcss = {
          -- TODO: find a way to have multiple hovers working with MEGA hover
          -- on_attach = function(client)
          --   client.server_capabilities.hoverProvider = false
          -- end,
          root_dir = function(fname)
            local root_pattern = require('lspconfig').util.root_pattern('tailwind.config.cjs', 'tailwind.config.js', 'postcss.config.js', 'tailwind.config.mjs')
            return root_pattern(fname)
          end,
        },
        emmet_language_server = {
          enabled = false,
          filetypes = { 'html', 'css', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'php' },
        },
        jsonls = {
          settings = {
            json = {
              filetypes = { 'json' },
              schemas = require('schemastore').json.schemas({}),
              validate = { enable = true },
            },
          },
        },
        yamlls = {
          filetypes = { 'yaml' },
          settings = {
            yaml = {
              filetypes = { 'yaml', 'yml' },
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
              completion = {
                callSnippet = 'Replace',
              },
              -- fix undefined global variables and unused variables diagnostics
              diagnostics = {
                disable = { 'missing-fields' },
                -- globals = { 'vim' },
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

      require('mason').setup()

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
        'prettierd', -- Used to format JavaScript, TypeScript, CSS, HTML, JSON, etc.
        'stylelint', -- Used to lint CSS
        'eslint_d', -- Used to lint JavaScript and TypeScript
        -- 'htmlhint', -- Used to lint HTML
        -- 'jsonlint', -- Used to lint JSON
        -- 'js-debug-adapters', -- Used to debug JavaScript and TypeScript
        'shfmt', -- Used to format shell scripts
      })
      require('mason-tool-installer').setup({ ensure_installed = ensure_installed })

      require('mason-lspconfig').setup({
        handlers = {
          function(server_name)
            local disabled_servers = { 'ts_ls', 'vtsls', 'esling', 'emmet_language_server' }
            if vim.tbl_contains(disabled_servers, server_name) then
              return
            end

            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            -- server.handlers = vim.tbl_deep_extend('force', default_handlers, server.handlers or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      })

      -- Vtsls Codelens
      -- vim.lsp.commands['editor.action.showReferences'] = function(command, ctx)
      --   local locations = command.arguments[3]
      --   local client = vim.lsp.get_client_by_id(ctx.client_id)
      --   if client and locations and #locations > 0 then
      --     local items = vim.lsp.util.locations_to_items(locations, client.offset_encoding)
      --     vim.fn.setloclist(0, {}, ' ', { title = 'References', items = items, context = ctx })
      --     vim.api.nvim_command('lopen')
      --   end
      -- end

      require('lspconfig.ui.windows').default_options.border = 'single'

      vim.diagnostic.config({
        virtual_text = false,
        underline = true,
        severity_sort = true,
        update_in_insert = true,
        float = {
          source = true,
          border = 'single',
          severity_sort = true,
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = '■',
            [vim.diagnostic.severity.WARN] = '■',
            [vim.diagnostic.severity.HINT] = '■',
            [vim.diagnostic.severity.INFO] = '■',
          },
        },
      })
    end,
  },

  -- vtsls extras
  {
    'yioneko/nvim-vtsls',
    enabled = false,
    ft = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx' },
    config = function()
      require('vtsls').config({
        -- customize handlers for commands
        -- handlers = {
        --   source_definition = function(err, locations) end,
        --   file_references = function(err, locations) end,
        --   code_action = function(err, actions) end,
        -- },
        -- automatically trigger renaming of extracted symbol
        refactor_auto_rename = true,
        -- refactor_move_to_file = {
        --   -- If dressing.nvim is installed, telescope will be used for selection prompt. Use this to customize
        --   -- the opts for telescope picker.
        --   telescope_opts = function(items, default) end,
        -- },
      })

      -- Opens trouble instead of qflist when multiple source definitions
      -- vim.api.nvim_create_autocmd('BufRead', {
      --   callback = function(ev)
      --     if vim.bo[ev.buf].buftype == 'quickfix' then
      --       vim.schedule(function()
      --         vim.cmd([[cclose]])
      --         vim.cmd([[Trouble qflist open]])
      --       end)
      --     end
      --   end,
      -- })
    end,
  },

  -- ts-tools
  {
    'pmizio/typescript-tools.nvim',
    ft = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx' },
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    keys = {
      { 'gd', '<cmd>TSToolsGoToSourceDefinition<cr>', desc = 'Goto Source Definition' },
      { 'gS', ' <cmd>lua vim.cmd "vsplit" vim.cmd "TSToolsGoToSourceDefinition"<cr>', desc = 'Goto Source Definition (vsplit)' },
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
          -- spawn additional tsserver instance to calculate diagnostics on it
          separate_diagnostic_server = true,
          -- "change"|"insert_leave" determine when the client asks the server about diagnostic
          publish_diagnostic_on = 'change',
          -- array of strings("fix_all"|"add_missing_imports"|"remove_unused"|
          -- "remove_unused_imports"|"organize_imports") -- or string "all"
          -- to include all supported code actions
          -- specify commands exposed as code_actions
          expose_as_code_action = {},
          -- string|nil - specify a custom path to `tsserver.js` file, if this is nil or file under path
          -- not exists then standard path resolution strategy is applied
          tsserver_path = nil,
          -- specify a list of plugins to load by tsserver, e.g., for support `styled-components`
          -- (see 💅 `styled-components` support section)
          tsserver_plugins = {
            '@styled/typescript-styled-plugin',
          },
          -- this value is passed to: https://nodejs.org/api/cli.html#--max-old-space-sizesize-in-megabytes
          -- memory limit in megabytes or "auto"(basically no limit)
          tsserver_max_memory = 'auto',
          -- described below
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
          -- locale of all tsserver messages, supported locales you can find here:
          -- https://github.com/microsoft/TypeScript/blob/3c221fc086be52b19801f6e8d82596d04607ede6/src/compiler/utilitiesPublic.ts#L620
          tsserver_locale = 'en',
          -- mirror of VSCode's `typescript.suggest.completeFunctionCalls`
          complete_function_calls = true,
          include_completions_with_insert_text = true,
          -- CodeLens
          -- WARNING: Experimental feature also in VSCode, because it might hit performance of server.
          -- possible values: ("off"|"all"|"implementations_only"|"references_only")
          code_lens = 'off',
          -- by default code lenses are displayed on all referencable values and for some of you it can
          -- be too much this option reduce count of them by removing member references from lenses
          disable_member_code_lens = true,
          -- JSXCloseTag
          -- WARNING: it is disabled by default (maybe you configuration or distro already uses nvim-ts-autotag,
          -- that maybe have a conflict if enable this feature. )
          jsx_close_tag = {
            enable = false,
            filetypes = { 'javascriptreact', 'typescriptreact' },
          },
        },
      })
    end,
  },

  -- pretty diagnostic virtual text
  {
    'rachartier/tiny-inline-diagnostic.nvim',
    event = 'LspAttach',
    priority = 1000,
    keys = {
      {
        '<leader>td',
        function()
          require('tiny-inline-diagnostic').toggle()
        end,
        desc = 'Toggle Tiny Inline Diagnostic',
      },
    },
    config = function()
      local bg = require('utils.misc').get_bg_color()

      require('tiny-inline-diagnostic').setup({
        signs = {
          -- left = '█',
          left = '',
          -- right = '█',
          right = '',
          diag = ' ■',
          arrow = '    ',
          up_arrow = '    ',
          vertical = ' │',
          vertical_end = ' └',
        },
        hi = {
          error = 'DiagnosticError',
          warn = 'DiagnosticWarn',
          info = 'DiagnosticInfo',
          hint = 'DiagnosticHint',
          arrow = 'NonText',
          background = 'CursorLine', -- Can be a highlight or a hexadecimal color (#RRGGBB)
          mixing_color = bg,
        },
        blend = {
          factor = 0.1,
        },
        options = {
          show_source = true,
          throttle = 20,
          softwrap = 15,
          multiple_diag_under_cursor = false,
          multilines = false,
          show_all_diags_on_cursorline = false,
          enable_on_insert = false,

          overflow = {
            mode = 'wrap',
          },
          format = nil,

          --- Enable it if you want to always have message with `after` characters length.
          break_line = {
            enabled = false,
            after = 30,
          },

          virt_texts = {
            priority = 10000,
          },

          severity = {
            vim.diagnostic.severity.ERROR,
            vim.diagnostic.severity.WARN,
            vim.diagnostic.severity.INFO,
            vim.diagnostic.severity.HINT,
          },
        },
      })
    end,
  },

  -- Show diagnostics in a panel
  {
    'folke/trouble.nvim',
    enabled = false,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    cmd = {
      'Trouble',
      'TroubleToggle',
    },
    keys = {
      -- { '<leader>xx', '<cmd>TroubleToggle<cr>', desc = 'Trouble: Toggle' },
      { '<leader>qD', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics (workspace)' },
      { '<leader>ql', '<cmd>Trouble lsp toggle focus=true win.position=right<cr>', desc = 'LSP stuff' },
      { '<leader>qd', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Diagnostics (buffer)' },
      { '<leader>qL', '<cmd>Trouble loclist toggle<cr>', desc = 'LocList' },
      { '<leader>qq', '<cmd>Trouble quickfix toggle<cr>', desc = 'Quickfix' },
      { '<leader>qt', '<cmd>Trouble todo toggle focus=true win.position=right<cr>', desc = 'Todo' },
      { '<leader>qs', '<cmd>Trouble lsp_document_symbols toggle focus=false win.position=right<cr>', desc = 'Symbols' },
      { '<leader>qf', '<cmd>Trouble telescope_files toggle focus=true<cr>', desc = 'Telescope Files' },
      { '<leader>qF', '<cmd>Trouble telescope toggle focus=true<cr>', desc = 'Telescope' },
      { ']q', '<cmd>Trouble next jump=true skip_groups=true<cr>', desc = 'Next Trouble' },
      { '[q', '<cmd>Trouble prev jump=true skip_groups=true<cr>', desc = 'Previous Trouble' },
    },
    config = function()
      local open_with_trouble = require('trouble.sources.telescope').open
      local add_to_trouble = require('trouble.sources.telescope').add

      require('trouble').setup({
        win = {
          size = {
            width = 50,
            height = 10,
          },
        },
      })

      require('telescope').setup({
        defaults = {
          keymaps = {
            i = {
              ['<c-q>'] = open_with_trouble,
              ['<m-q>'] = add_to_trouble,
            },
            n = {
              ['<c-q>'] = open_with_trouble,
              ['<m-q>'] = add_to_trouble,
            },
          },
        },
      })
    end,
  },

  -- used for completion, annotations and signatures of Neovim apis
  {
    'folke/lazydev.nvim',
    ft = { 'lua' },
    dependencies = {
      'Bilal2453/luvit-meta',
    },
    opts = {
      library = {
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
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
    enabled = true,
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
