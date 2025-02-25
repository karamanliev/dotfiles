return {
  -- Search & Replace file/project
  {
    'nvim-pack/nvim-spectre',
    enabled = false,
    cmd = {
      'Spectre',
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    keys = {
      {
        '<Leader>ss',
        function()
          require('spectre').toggle()
        end,
        desc = 'Spectre',
      },
      {
        '<Leader>sw',
        function()
          require('spectre').open_visual({ select_word = true })
        end,
        desc = 'Spectre Word',
      },
      {
        '<Leader>ss',
        '<esc><cmd>lua require("spectre").open_visual()<CR>',
        desc = 'Spectre Selection',
        mode = 'v',
      },
      {
        '<Leader>sf',
        function()
          require('spectre').open_file_search({ select_word = true })
        end,
        desc = 'Spectre File',
      },
    },
    config = function()
      require('spectre').setup({
        mapping = {
          ['q'] = {
            map = 'q',
            cmd = "<cmd>lua require('spectre').close()<cr>",
            desc = 'Close',
          },
        },
      })
    end,
  },

  -- C+d from VSCode
  {
    'mg979/vim-visual-multi',
    enabled = false,
    keys = {
      '<C-n>',
      { '<C-n>', mode = 'v' },
      '<C-Up>',
      '<C-Down>',
      '<S-Left>',
      '<S-Right>',
      { '<leader>s/', '<Plug>(VM-Start-Regex-Search)', desc = 'VM Regex search' },
      { '<leader>s\\', '<Plug>(VM-Add-Cursor-At-Pos)', desc = 'VM Add cursor at position' },
      { '<leader>sA', '<Plug>(VM-Select-All)', desc = 'VM Select all' },
      { '<leader>sgS', '<Plug>(VM-Reselect-Last)', desc = 'VM Reselect last' },
    },
    branch = 'master',
    config = function()
      -- local hlslens = require('hlslens')
      -- if hlslens then
      --   local overrideLens = function(render, posList, nearest, idx, relIdx)
      --     local _ = relIdx
      --     local lnum, col = unpack(posList[idx])
      --
      --     local text, chunks
      --     if nearest then
      --       text = ('[%d/%d]'):format(idx, #posList)
      --       chunks = { { ' ', 'Ignore' }, { text, 'VM_Extend' } }
      --     else
      --       text = ('[%d]'):format(idx)
      --       chunks = { { ' ', 'Ignore' }, { text, 'HlSearchLens' } }
      --     end
      --     render.setVirt(0, lnum - 1, col - 1, chunks, nearest)
      --   end
      --   local lensBak
      --   local config = require('hlslens.config')
      --   local gid = vim.api.nvim_create_augroup('VMlens', {})
      --   vim.api.nvim_create_autocmd('User', {
      --     pattern = { 'visual_multi_start', 'visual_multi_exit' },
      --     group = gid,
      --     callback = function(ev)
      --       if ev.match == 'visual_multi_start' then
      --         lensBak = config.override_lens
      --         config.override_lens = overrideLens
      --       else
      --         config.override_lens = lensBak
      --       end
      --       hlslens.start()
      --     end,
      --   })
      -- end

      vim.g.VM_leader = '<space>s'
      vim.g.VM_set_statusline = 0
      vim.g.VM_theme = 'neon'
    end,
  },
}
