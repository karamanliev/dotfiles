return {
  -- Session management
  {
    'rmagatti/auto-session',
    event = {
      'BufReadPre',
      'BufWritePre',
    },
    cmd = { 'SessionRestore', 'SessionSave', 'SessionDelete', 'SessionSearch' },
    config = function()
      require('auto-session').setup({
        auto_session_use_git_branch = true,
        auto_restore_enabled = false,

        -- pre_save_cmds = { 'tabdo Neotree close' },

        session_lens = {
          buftypes_to_ignore = {}, -- list of buffer types what should not be deleted from current session
          load_on_setup = false,
          theme_conf = { border = true },
          previewer = false,
        },

        -- cwd_change_handling = {
        --   post_cwd_changed_hook = function() -- example refreshing the lualine status line _after_ the cwd changes
        --     require('lualine').refresh() -- refresh lualine so the new session name is displayed in the status bar
        --   end,
        -- },
      })

      vim.keymap.set('n', '<leader>fs', 'SessionSearch', {
        noremap = true,
        desc = 'List Sessions',
      })
    end,
  },

  -- Undo tree
  {
    'mbbill/undotree',
    enabled = false,
    cmd = {
      'UndotreeToggle',
    },
    init = function()
      vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle, { desc = 'Undo Tree' })
      vim.g.undotree_ShortIndicators = 1
      vim.g.undotree_SplitWidth = 35
      vim.g.undotree_SetFocusWhenToggle = 1
    end,
  },
}
