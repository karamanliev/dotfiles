return {
  {
    'folke/snacks.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      bigfile = {
        enabled = true,
        size = 0.8 * 1024 * 1024, -- 800 KB
        setup = function(ctx)
          if vim.fn.exists(':NoMatchParen') ~= 0 then
            vim.cmd([[NoMatchParen]])
          end
          if vim.fn.exists(':Gitsigns') ~= 0 then
            vim.cmd([[Gitsigns detach]])
          end
          Snacks.util.wo(0, { foldmethod = 'manual', statuscolumn = '', conceallevel = 0 })
          vim.b.minianimate_disable = true
          vim.schedule(function()
            if vim.api.nvim_buf_is_valid(ctx.buf) then
              vim.bo[ctx.buf].syntax = ctx.ft
            end
          end)
        end,
      },
      dashboard = { enabled = false },
      explorer = { replace_netrw = false },
      indent = {
        enabled = true,
        animate = {
          enabled = false,
        },
        chunk = {
          enabled = true,
          char = {
            arrow = '─',
          },
        },
        indent = {
          enabled = true,
          width = 2,
          char = '┊',
          hl = 'Whitespace',
        },
        scope = {
          enabled = false,
        },
      },
      input = {
        enabled = true,
        prompt_pos = false,
        icon_pos = false,
      },
      image = {
        enabled = true,
      },
      notifier = {
        enabled = false,
        timeout = 3000,
      },
      picker = {
        enabled = true,
        formatters = {
          file = {
            filename_first = true,
          },
        },
        win = {
          preview = {
            wo = {
              foldcolumn = '0',
              number = true,
              numberwidth = 4,
              relativenumber = false,
              signcolumn = 'no',
              statuscolumn = '',
            },
          },
        },
        previewers = {
          diff = {
            builtin = false,
            cmd = { 'delta' },
          },
        },
        layouts = {
          vertical = {
            layout = {
              box = 'horizontal',
              backdrop = false,
              width = 0.8,
              height = 0.8,
              border = 'none',
              {
                box = 'vertical',
                { win = 'input', height = 1, border = 'single', title = '{title} {live} {flags}', title_pos = 'center' },
                { win = 'list', title = '', title_pos = 'center', border = 'single' },
                { win = 'preview', title = '{preview:Preview}', height = 0.65, border = 'single', title_pos = 'center' },
              },
            },
          },
          select = {
            cycle = true,
            layout = {
              backdrop = false,
              width = 0.5,
              min_width = 80,
              height = 0.4,
              min_height = 3,
              box = 'vertical',
              border = 'single',
              title = '{title}',
              title_pos = 'center',
              { win = 'input', height = 1, border = 'none' },
              { win = 'list', border = 'none' },
              { win = 'preview', title = '{preview}', height = 0.4, border = 'top' },
            },
          },
        },
        layout = {
          layout = {
            backdrop = {
              bg = '#1e1e2e',
              blend = 25,
            },
          },
        },
        auto_confirm = true,
        ui_select = true,
      },
      quickfile = { enabled = true },
      scope = {
        enabled = true,
        cursor = true,
        keys = {
          textobject = {
            ii = {
              cursor = true,
            },
            ai = {
              cursor = true,
            },
          },
          jump = {
            ['[i'] = {
              cursor = true,
            },
            [']i'] = {
              cursor = true,
            },
          },
        },
      },
      scroll = { enabled = false },
      statuscolumn = {
        enabled = false,
        left = { 'git', 'sign' },
        right = { 'fold' },
      },
      words = { enabled = true },
      toggle = {
        which_key = false,
      },
      styles = {
        input = {
          border = 'single',
          relative = 'cursor',
          row = -4,
          col = 0,
          wo = {
            winhighlight = 'NormalFloat:Normal,FloatBorder:LineNr,FloatTitle:LineNr,FloatPrompt:LineNr',
          },
        },
      },
    },
    keys = {
      -- Top Pickers & Explorer
      {
        '<leader>fs',
        function()
          Snacks.picker({})
        end,
        desc = 'Snacks Pickers',
      },
      {
        '<leader>.',
        function()
          Snacks.picker.smart({
            hidden = true,
            filter = {
              cwd = true,
            },
          })
        end,
        desc = 'Smart Find Files',
      },
      {
        '<leader>.',
        function()
          vim.cmd('normal! "vy')
          local search_text = vim.fn.getreg('v'):gsub('^%s*(.-)%s*$', '%1')
          Snacks.picker.files({
            title = 'Find File (Visual)',
            hidden = true,
            search = search_text,
          })
        end,
        mode = 'v',
        desc = 'Find File (Visual)',
      },
      {
        '<leader><space>',
        function()
          Snacks.picker.buffers({
            layout = {
              cycle = true,
              preset = 'ivy',
              layout = {
                height = 0.25,
              },
              hidden = { 'preview' },
            },
            current = false,
            focus = 'list',
            win = {
              list = {
                keys = {
                  ['<c-x>'] = 'bufdelete',
                },
              },
            },
          })
        end,
        mode = { 'n', 'v' },
        desc = 'Buffers',
      },
      {
        '<leader>,',
        function()
          Snacks.picker.grep({
            hidden = true,
          })
        end,
        desc = 'Grep',
      },
      {
        '<leader>,',
        function()
          vim.cmd('normal! "vy')
          local search_text = vim.fn.getreg('v'):gsub('^%s*(.-)%s*$', '%1')
          Snacks.picker.grep({
            title = 'Grep (Visual)',
            search = search_text,
            hidden = true,
          })
        end,
        mode = 'v',
        desc = 'Grep (Visual)',
      },
      {
        '<leader>;',
        function()
          Snacks.picker.resume({})
        end,
        desc = 'Resume',
      },
      {
        '<leader>ff',
        function()
          Snacks.picker.files({
            hidden = true,
          })
        end,
        desc = 'Find Files',
      },
      {
        '<leader>fn',
        function()
          Snacks.picker.files({ cwd = vim.fn.stdpath('config') })
        end,
        desc = 'Find Config File',
      },
      {
        '<leader>fp',
        function()
          Snacks.picker.projects()
        end,
        desc = 'Projects',
      },
      {
        '<leader>>',
        function()
          Snacks.picker.recent()
        end,
        desc = 'Recent',
      },
      {
        '<leader><',
        function()
          Snacks.picker.grep_buffers()
        end,
        desc = 'Grep Open Buffers',
      },
      {
        '<leader>fg',
        function()
          Snacks.picker.git_status({
            cwd = vim.fn.expand('%:p:h'),
          })
        end,
        desc = 'Git Status',
      },
      {
        '<leader>/',
        function()
          Snacks.picker.lines()
        end,
        desc = 'Buffer Lines',
      },
      {
        '<leader>fw',
        function()
          Snacks.picker.grep_word()
        end,
        desc = 'Visual selection or word',
        mode = { 'n', 'x' },
      },
      {
        '<leader>"',
        function()
          Snacks.picker.registers({})
        end,
        desc = 'Registers',
      },
      {
        '<leader>fh',
        function()
          Snacks.picker.help()
        end,
        desc = 'Help Pages',
      },
      {
        '<leader>fk',
        function()
          Snacks.picker.keymaps()
        end,
        desc = 'Keymaps',
      },
      {
        '<leader>fm',
        function()
          Snacks.picker.marks()
        end,
        desc = 'Marks',
      },
      {
        '<leader>fu',
        function()
          Snacks.picker.undo({})
        end,
        desc = 'Undo History',
      },
      {
        '<leader>tt',
        function()
          Snacks.picker.colorschemes({
            focus = 'list',
            main = {
              current = true,
              file = true,
            },
            transform = function(item)
              local allowed = {
                'catppuccin-frappe',
                'catppuccin-macchiato',
                'catppuccin-mocha',
                'rose-pine-main',
                'rose-pine-moon',
                'poimandres',
                'kanagawa-paper-ink',
                'oldworld',
                'tokyonight-moon',
                'tokyonight-night',
                'tokyonight-storm',
              }

              if vim.tbl_contains(allowed, item.text) then
                return item
              end

              return false
            end,

            layout = {
              preset = 'sidebar',
              preview = 'main',
              layout = {
                position = 'right',
                width = 0.25,
              },
            },
            confirm = function(picker, item)
              picker:close()
              if item then
                picker.preview.state.colorscheme = nil
                vim.schedule(function()
                  vim.cmd('colorscheme ' .. item.text)
                  local colorscheme_path = vim.fn.stdpath('config') .. '/lua/custom/colorscheme.lua'
                  local lines = vim.fn.readfile(colorscheme_path)

                  for i, line in ipairs(lines) do
                    if line:match('vim%.cmd%.colorscheme%(.+%)') then
                      lines[i] = string.format("vim.cmd.colorscheme('%s')", item.text)
                      break
                    end
                  end

                  vim.fn.writefile(lines, colorscheme_path)
                  vim.fn.system('nvim-sync-colors.sh ' .. item.text)
                end)
              end
            end,
          })
        end,
        desc = 'Toggle Theme',
        mode = { 'n', 'v' },
      },
      {
        '<leader>E',
        function()
          Snacks.picker.explorer({
            auto_close = true,
            follow_file = true,
            hidden = true,
          })
        end,
        desc = 'Explorer',
      },
      {
        '<leader>ss',
        function()
          Snacks.scratch()
        end,
        desc = 'Toggle Scratch Buffer',
      },
      {
        '<leader>sS',
        function()
          Snacks.scratch.select()
        end,
        desc = 'Select Scratch Buffer',
      },
      {
        '<leader>gB',
        function()
          Snacks.gitbrowse()
        end,
        desc = 'Git Browse',
        mode = { 'n', 'v' },
      },

      {
        '<leader>gc',
        function()
          Snacks.terminal.open('git commit', {
            start_insert = true,
            auto_insert = true,
            auto_close = true,
            win = {
              position = 'bottom',
              height = 0.4,
              keys = {
                ['<C-c>'] = { 'hide', mode = { 'n', 'i', 't' } },
                ['ZQ'] = { 'hide', mode = { 'n', 'i', 't' } },
              },
            },
          })
        end,
        desc = 'Git Commit',
        mode = { 'n', 'v' },
      },
      {
        ']]',
        function()
          Snacks.words.jump(vim.v.count1, true)
        end,
        desc = 'Next Reference',
        mode = { 'n', 't' },
      },
      {
        '[[',
        function()
          Snacks.words.jump(-vim.v.count1, true)
        end,
        desc = 'Prev Reference',
        mode = { 'n', 't' },
      },
    },
    init = function()
      vim.api.nvim_create_autocmd('User', {
        pattern = 'OilActionsPost',
        callback = function(event)
          if event.data.actions.type == 'move' then
            Snacks.rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
          end
        end,
      })

      vim.api.nvim_create_autocmd('User', {
        pattern = 'VeryLazy',
        callback = function()
          -- Setup some globals for debugging (lazy-loaded)
          _G.dd = function(...)
            Snacks.debug.inspect(...)
          end
          _G.bt = function()
            Snacks.debug.backtrace()
          end

          -- Override print to use snacks for `:=` command
          if vim.fn.has('nvim-0.11') == 1 then
            vim._print = function(_, ...)
              dd(...)
            end
          else
            vim.print = _G.dd
          end
        end,
      })
    end,
  },
}
