-- LSP Configuration & Plugins
return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      -- Remove default nvim 0.11 lsp mappings
      vim.keymap.del('n', 'gra') -- code actions
      vim.keymap.del('n', 'gri') -- goto implementation
      vim.keymap.del('n', 'grn') -- rename
      vim.keymap.del('n', 'grr') -- goto references
      vim.keymap.del('n', 'grt') -- goto type definition

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            vim.keymap.set(mode and mode or 'n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Keybinds are only enabled for ts files
          local ts_ft = {
            'javascript',
            'javascriptreact',
            'javascript.jsx',
            'typescript',
            'typescriptreact',
            'typescript.tsx',
          }

          if not vim.tbl_contains(ts_ft, vim.bo.filetype) then
            map('gd', require('snacks.picker').lsp_definitions, 'Goto Definition')
          end

          map('gr', require('snacks.picker').lsp_references, 'Goto References')
          map('<leader>ca', vim.lsp.buf.code_action, 'Code Action', { 'n', 'v' })
          map('<leader>ci', require('snacks.picker').lsp_implementations, 'Goto Implementation')
          map('<leader>cd', require('snacks.picker').lsp_declarations, 'Goto Declaration')
          map('<leader>ct', require('snacks.picker').lsp_type_definitions, 'Goto Type Definition')
          map('<leader>cn', vim.lsp.buf.rename, 'Rename Word')

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
          --     callback = function(evt)
          --       vim.lsp.buf.clear_references()
          --       vim.api.nvim_clear_autocmds({ group = 'lsp-highlight', buffer = evt.buf })
          --     end,
          --   })
          -- end
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
        jsonls = {},
        yamlls = {},
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
        tailwindcss = {},
        astro = {},
        vtsls = {
          on_attach = function(client, bufnr)
            local map = function(keys, func, desc)
              vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'TS: ' .. desc })
            end
            local execute = require('utils.lsp').execute
            local action = require('utils.lsp').action

            map('gd', function()
              local params = vim.lsp.util.make_position_params(0, client.offset_encoding)

              execute({
                command = 'typescript.goToSourceDefinition',
                arguments = { params.textDocument.uri, params.position },
                open = true,
              })
            end, 'Goto Source Definition')
            map('<leader>cf', function()
              execute({
                command = 'typescript.findAllFileReferences',
                arguments = { vim.uri_from_bufnr(0) },
                open = 'always',
              })
            end, 'File References')
            map('<leader>co', function()
              execute({
                command = 'typescript.organizeImports',
                arguments = { vim.api.nvim_buf_get_name(0) },
              })
            end, 'Organize Imports')
            map('<leader>cm', action['source.addMissingImports.ts'], 'Add missing imports')
            map('<leader>cu', action['source.removeUnused.ts'], 'Remove unused imports')
            map('<leader>cv', function()
              execute({ command = 'typescript.selectTypeScriptVersion' })
            end, 'Select TS workspace version')
          end,
          settings = {
            complete_function_calls = true,
            vtsls = {
              enableMoveToFileCodeAction = true,
              autoUseWorkspaceTsdk = true,
              experimental = {
                maxInlayHintLength = 30,
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
    cmd = {
      'Mason',
      'MasonInstall',
      'MasonLog',
      'MasonUninstall',
      'MasonUninstallAll',
      'MasonUpdate',
    },
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {},
  },

  -- Show definitions in a popup
  {
    'rmagatti/goto-preview',
    enabled = false,
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
    enabled = false,
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
    enabled = false,
    ft = { 'json', 'yaml', 'yml' },
  },
}
