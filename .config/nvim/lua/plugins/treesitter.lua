return {
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    branch = 'master',
    build = ':TSUpdate',
    opts = {
      ensure_installed = {
        'bash',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'vim',
        'vimdoc',
        'javascript',
        'json',
        'css',
        'typescript',
        'markdown',
        'query',
        'c',
        'diff',
        'php',
        'http',
        'markdown',
        'markdown_inline',
        'astro',
      },
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby', 'php' },
        disable = function(lang, buf)
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
      },
      indent = { enable = true, disable = { 'ruby', 'php' } },

      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<C-space>',
          node_incremental = '<C-space>',
          scope_incremental = false,
          node_decremental = '<bs>',
        },
      },
    },
    config = function(_, opts)
      -- Prefer git instead of curl in order to improve connectivity in some environments
      require('nvim-treesitter.install').prefer_git = true
      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup(opts)
    end,
  },

  -- Textobjects
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    enabled = false,
    config = function()
      -- Treesitter Textobjects Repeatable Move
      local ts_repeat_move = require('nvim-treesitter.textobjects.repeatable_move')

      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup({
        textobjects = {
          select = {
            enable = true,
            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,
            keymaps = {
              ['aa'] = { query = '@parameter.outer', desc = 'outer part of a parameter/argument' },
              ['ia'] = { query = '@parameter.inner', desc = 'inner part of a parameter/argument' },

              ['ac'] = { query = '@call.outer', desc = 'outer part of a function call' },
              ['ic'] = { query = '@call.inner', desc = 'inner part of a function call' },

              ['af'] = { query = '@function.outer', desc = 'outer part of a method/function definition' },
              ['if'] = { query = '@function.inner', desc = 'inner part of a method/function definition' },

              ['aC'] = { query = '@class.outer', desc = 'outer part of a class' },
              ['iC'] = { query = '@class.inner', desc = 'inner part of a class' },

              ['/'] = { query = '@comment.outer', desc = 'comment' },
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              [']c'] = { query = '@call.outer', desc = 'Next function call start' },
              [']a'] = { query = '@assignment.outer', desc = 'Next assignment start' },
              [']f'] = { query = '@function.outer', desc = 'Next method/function def start' },
              [']C'] = { query = '@class.outer', desc = 'Next class start' },
              [']i'] = { query = '@conditional.outer', desc = 'Next conditional start' },
              [']l'] = { query = '@loop.outer', desc = 'Next loop start' },
            },
            goto_previous_start = {
              ['[c'] = { query = '@call.outer', desc = 'Prev function call start' },
              ['[a'] = { query = '@assignment.outer', desc = 'Prev assignment start' },
              ['[f'] = { query = '@function.outer', desc = 'Prev method/function def start' },
              ['[C'] = { query = '@class.outer', desc = 'Prev class start' },
              ['[i'] = { query = '@conditional.outer', desc = 'Prev conditional start' },
              ['[l'] = { query = '@loop.outer', desc = 'Prev loop start' },
            },
          },
        },
      })

      -- vim way: ; goes to the direction you were moving.
      vim.keymap.set({ 'n', 'x', 'o' }, ';', ts_repeat_move.repeat_last_move_next)
      vim.keymap.set({ 'n', 'x', 'o' }, ',', ts_repeat_move.repeat_last_move_previous)

      -- Optionally, make builtin f, F, t, T also repeatable with ; and ,
      vim.keymap.set({ 'n', 'x', 'o' }, 'f', ts_repeat_move.builtin_f_expr, { expr = true })
      vim.keymap.set({ 'n', 'x', 'o' }, 'F', ts_repeat_move.builtin_F_expr, { expr = true })
      vim.keymap.set({ 'n', 'x', 'o' }, 't', ts_repeat_move.builtin_t_expr, { expr = true })
      vim.keymap.set({ 'n', 'x', 'o' }, 'T', ts_repeat_move.builtin_T_expr, { expr = true })
    end,
  },

  -- More textobjects
  {
    'chrisgrieser/nvim-various-textobjs',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    enabled = false,
    config = function()
      require('various-textobjs').setup({
        keymaps = {
          useDefaults = false,
        },
      })

      vim.keymap.set({ 'o', 'x' }, 'ii', "<cmd>lua require('various-textobjs').indentation('inner', 'inner')<CR>", { desc = 'Inner indentation' })
      vim.keymap.set(
        { 'o', 'x' },
        'ai',
        "<cmd>lua require('various-textobjs').indentation('outer', 'outer')<CR>",
        { desc = 'Outer indentation and lines above/below' }
      )
      vim.keymap.set({ 'o', 'x' }, 'R', "<cmd>lua require('various-textobjs').restOfIndentation()<CR>", { desc = 'Rest of indentation' })
      -- vim.keymap.set({ 'o', 'x' }, 'P', "<cmd>lua require('various-textobjs').restOfParagraph()<CR>", { desc = 'Rest of paragraph' })
      vim.keymap.set({ 'o', 'x' }, 'ie', "<cmd>lua require('various-textobjs').subword('inner')<CR>", { desc = 'Inner subword' })
      vim.keymap.set({ 'o', 'x' }, 'ae', "<cmd>lua require('various-textobjs').subword('outer')<CR>", { desc = 'Outer subword' })
      vim.keymap.set({ 'o', 'x' }, 'O', "<cmd>lua require('various-textobjs').toNextClosingBracket()<CR>", { desc = 'To next closing bracket' })
      vim.keymap.set({ 'o', 'x' }, 'Q', "<cmd>lua require('various-textobjs').toNextQuotationMark()<CR>", { desc = 'To next quotes' })
      vim.keymap.set({ 'o', 'x' }, 'iq', "<cmd>lua require('various-textobjs').anyQuote('inner')<CR>", { desc = 'Inner quotes' })
      vim.keymap.set({ 'o', 'x' }, 'aq', "<cmd>lua require('various-textobjs').anyQuote('outer')<CR>", { desc = 'Outer quotes' })
      vim.keymap.set({ 'o', 'x' }, 'io', "<cmd>lua require('various-textobjs').anyBracket('inner')<CR>", { desc = 'Inner brackets' })
      vim.keymap.set({ 'o', 'x' }, 'ao', "<cmd>lua require('various-textobjs').anyBracket('outer')<CR>", { desc = 'Outer brackets' })
      vim.keymap.set({ 'o', 'x' }, 'gG', "<cmd>lua require('various-textobjs').entireBuffer()<CR>", { desc = 'Buffer' })
      vim.keymap.set({ 'o', 'x' }, 'iv', "<cmd>lua require('various-textobjs').value('inner')<CR>", { desc = 'inner value' })
      vim.keymap.set({ 'o', 'x' }, 'av', "<cmd>lua require('various-textobjs').value('outer')<CR>", { desc = 'outer value' })
      vim.keymap.set({ 'o', 'x' }, 'ik', "<cmd>lua require('various-textobjs').key('inner')<CR>", { desc = 'inner key' })
      vim.keymap.set({ 'o', 'x' }, 'ak', "<cmd>lua require('various-textobjs').key('outer')<CR>", { desc = 'outer key' })
      vim.keymap.set({ 'o', 'x' }, 'in', "<cmd>lua require('various-textobjs').number('inner')<CR>", { desc = 'inner number' })
      vim.keymap.set({ 'o', 'x' }, 'an', "<cmd>lua require('various-textobjs').number('outer')<CR>", { desc = 'Outer quotes' })
      vim.keymap.set({ 'o', 'x' }, 'im', "<cmd>lua require('various-textobjs').chainMember('inner')<CR>", { desc = 'Inner chain' })
      vim.keymap.set({ 'o', 'x' }, 'am', "<cmd>lua require('various-textobjs').chainMember('outer')<CR>", { desc = 'Outer chain' })
      vim.keymap.set({ 'o', 'x' }, ';', "<cmd>lua require('various-textobjs').lastChange()<CR>", { desc = 'Last change' })
      vim.keymap.set({ 'o', 'x' }, 'iz', "<cmd>lua require('various-textobjs').closedFold('inner')<CR>", { desc = 'Inner fold' })
      vim.keymap.set({ 'o', 'x' }, 'az', "<cmd>lua require('various-textobjs').closedFold('outer')<CR>", { desc = 'Outer fold' })
      vim.keymap.set({ 'o', 'x' }, '|', "<cmd>lua require('various-textobjs').column()<CR>", { desc = 'Column' })
      vim.keymap.set({ 'o', 'x' }, '_', "<cmd>lua require('various-textobjs').lineCharacterwise('inner')<CR>", { desc = 'Line' })

      vim.keymap.set('n', 'dsi', function()
        -- select outer indentation
        require('various-textobjs').indentation('outer', 'outer')

        -- plugin only switches to visual mode when a textobj has been found
        local indentationFound = vim.fn.mode():find('V')
        if not indentationFound then
          return
        end

        -- dedent indentation
        vim.cmd.normal({ '<', bang = true })

        -- delete surrounding lines
        local endBorderLn = vim.api.nvim_buf_get_mark(0, '>')[1]
        local startBorderLn = vim.api.nvim_buf_get_mark(0, '<')[1]
        vim.cmd(tostring(endBorderLn) .. ' delete') -- delete end first so line index is not shifted
        vim.cmd(tostring(startBorderLn) .. ' delete')
      end, { desc = 'Delete Surrounding Indentation' })
    end,
  },

  -- Smart split/join
  {
    'Wansmer/treesj',
    keys = {
      { '<leader>j', '<cmd>TSJToggle<cr>', desc = 'TreesJ Toggle' },
    },
    -- event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    enabled = true,
    opts = {
      use_default_keymaps = false,
      max_join_length = 160,
    },
  },
}
