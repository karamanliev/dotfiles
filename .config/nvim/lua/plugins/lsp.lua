-- LSP Configuration & Plugins
return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
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

          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>cr', vim.lsp.buf.rename, '[R]ename Word')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

          -- Mega K hover info: if no hover info is available, show git hunk preview, if folded show fold preview
          map('K', function()
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
          end, 'Mega Hover')

          -- Keybinds are only enabled for tsserver files
          if client and (client.name == 'tsserver' or client.name == 'vtsls') then
            -- Go to source definition
            map('gd', '<cmd>GoToSourceDefintion<cr>', '[G]oto Source [D]efinition')
            -- how to add vsplit here
            map('gps', '<cmd>lua vim.cmd "vsplit" vim.cmd "GoToSourceDefintion"<cr>', '[G]oto Source [D]efinition (vsplit)')

            -- Organize imports
            map('<leader>co', '<cmd>OrganizeImports<cr>', '[O]rganize Imports')

            -- Remove unused imports
            map('<leader>cu', '<cmd>RemoveUnusedImports<cr>', 'Remove [U]nused Imports')

            -- Sort imports
            map('<leader>cs', '<cmd>SortImports<cr>', '[S]ort Imports')

            -- Add missing imports
            map('<leader>ci', '<cmd>AddMissingImports<cr>', '[A]dd Missing Imports')

            -- Rename file and update imports
            map('<leader>cf', '<cmd>RenameFile<cr>', 'Rename [F]ile and Update Imports')

            -- TSC
            map('<leader>ct', '<cmd>TSC<cr>', '[T]ypecheck Project')
            map('<leader>xt', '<cmd>TSCOpen<cr>', '[T]SC Panel Open')
          else
            map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          end

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
              callback = function(event)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = 'lsp-highlight', buffer = event.buf })
              end,
            })
          end

          -- Toggle inlay hints
          if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            map('<leader>th', function()
              ---@diagnostic disable-next-line: missing-parameter
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
            end, '[T]oggle Inlay [H]ints')
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

      local servers = {
        bashls = {
          filetypes = { 'sh', 'zsh' },
        },
        tsserver = {
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
            GoToSourceDefintion = {
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
            local root_pattern = require('lspconfig').util.root_pattern('tailwind.config.cjs', 'tailwind.config.js', 'postcss.config.js')
            return root_pattern(fname)
          end,
        },
        eslint_d = {
          settings = {
            -- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
            workingDirectories = { mode = 'auto' },
          },
        },
        emmet_language_server = {
          filetypes = { 'html', 'css', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
        },
        jsonls = {},
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
      }

      require('mason').setup()

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
        'prettierd', -- Used to format JavaScript, TypeScript, CSS, HTML, JSON, etc.
        'eslint_d', -- Used to lint JavaScript and TypeScript
        'stylelint', -- Used to lint CSS
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

      require('lspconfig.ui.windows').default_options.border = 'rounded'

      vim.diagnostic.config({
        virtual_text = vim.g.virtual_text,
        severity_sort = true,
        update_in_insert = true,
        float = {
          source = true,
          border = 'rounded',
          severity_sort = true,
        },
        -- signs = {
        --   text = {
        --     [vim.diagnostic.severity.ERROR] = '󰅚 ',
        --     [vim.diagnostic.severity.WARN] = '󰀪 ',
        --     [vim.diagnostic.severity.HINT] = '󰌶 ',
        --     [vim.diagnostic.severity.INFO] = '󰋽 ',
        --   },
        -- },
      })
    end,
  },

  -- Show diagnostics in a panel
  {
    'folke/trouble.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {},
    keys = {
      -- { '<leader>xx', '<cmd>TroubleToggle<cr>', desc = 'Trouble: Toggle' },
      { '<leader>lD', '<cmd>Trouble diagnostics toggle<cr>', desc = 'List [D]iagnostics (workspace)' },
      { '<leader>ld', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'List [D]iagnostics (buffer)' },
      { '<leader>lL', '<cmd>Trouble loclist toggle<cr>', desc = 'List [L]ocList' },
      { '<leader>lq', '<cmd>Trouble quickfix toggle<cr>', desc = 'List [Q]uickfix' },
      { '<leader>lt', '<cmd>Trouble todo toggle focus=true win.position=right<cr>', desc = 'List [T]odo' },
      { '<leader>ls', '<cmd>Trouble lsp_document_symbols toggle focus=false win.position=right<cr>', desc = 'List [S]ymbols' },
      { ']t', '<cmd>Trouble next jump=true skip_groups=true<cr>', desc = 'Next Trouble' },
      { '[t', '<cmd>Trouble prev jump=true skip_groups=true<cr>', desc = 'Previous Trouble' },
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
    event = { 'BufReadPre', 'BufNewFile' },
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
}
