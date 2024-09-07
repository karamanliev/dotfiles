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
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Keybinds are only enabled for tsserver files
          --[[ -- NOTE: for some reason `if client.name == 'tsserver'` doesn't work well and <gd> gets reasigned to default go_to_definition instead
          local ts_ft = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx' }

          if vim.tbl_contains(ts_ft, vim.bo.filetype) then
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
          else
            map('gd', require('telescope.builtin').lsp_definitions, 'Goto Definition')
          end ]]

          local ts_ft = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx' }
          if vim.tbl_contains(ts_ft, vim.bo.filetype) then
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
          else
            map('gd', require('telescope.builtin').lsp_definitions, 'Goto Definition')
          end

          -- map('gd', require('telescope.builtin').lsp_definitions, 'Goto Definition')
          map('gr', require('telescope.builtin').lsp_references, 'Goto References')
          map('gI', require('telescope.builtin').lsp_implementations, 'Goto Implementation')
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type Definition')
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, 'Document Symbols')
          map('<leader>cr', vim.lsp.buf.rename, 'Rename Word')
          map('<leader>ca', vim.lsp.buf.code_action, 'Code Action')
          map('<leader>cL', vim.lsp.codelens.refresh, 'CodeLens Refresh')
          map('<leader>cl', vim.lsp.codelens.run, 'CodeLens Run')
          vim.keymap.set('v', '<leader>c', vim.lsp.buf.code_action, { desc = 'Code Action' })
          map('K', vim.lsp.buf.hover, 'Hover Info')

          -- Mega K hover info: if no hover info is available, show git hunk preview, if folded show fold preview
          --[[ map('K', function()
            -- TODO: having multiple clients attached to a buffer, this will not work as expected
            -- for example, if both tsserver and tailwindcss are attached it will not work
            -- because tsserver will have result and tailwindcss will not
            -- https://www.reddit.com/r/neovim/comments/170ykc0/tailwind_lsp_hover_documentation_multiple_lsps/
            -- -- Function to check if any predefined clients are attached and only then show hover info
            -- local function is_accepted_client()
            --   -- Define the list of predefined LSP clients
            --   local accepted_clients = {
            --     'tsserver',
            --     'lua_ls',
            --   }
            --
            --   for _, client_name in pairs(accepted_clients) do
            --     local clients = vim.lsp.get_clients({ bufnr = 0, name = client_name })
            --     if clients and #clients > 0 then
            --       return true
            --     end
            --   end
            --
            --   return false
            -- end

            local previewFold = require('ufo').peekFoldedLinesUnderCursor()
            local gitsigns = require('gitsigns')
            local params = vim.lsp.util.make_position_params()

            if not previewFold then
              vim.lsp.buf_request(0, 'textDocument/hover', params, function(_, result, _, _)
                -- Check if hover value returns number followed by a space and then "byte" or "bytes"
                -- this prevents showing hover info for byte values in the code
                local pattern = '%d%s+byte[s]*'
                local isRealHoverInfo = result and result.contents and not string.match(result.contents.value, pattern)

                if isRealHoverInfo then
                  vim.lsp.buf.hover()
                else
                  local previewHunk = gitsigns.preview_hunk()
                  if not previewHunk then
                    vim.notify('No hover info available!', vim.log.levels.INFO)
                  end
                end
              end)
            end
          end, 'Mega Hover') ]]

          -- Highlight references
          --[[ if client and client.server_capabilities.documentHighlightProvider then
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
              callback = function(event)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = 'lsp-highlight', buffer = event.buf })
              end,
            })
          end ]]

          -- Toggle inlay hints
          if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            map('<leader>th', function()
              ---@diagnostic disable-next-line: missing-parameter
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
            end, 'Toggle Inlay Hints')
          end
        end,
      })

      -- Enhance LSP capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- add border to hover and signature help
      local default_handlers = {
        ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' }),
        ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' }),
      }

      require('lspconfig.configs').vtsls = require('vtsls').lspconfig

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
        },
        --[[ tsserver = {
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
        }, ]]
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
        jsonls = {},
        yamlls = {
          capabilities = {
            textDocument = {
              foldingRange = {
                dynamicRegistration = false,
                lineFoldingOnly = true,
              },
            },
          },
          filetypes = { 'yaml' },
          settings = {
            yaml = {
              format = {
                enable = true,
              },
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
        'eslint_d', -- Used to lint JavaScript and TypeScript
        'htmlhint', -- Used to lint HTML
        'jsonlint', -- Used to lint JSON
        -- 'js-debug-adapters', -- Used to debug JavaScript and TypeScript
        'shfmt', -- Used to format shell scripts
      })
      require('mason-tool-installer').setup({ ensure_installed = ensure_installed })

      require('mason-lspconfig').setup({
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            server.handlers = vim.tbl_deep_extend('force', default_handlers, server.handlers or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      })

      -- Vtsls Codelens
      vim.lsp.commands['editor.action.showReferences'] = function(command, ctx)
        local locations = command.arguments[3]
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        if locations and #locations > 0 then
          local items = vim.lsp.util.locations_to_items(locations, client.offset_encoding)
          vim.fn.setloclist(0, {}, ' ', { title = 'References', items = items, context = ctx })
          vim.api.nvim_command('lopen')
        end
      end

      require('lspconfig.ui.windows').default_options.border = 'rounded'

      vim.diagnostic.config({
        virtual_text = false,
        underline = true,
        severity_sort = true,
        update_in_insert = false,
        float = {
          source = true,
          border = 'rounded',
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
    end,
  },

  -- pretty diagnostic virtual text
  {
    'rachartier/tiny-inline-diagnostic.nvim',
    event = { 'VeryLazy' },
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
      local colors = require('tokyonight.colors').setup()

      require('tiny-inline-diagnostic').setup({
        signs = {
          left = '█',
          right = '█',
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
          mixing_color = colors.bg, -- Can be None or a hexadecimal color (#RRGGBB). Used to blend the background color with the diagnostic background color with another color.
        },
        blend = {
          factor = 0.1,
        },
        options = {
          show_source = false,
          throttle = 20,
          softwrap = 15,

          overflow = {
            mode = 'wrap',
          },

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

      vim.cmd('hi TinyInlineDiagnosticVirtualTextArrow guifg=' .. colors.fg_dark)
    end,
  },

  -- Show diagnostics in a panel
  {
    'folke/trouble.nvim',
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
      { ']q', '<cmd>Trouble next jump=true skip_groups=true<cr>', desc = 'Next Trouble' },
      { '[q', '<cmd>Trouble prev jump=true skip_groups=true<cr>', desc = 'Previous Trouble' },
    },
    config = function()
      require('trouble').setup({
        win = {
          size = {
            width = 50,
            height = 10,
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
        use_trouble_qflist = true,
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

  -- Illuminate the current word under the cursor
  {
    'RRethy/vim-illuminate',
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
}
