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

      -- Auto update imports on file/folder rename
      -- {
      --   'antosha417/nvim-lsp-file-operations',
      --   event = { 'BufReadPre', 'BufNewFile' },
      --   dependencies = {
      --     'nvim-lua/plenary.nvim',
      --     -- 'nvim-neo-tree/neo-tree.nvim',
      --     'stevearc/oil.nvim',
      --   },
      --   opts = {},
      -- },

      -- Useful status updates for LSP.
      {
        'j-hui/fidget.nvim',
        event = { 'BufReadPre', 'BufNewFile' },
        opts = {},
      },

      -- used for completion, annotations and signatures of Neovim apis
      {
        'folke/neodev.nvim',
        event = { 'BufReadPre', 'BufNewFile' },
        opts = {},
      },
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>cr', vim.lsp.buf.rename, '[R]ename Word')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
          map('K', vim.lsp.buf.hover, 'Hover Documentation')

          -- Keybinds are only enabled for tsserver files
          if vim.bo.filetype == 'typescript' or vim.bo.filetype == 'typescriptreact' then
            -- Organize imports
            map('<leader>co', '<cmd>OrganizeImports<cr>', '[O]rganize Imports')

            -- Go to source definition
            map('gD', '<cmd>GoToSourceDefintion<cr>', 'Go to Source [D]efinition')

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
          end

          -- Highlight references
          local client = vim.lsp.get_client_by_id(event.data.client_id)
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
                vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event.buf }
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

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- add border to hover and signature help
      local default_handlers = {
        ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' }),
        ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' }),
      }

      local servers = {
        tsserver = {
          root_dir = require('lspconfig.util').root_pattern 'package.json',
          single_file_support = true,
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
                vim.lsp.buf.execute_command {
                  command = '_typescript.goToSourceDefinition',
                  arguments = {
                    vim.api.nvim_buf_get_name(0),
                    vim.lsp.util.make_position_params().position,
                  },
                }
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
                      vim.notify('The file was not renamed. Please provide a target file.', 'info', { ttl = 5000 })
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
                    vim.notify('Imports updated! Use :wa to save the changes.', 'info', { ttl = 5000 })
                  end)
                end

                prompt_ts_rename()
              end,
              description = 'Rename File and Update Imports',
            },

            -- Remove Unused Imports
            RemoveUnusedImports = {
              function()
                vim.lsp.buf.code_action {
                  apply = true,
                  context = {
                    only = { 'source.removeUnused.ts' },
                    diagnostics = {},
                  },
                }
              end,
              description = 'Remove Unused Imports',
            },

            -- Sort Imports
            SortImports = {
              function()
                vim.lsp.buf.code_action {
                  apply = true,
                  context = {
                    only = { 'source.sortImports.ts' },
                    diagnostics = {},
                  },
                }
              end,
              description = 'Sort Imports',
            },

            -- Add Missing Imports
            AddMissingImports = {
              function()
                vim.lsp.buf.code_action {
                  apply = true,
                  context = {
                    only = { 'source.addMissingImports.ts' },
                    diagnostics = {},
                  },
                }
              end,
              description = 'Add Missing Imports',
            },
          },
          handlers = {
            ['workspace/executeCommand'] = function(_, result, ctx, _)
              if ctx.params.command == '_typescript.goToSourceDefinition' and result ~= nil and #result > 0 then
                -- wanna open in vsplit? Try and maybe change to buffer.
                vim.cmd 'vsplit'
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
              inlayHints = {
                includeInlayParameterNameHints = 'all', -- 'none' | 'literals' | 'all'
                includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                includeInlayVariableTypeHints = true,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHintsWhenTypeMatchesName = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = 'all', -- 'none' | 'literals' | 'all'
                includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                includeInlayVariableTypeHints = true,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHintsWhenTypeMatchesName = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
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
        tailwindcss = {},
        -- getting annoying completion suggestions because of this
        -- emmet_ls = {},
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
                globals = { 'vim' },
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
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            server.handlers = vim.tbl_deep_extend('force', default_handlers, server.handlers or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }

      require('lspconfig.ui.windows').default_options.border = 'rounded'

      vim.diagnostic.config {
        virtual_text = {
          source = false,
          severity = { min = vim.diagnostic.severity.WARN },
        },
        severity_sort = true,
        update_in_insert = true,
        underline = true,
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
      }
    end,
  },
  {
    'folke/trouble.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {},
    keys = {
      { '<leader>xx', '<cmd>TroubleToggle<cr>', desc = 'Trouble: Toggle' },
      { '<leader>xw', '<cmd>TroubleToggle workspace_diagnostics<cr>', desc = 'Trouble: Workspace Diagnostics' },
      { '<leader>xd', '<cmd>TroubleToggle document_diagnostics<cr>', desc = 'Trouble: document diagnostics' },
      { '<leader>xl', '<cmd>TroubleToggle loclist<cr>', desc = 'Trouble LocList' },
      { '<leader>xq', '<cmd>TroubleToggle quickfix<cr>', desc = 'Trouble: Quickfix' },
    },
  },
  {
    'dmmulroy/tsc.nvim',
    ft = { 'typescript', 'typescriptreact' },
    config = function()
      require('tsc').setup {
        use_trouble_qflist = true,
        auto_open_qflist = true,
        auto_focus_qflist = true,
        pretty_errors = true,
      }
    end,
  },
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
  {
    'rmagatti/goto-preview',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('goto-preview').setup {
        default_mappings = true,
      }
    end,
  },
}
