require('options')
require('commands')
require('keymaps')

-- Lazy and plugins load
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    lazyrepo,
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require('lazy').setup('plugins', {
  change_detection = { notify = false },
})
