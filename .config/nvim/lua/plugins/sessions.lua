return {
  'rmagatti/auto-session',
  cmd = { 'SessionRestore', 'SessionSave', 'SessionDelete' },
  config = function()
    require('auto-session').setup {
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
    }

    vim.keymap.set('n', '<leader>ls', require('auto-session.session-lens').search_session, {
      noremap = true,
      desc = 'List [S]essions',
    })
  end,
}
