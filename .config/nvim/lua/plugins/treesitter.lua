return {
  {
    'nvim-treesitter/nvim-treesitter',
    event = { 'BufReadPre', 'BufNewFile' },
    build = ':TSUpdate',
    dependencies = {
      {
        'nvim-treesitter/nvim-treesitter-textobjects',
        event = { 'BufReadPre', 'BufNewFile' },
      },
      {
        'nvim-treesitter/nvim-treesitter-context',
        event = { 'BufReadPre', 'BufNewFile' },
      },
    },
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
      },
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },

      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<C-space>',
          node_incremental = '<C-space>',
          scope_incremental = false,
          node_decremental = '<bs>',
        },
      },

      textobjects = {
        lsp_interop = {
          enable = true,
          border = 'rounded',
          floating_preview_opts = {},
          -- peek_definition_code = {
          -- 	["<leader>df"] = "@function.outer",
          -- 	["<leader>dF"] = "@class.outer",
          -- },
        },
        select = {
          enable = true,
          -- Automatically jump forward to textobj, similar to targets.vim
          lookahead = true,
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ['a='] = { query = '@assignment.outer', desc = 'outer part of an assignment' },
            ['i='] = { query = '@assignment.inner', desc = 'inner part of an assignment' },
            ['l='] = { query = '@assignment.lhs', desc = 'left hand side of an assignment' },
            ['r='] = { query = '@assignment.rhs', desc = 'right hand side of an assignment' },

            -- works for javascript/typescript files (custom capture I created in after/queries/ecma/textobjects.scm)
            ['a:'] = { query = '@property.outer', desc = 'outer part of an object property' },
            ['i:'] = { query = '@property.inner', desc = 'inner part of an object property' },
            ['l:'] = { query = '@property.lhs', desc = 'left part of an object property' },
            ['r:'] = { query = '@property.rhs', desc = 'right part of an object property' },

            ['aa'] = { query = '@parameter.outer', desc = 'outer part of a parameter/argument' },
            ['ia'] = { query = '@parameter.inner', desc = 'inner part of a parameter/argument' },

            ['ai'] = { query = '@conditional.outer', desc = 'outer part of a conditional' },
            ['ii'] = { query = '@conditional.inner', desc = 'inner part of a conditional' },

            ['al'] = { query = '@loop.outer', desc = 'outer part of a loop' },
            ['il'] = { query = '@loop.inner', desc = 'inner part of a loop' },

            ['ac'] = { query = '@call.outer', desc = 'outer part of a function call' },
            ['ic'] = { query = '@call.inner', desc = 'inner part of a function call' },

            ['af'] = { query = '@function.outer', desc = 'outer part of a method/function definition' },
            ['if'] = { query = '@function.inner', desc = 'inner part of a method/function definition' },

            ['aC'] = { query = '@class.outer', desc = 'outer part of a class' },
            ['iC'] = { query = '@class.inner', desc = 'inner part of a class' },

            ['a/'] = { query = '@comment.outer', desc = 'comment' },
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            [']f'] = { query = '@call.outer', desc = 'Next function call start' },
            [']a'] = { query = '@assignment.outer', desc = 'Next assignment start' },
            [']m'] = { query = '@function.outer', desc = 'Next method/function def start' },
            [']c'] = { query = '@class.outer', desc = 'Next class start' },
            [']i'] = { query = '@conditional.outer', desc = 'Next conditional start' },
            [']l'] = { query = '@loop.outer', desc = 'Next loop start' },

            -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
            -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
            [']s'] = { query = '@scope', query_group = 'locals', desc = 'Next scope' },
            [']z'] = { query = '@fold', query_group = 'folds', desc = 'Next fold' },
          },
          goto_next_end = {
            [']F'] = { query = '@call.outer', desc = 'Next function call end' },
            [']A'] = { query = '@assignment.outer', desc = 'Next assignment end' },
            [']M'] = { query = '@function.outer', desc = 'Next method/function def end' },
            [']C'] = { query = '@class.outer', desc = 'Next class end' },
            [']I'] = { query = '@conditional.outer', desc = 'Next conditional end' },
            [']L'] = { query = '@loop.outer', desc = 'Next loop end' },
          },
          goto_previous_start = {
            ['[f'] = { query = '@call.outer', desc = 'Prev function call start' },
            ['[a'] = { query = '@assignment.outer', desc = 'Prev assignment start' },
            ['[m'] = { query = '@function.outer', desc = 'Prev method/function def start' },
            ['[c'] = { query = '@class.outer', desc = 'Prev class start' },
            ['[i'] = { query = '@conditional.outer', desc = 'Prev conditional start' },
            ['[l'] = { query = '@loop.outer', desc = 'Prev loop start' },
          },
          goto_previous_end = {
            ['[F'] = { query = '@call.outer', desc = 'Prev function call end' },
            ['[A'] = { query = '@assignment.outer', desc = 'Prev assignment end' },
            ['[M'] = { query = '@function.outer', desc = 'Prev method/function def end' },
            ['[C'] = { query = '@class.outer', desc = 'Prev class end' },
            ['[I'] = { query = '@conditional.outer', desc = 'Prev conditional end' },
            ['[L'] = { query = '@loop.outer', desc = 'Prev loop end' },
          },
        },
      },
    },
    config = function(_, opts)
      -- [[ Configure Treesitter ]] See `:help nvim-treesitter`

      -- Prefer git instead of curl in order to improve connectivity in some environments
      require('nvim-treesitter.install').prefer_git = true
      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup(opts)

      -- Treesitter Context
      require('treesitter-context').setup({
        enable = true,
        max_lines = 1,
      })
      vim.keymap.set('n', 'gC', function()
        require('treesitter-context').go_to_context(vim.v.count1)
      end, { silent = true })

      -- Treesitter Textobjects Repeatable Move
      local ts_repeat_move = require('nvim-treesitter.textobjects.repeatable_move')

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
    config = function()
      require('various-textobjs').setup({
        useDefaultKeymaps = false,
      })

      vim.keymap.set({ 'o', 'x' }, 'ir', "<cmd>lua require('various-textobjs').indentation('inner', 'inner')<CR>", { desc = 'Inner indentation' })
      vim.keymap.set({ 'o', 'x' }, 'ar', "<cmd>lua require('various-textobjs').indentation('outer', 'inner')<CR>", { desc = 'Outer indentation' })
      vim.keymap.set({ 'o', 'x' }, 'iR', "<cmd>lua require('various-textobjs').indentation('inner', 'inner')<CR>", { desc = 'Inner indentation' })
      vim.keymap.set(
        { 'o', 'x' },
        'aR',
        "<cmd>lua require('various-textobjs').indentation('outer', 'outer')<CR>",
        { desc = 'Outer indentation and lines above/below' }
      )
      vim.keymap.set({ 'o', 'x' }, 'R', "<cmd>lua require('various-textobjs').restOfIndentation()<CR>", { desc = 'Rest of indentation' })
      vim.keymap.set({ 'o', 'x' }, 'P', "<cmd>lua require('various-textobjs').restOfParagraph()<CR>", { desc = 'Rest of paragraph' })
      vim.keymap.set({ 'o', 'x' }, 'iS', "<cmd>lua require('various-textobjs').subword('inner')<CR>", { desc = 'Inner subword' })
      vim.keymap.set({ 'o', 'x' }, 'aS', "<cmd>lua require('various-textobjs').subword('outer')<CR>", { desc = 'Outer subword' })
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
      vim.keymap.set({ 'o', 'x' }, 'U', "<cmd>lua require('various-textobjs').lastChange()<CR>", { desc = 'Last change' })
      vim.keymap.set({ 'o', 'x' }, 'iz', "<cmd>lua require('various-textobjs').closedFold('inner')<CR>", { desc = 'Inner fold' })
      vim.keymap.set({ 'o', 'x' }, 'az', "<cmd>lua require('various-textobjs').closedFold('outer')<CR>", { desc = 'Outer fold' })
      vim.keymap.set({ 'o', 'x' }, '|', "<cmd>lua require('various-textobjs').column()<CR>", { desc = 'Column' })
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

  -- Autotag
  {
    'windwp/nvim-ts-autotag',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('nvim-ts-autotag').setup({
        opts = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true,
        },
      })
    end,
  },

  -- Smart split/join
  {
    'Wansmer/treesj',
    keys = {
      { 'J', '<cmd>TSJToggle<cr>', desc = 'Join Toggle' },
    },
    opts = {
      use_default_keymaps = false,
      max_join_length = 160,
    },
  },
}
