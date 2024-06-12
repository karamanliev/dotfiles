return {
  {
    'rmagatti/auto-session',
    event = { 'BufReadPre', 'BufNewFile' },
    cmd = { 'SessionRestore', 'SessionSave', 'SessionDelete' },
    config = function()
      require('auto-session').setup({
        auto_session_use_git_branch = true,
        auto_restore_enabled = false,

        -- pre_save_cmds = { 'tabdo Neotree close' },

        session_lens = {
          buftypes_to_ignore = {}, -- list of buffer types what should not be deleted from current session
          load_on_setup = true,
          theme_conf = { border = true },
          previewer = false,
        },

        -- cwd_change_handling = {
        --   post_cwd_changed_hook = function() -- example refreshing the lualine status line _after_ the cwd changes
        --     require('lualine').refresh() -- refresh lualine so the new session name is displayed in the status bar
        --   end,
        -- },
      })

      vim.keymap.set('n', '<leader>lS', require('auto-session.session-lens').search_session, {
        noremap = true,
        desc = 'List [S]essions',
      })
    end,
  },
  {
    'mbbill/undotree',
    keys = '<leader>u',
    config = function()
      vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle, { desc = '[U]ndo Tree' })
      vim.g.undotree_ShortIndicators = 1
      vim.g.undotree_SplitWidth = 35
      vim.g.undotree_SetFocusWhenToggle = 1
    end,
  },
}
