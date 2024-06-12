return {
  {
    'nvim-treesitter/nvim-treesitter',
    event = { 'BufReadPre', 'BufNewFile' },
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
    enabled = true,
    config = function()
      -- Treesitter Textobjects Repeatable Move
      local ts_repeat_move = require('nvim-treesitter.textobjects.repeatable_move')

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

              ['gc'] = { query = '@comment.outer', desc = 'comment' },
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
    enabled = true,
    config = function()
      require('various-textobjs').setup({
        useDefaultKeymaps = false,
      })

      vim.keymap.set({ 'o', 'x' }, 'ii', "<cmd>lua require('various-textobjs').indentation('inner', 'inner')<CR>", { desc = 'Inner indentation' })
      vim.keymap.set(
        { 'o', 'x' },
        'ai',
        "<cmd>lua require('various-textobjs').indentation('outer', 'outer')<CR>",
        { desc = 'Outer indentation and lines above/below' }
      )
      vim.keymap.set({ 'o', 'x' }, 'R', "<cmd>lua require('various-textobjs').restOfIndentation()<CR>", { desc = 'Rest of indentation' })
      vim.keymap.set({ 'o', 'x' }, 'P', "<cmd>lua require('various-textobjs').restOfParagraph()<CR>", { desc = 'Rest of paragraph' })
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
      vim.keymap.set({ 'o', 'x' }, 'U', "<cmd>lua require('various-textobjs').lastChange()<CR>", { desc = 'Last change' })
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

  {
    'echasnovski/mini.ai',
    event = 'VeryLazy',
    enabled = false,
    opts = function()
      local i = {
        [' '] = 'Whitespace',
        ['"'] = 'Balanced "',
        ["'"] = "Balanced '",
        ['`'] = 'Balanced `',
        ['('] = 'Balanced (',
        [')'] = 'Balanced ) including white-space',
        ['>'] = 'Balanced > including white-space',
        ['<lt>'] = 'Balanced <',
        [']'] = 'Balanced ] including white-space',
        ['['] = 'Balanced [',
        ['}'] = 'Balanced } including white-space',
        ['{'] = 'Balanced {',
        ['?'] = 'User Prompt',
        _ = 'Underscore',
        a = 'Argument',
        b = 'Balanced ), ], }',
        c = 'Class',
        d = 'Digit(s)',
        e = 'Word in CamelCase & snake_case',
        f = 'Function',
        g = 'Entire file',
        i = 'Indent',
        o = 'Block, conditional, loop',
        q = 'Quote `, ", \'',
        t = 'Tag',
        u = 'Use/call function & method',
        U = 'Use/call without dot in name',
      }
      local a = vim.deepcopy(i)
      for k, v in pairs(a) do
        a[k] = v:gsub(' including.*', '')
      end

      local ic = vim.deepcopy(i)
      local ac = vim.deepcopy(a)
      for key, name in pairs({ n = 'Next', l = 'Last' }) do
        ---@diagnostic disable-next-line: assign-type-mismatch
        i[key] = vim.tbl_extend('force', { name = 'Inside ' .. name .. ' textobject' }, ic)
        ---@diagnostic disable-next-line: assign-type-mismatch
        a[key] = vim.tbl_extend('force', { name = 'Around ' .. name .. ' textobject' }, ac)
      end
      require('which-key').register({
        mode = { 'o', 'x' },
        i = i,
        a = a,
      })

      local ai = require('mini.ai')
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({ -- code block
            a = { '@block.outer', '@conditional.outer', '@loop.outer' },
            i = { '@block.inner', '@conditional.inner', '@loop.inner' },
          }),
          f = ai.gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }), -- function
          c = ai.gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }), -- class
          t = { '<([%p%w]-)%f[^<%w][^<>]->.-</%1>', '^<.->().*()</[^/]->$' }, -- tags
          d = { '%f[%d]%d+' }, -- digits
          e = { -- Word with case
            { '%u[%l%d]+%f[^%l%d]', '%f[%S][%l%d]+%f[^%l%d]', '%f[%P][%l%d]+%f[^%l%d]', '^[%l%d]+%f[^%l%d]' },
            '^().*()$',
          },
          i = function(ai_type)
            local spaces = (' '):rep(vim.o.tabstop)
            local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            local indents = {} ---@type {line: number, indent: number, text: string}[]

            for l, line in ipairs(lines) do
              if not line:find('^%s*$') then
                indents[#indents + 1] = { line = l, indent = #line:gsub('\t', spaces):match('^%s*'), text = line }
              end
            end

            local ret = {}

            for i = 1, #indents do
              if i == 1 or indents[i - 1].indent < indents[i].indent then
                local from, to = i, i
                for j = i + 1, #indents do
                  if indents[j].indent < indents[i].indent then
                    break
                  end
                  to = j
                end
                from = ai_type == 'a' and from > 1 and from - 1 or from
                to = ai_type == 'a' and to < #indents and to + 1 or to
                ret[#ret + 1] = {
                  indent = indents[i].indent,
                  from = { line = indents[from].line, col = ai_type == 'a' and 1 or indents[from].indent + 1 },
                  to = { line = indents[to].line, col = #indents[to].text },
                }
              end
            end

            return ret
          end, -- indent
          g = function(ai_type)
            local start_line, end_line = 1, vim.fn.line('$')
            if ai_type == 'i' then
              -- Skip first and last blank lines for `i` textobject
              local first_nonblank, last_nonblank = vim.fn.nextnonblank(start_line), vim.fn.prevnonblank(end_line)
              -- Do nothing for buffer with all blanks
              if first_nonblank == 0 or last_nonblank == 0 then
                return { from = { line = start_line, col = 1 } }
              end
              start_line, end_line = first_nonblank, last_nonblank
            end

            local to_col = math.max(vim.fn.getline(end_line):len(), 1)
            return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
          end, -- buffer
          u = ai.gen_spec.function_call(), -- u for "Usage"
          U = ai.gen_spec.function_call({ name_pattern = '[%w_]' }), -- without dot in function name
        },
      }
    end,
  },
  -- Context
  {
    'nvim-treesitter/nvim-treesitter-context',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    enabled = true,
    config = function()
      local context = require('treesitter-context')

      context.setup({
        enable = true,
        max_lines = 1,
      })

      vim.keymap.set('n', 'gC', function()
        context.go_to_context(vim.v.count1)
      end, { silent = true })
    end,
  },

  -- Autotag
  {
    'windwp/nvim-ts-autotag',
    ft = { 'html', 'javascriptreact', 'typescriptreact', 'svelte', 'vue' },
    -- event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    enabled = true,
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
    -- event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    enabled = true,
    opts = {
      use_default_keymaps = false,
      max_join_length = 160,
    },
  },
}
