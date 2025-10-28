return {
  -- AI completion
  {
    'supermaven-inc/supermaven-nvim',
    enabled = true,
    event = 'InsertEnter',
    config = function()
      require('supermaven-nvim').setup({
        keymaps = {
          accept_suggestion = '<C-l>',
          clear_suggestion = '<C-c>',
          accept_word = '<C-j>',
        },
        ignore_filetypes = { cpp = true }, -- or { "cpp", }
        -- color = {
        --   suggestion_color = "#FFFFFF",
        --   cterm = 244,
        -- },
        log_level = 'off',
        disable_inline_completion = false,
        disable_keymaps = false,
        condition = function()
          local filename = vim.fn.expand('%:t')
          local fullpath = vim.fn.expand('%:p')
          return string.match(filename, 'obsidian') or string.match(fullpath, 'obsidian')
        end,
      })
    end,
  },
  -- Claude Code
  {
    'coder/claudecode.nvim',
    enabled = false,
    cmd = {
      'ClaudeCode',
      'ClaudeCodeAdd',
      'ClaudeCodeSend',
    },
    opts = {
      focus_after_send = true,
      terminal = {
        provider = 'external',
        provider_opts = {
          external_terminal_cmd = function(cmd)
            -- Check if Claude is already running in any pane of the current window
            local check_claude = os.execute("tmux list-panes -F '#{pane_current_command}' | grep -q claude")
            if check_claude == 0 then
              local pane_id = vim.fn.system('tmux list-panes -F "#{pane_id}:#{pane_current_command}" | grep claude | cut -d: -f1'):gsub('\n', '')
              return 'tmux select-pane -t ' .. pane_id
            end

            local cols = vim.o.columns
            local lines = vim.o.lines
            local split_cmd = cols / math.max(lines, 1) >= 1.2 and 'tmux splitw -l 35% -d ' or 'tmux splitw -h -l 45% -d '

            return split_cmd .. cmd
          end,
        },
      },
      diff_opts = {
        layout = 'horizontal',
        open_in_current_tab = true,
        keep_terminal_focus = false,
      },
    },
    keys = {
      { '<leader>an', '<cmd>ClaudeCode<cr>', desc = 'Toggle Claude', mode = { 'n', 'v' } },
      { '<leader>ar', '<cmd>ClaudeCode --resume<cr>', desc = 'Resume Claude' },
      { '<leader>ac', '<cmd>ClaudeCode --continue<cr>', desc = 'Continue Claude' },
      -- Diff management
      { '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', desc = 'Accept diff' },
      { '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', desc = 'Deny diff' },
    },
  },
  -- Opencode
  {
    'NickvanDyke/opencode.nvim',
    enabled = false,
    keys = {
      {
        '<leader>oA',
        function()
          require('opencode').ask()
        end,
        desc = 'Ask opencode',
      },
      {
        '<leader>oa',
        function()
          require('opencode').ask('@cursor: ')
        end,
        desc = 'Ask opencode about this',
        mode = 'n',
      },
      {
        '<leader>oa',
        function()
          require('opencode').ask('@selection: ')
        end,
        desc = 'Ask opencode about selection',
        mode = 'v',
      },
      {
        '<leader>on',
        function()
          require('opencode').command('session_new')
        end,
        desc = 'New session',
      },
      {
        '<leader>oy',
        function()
          require('opencode').command('messages_copy')
        end,
        desc = 'Copy last message',
      },
      {
        '<S-C-u>',
        function()
          require('opencode').command('messages_half_page_up')
        end,
        desc = 'Scroll messages up',
      },
      {
        '<S-C-d>',
        function()
          require('opencode').command('messages_half_page_down')
        end,
        desc = 'Scroll messages down',
      },
      {
        '<leader>op',
        function()
          require('opencode').select()
        end,
        desc = 'Select prompt',
        mode = { 'n', 'v' },
      },
      -- Example: keymap for custom prompt
      {
        '<leader>oe',
        function()
          require('opencode').prompt('Explain @cursor and its context')
        end,
        desc = 'Explain code near cursor',
      },
    },
    config = function()
      vim.g.opencode_opts = {
        on_opencode_not_found = function()
          vim.system({ 'tmux', 'splitw', '-l 35%', '-d', 'opencode' }, { cwd = vim.fn.getcwd() }):wait()
          return true
        end,
      }
    end,
  },
  -- AI chat & agents
  {
    'olimorris/codecompanion.nvim',
    enabled = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      {
        'ravitemer/mcphub.nvim',
        build = 'npm install -g mcp-hub@latest',
        config = function()
          require('mcphub').setup()
        end,
      },
    },
    keys = {
      { '\\A', '<cmd>CodeCompanionActions<cr>', mode = { 'n', 'v' }, desc = 'CodeCompanion Actions' },
      { '\\a', '<cmd>CodeCompanionChat Toggle<cr>', mode = { 'n', 'v' }, desc = 'CodeCompanion Chat Toggle' },
      { 'ga', '<cmd>CodeCompanionChat Add<cr>', mode = { 'v' }, desc = 'CodeCompanion Chat Add' },
      { '\\s', desc = 'CodeCompanion Select Model' },
    },
    cmd = {
      'CodeCompanion',
      'CodeCompanionActions',
      'CodeCompanionChat',
      'CodeCompanionCmd',
    },
    config = function()
      local default_model = 'qwen/qwen3-coder'
      local available_models = {
        'anthropic/claude-sonnet-4',
        'openai/gpt-5-mini',
        'openai/gpt-5',
        'openai/gpt-oss-20b:free',
        'openai/gpt-oss-120b',
        'google/gemini-2.5-flash',
        'google/gemini-2.5-pro',
        'mistralai/codestral-2508',
        'z-ai/glm-4.5',
        'qwen/qwen3-coder',
        'qwen/qwen3-coder:free',
        'moonshotai/kimi-k2',
        'moonshotai/kimi-k2:free',
        'moonshotai/kimi-dev-72b:free',
        'mistralai/codestral-2508',
      }
      local current_model = default_model

      local function select_model()
        vim.ui.select(available_models, {
          prompt = 'Select  Model:',
        }, function(choice)
          if choice then
            current_model = choice
            vim.notify('Selected model: ' .. current_model)
          end
        end)
      end

      require('codecompanion').setup({
        strategies = {
          chat = {
            adapter = 'openrouter',
          },
          inline = {
            adapter = 'openrouter',
          },
        },
        adapters = {
          opts = {
            show_defaults = false,
          },
          openrouter = function()
            return require('codecompanion.adapters').extend('openai_compatible', {
              env = {
                url = 'https://openrouter.ai/api',
                api_key = 'cmd:grep "^OPENROUTER_API_KEY" $DOTFILES/.env | cut -d"=" -f2-',
                chat_url = '/v1/chat/completions',
              },
              schema = {
                model = {
                  default = current_model,
                },
              },
            })
          end,
        },
        display = {
          action_palette = {
            provider = 'default',
          },
          chat = {
            window = {
              layout = 'vertical',
              width = 0.4,
            },
          },
          inline = {
            layout = 'vertical',
          },
        },
        extensions = {
          mcphub = {
            callback = 'mcphub.extensions.codecompanion',
            opts = {
              -- MCP Tools
              make_tools = true, -- Make individual tools (@server__tool) and server groups (@server) from MCP servers
              show_server_tools_in_chat = true, -- Show individual tools in chat completion (when make_tools=true)
              add_mcp_prefix_to_tool_names = false, -- Add mcp__ prefix (e.g `@mcp__github`, `@mcp__neovim__list_issues`)
              show_result_in_chat = true, -- Show tool results directly in chat buffer
              format_tool = nil, -- function(tool_name:string, tool: CodeCompanion.Agent.Tool) : string Function to format tool names to show in the chat buffer
              -- MCP Resources
              make_vars = true, -- Convert MCP resources to #variables for prompts
              -- MCP Prompts
              make_slash_commands = true, -- Add MCP prompts as /slash commands
            },
          },
        },
      })
      vim.keymap.set('n', '\\s', select_model, { desc = 'CodeCompanion Select Model' })
      -- Expand 'cc' into 'CodeCompanion' in the command line
      vim.cmd([[cab cc CodeCompanion]])
    end,
  },
}
