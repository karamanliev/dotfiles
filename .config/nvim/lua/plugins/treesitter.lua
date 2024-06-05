return {
  'nvim-treesitter/nvim-treesitter',
  event = { 'BufReadPre', 'BufNewFile' },
  build = ':TSUpdate',
  dependencies = {
    {
      'windwp/nvim-ts-autotag',
      event = { 'InsertEnter' },
    },
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
          ['a='] = { query = '@assignment.outer', desc = 'Select outer part of an assignment' },
          ['i='] = { query = '@assignment.inner', desc = 'Select inner part of an assignment' },
          ['l='] = { query = '@assignment.lhs', desc = 'Select left hand side of an assignment' },
          ['r='] = { query = '@assignment.rhs', desc = 'Select right hand side of an assignment' },

          -- works for javascript/typescript files (custom capture I created in after/queries/ecma/textobjects.scm)
          ['a:'] = { query = '@property.outer', desc = 'Select outer part of an object property' },
          ['i:'] = { query = '@property.inner', desc = 'Select inner part of an object property' },
          ['l:'] = { query = '@property.lhs', desc = 'Select left part of an object property' },
          ['r:'] = { query = '@property.rhs', desc = 'Select right part of an object property' },

          ['aa'] = { query = '@parameter.outer', desc = 'Select outer part of a parameter/argument' },
          ['ia'] = { query = '@parameter.inner', desc = 'Select inner part of a parameter/argument' },

          ['ai'] = { query = '@conditional.outer', desc = 'Select outer part of a conditional' },
          ['ii'] = { query = '@conditional.inner', desc = 'Select inner part of a conditional' },

          ['al'] = { query = '@loop.outer', desc = 'Select outer part of a loop' },
          ['il'] = { query = '@loop.inner', desc = 'Select inner part of a loop' },

          ['af'] = { query = '@call.outer', desc = 'Select outer part of a function call' },
          ['if'] = { query = '@call.inner', desc = 'Select inner part of a function call' },

          ['am'] = { query = '@function.outer', desc = 'Select outer part of a method/function definition' },
          ['im'] = { query = '@function.inner', desc = 'Select inner part of a method/function definition' },

          ['ac'] = { query = '@class.outer', desc = 'Select outer part of a class' },
          ['ic'] = { query = '@class.inner', desc = 'Select inner part of a class' },
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

    -- Treesitter Autotag
    ---@diagnostic disable-next-line: missing-fields
    require('nvim-ts-autotag').setup({
      opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = true,
      },
    })

    -- Treesitter Context
    require('treesitter-context').setup({
      enable = true,
      max_lines = 1,
    })
    vim.keymap.set('n', 'gtc', function()
      require('treesitter-context').go_to_context(vim.v.count1)
    end, { silent = true })

    -- Treesitter Textobjects Repeatable Move
    local ts_repeat_move = require('nvim-treesitter.textobjects.repeatable_move')

    -- vim way: ; goes to the direction you were moving.
    vim.keymap.set({ 'n', 'x', 'o' }, ';', ts_repeat_move.repeat_last_move)
    vim.keymap.set({ 'n', 'x', 'o' }, ',', ts_repeat_move.repeat_last_move_opposite)

    -- Optionally, make builtin f, F, t, T also repeatable with ; and ,
    vim.keymap.set({ 'n', 'x', 'o' }, 'f', ts_repeat_move.builtin_f)
    vim.keymap.set({ 'n', 'x', 'o' }, 'F', ts_repeat_move.builtin_F)
    vim.keymap.set({ 'n', 'x', 'o' }, 't', ts_repeat_move.builtin_t)
    vim.keymap.set({ 'n', 'x', 'o' }, 'T', ts_repeat_move.builtin_T)
  end,
}
