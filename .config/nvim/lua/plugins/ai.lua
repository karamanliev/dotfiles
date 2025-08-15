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
          return string.match(vim.fn.expand('%:t'), '.env')
        end,
      })
    end,
  },

  -- AI chat & agents
  {
    'olimorris/codecompanion.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    keys = {
      { '<leader>A', '<cmd>CodeCompanionActions<cr>', mode = { 'n', 'v' }, desc = 'CodeCompanion Actions' },
      { '<leader>a', '<cmd>CodeCompanionChat Toggle<cr>', mode = { 'n', 'v' }, desc = 'CodeCompanion Chat Toggle' },
      { 'ga', '<cmd>CodeCompanionChat Add<cr>', mode = { 'v' }, desc = 'CodeCompanion Chat Add' },
      { '<leader>ta', desc = 'Select AI Model' },
    },
    cmd = {
      'CodeCompanion',
      'CodeCompanionActions',
      'CodeCompanionChat',
      'CodeCompanionCmd',
    },
    config = function()
      local default_model = 'anthropic/claude-sonnet-4'
      local available_models = {
        'anthropic/claude-sonnet-4',
        'openai/gpt-5-mini',
        'openai/gpt-5',
        'google/gemini-2.5-flash',
        'google/gemini-2.5-pro',
        'z-ai/glm-4.5',
        'qwen/qwen3-coder',
        'moonshotai/kimi-k2',
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
      })
      vim.keymap.set('n', '<leader>ta', select_model, { desc = 'Select AI Model' })
      -- Expand 'cc' into 'CodeCompanion' in the command line
      vim.cmd([[cab cc CodeCompanion]])
    end,
  },
}
