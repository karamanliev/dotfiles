local command = vim.api.nvim_create_user_command

local autocmd = vim.api.nvim_create_autocmd
local autogroup = vim.api.nvim_create_augroup
local general = autogroup('General', { clear = true })

-- Close all buffers, but the active one
command('ClearBuffers', function()
  local current_line = vim.fn.line('.')
  vim.cmd([[%bd|e#|bd#]])
  vim.cmd(current_line .. 'norm! zz')
end, {})

-- Show current buffer CWD for 5 seconds
command('BufCWD', function()
  local function print_buffer_cwd()
    local cwd = vim.fn.expand('%:p:h')
    local padded_cwd = cwd .. string.rep(' ', 2) -- Adding 2 spaces of padding
    vim.notify('Current Buffer CWD: ' .. padded_cwd, vim.log.levels.INFO, { ttl = 10000 })
  end

  print_buffer_cwd()
end, {})

-- Highlight when yanking (copying) text
autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = general,
  desc = 'Highlight when yanking (copying) text',
})

-- Open help in vertical split
autocmd('FileType', {
  callback = function()
    vim.bo.bufhidden = 'unload'
    vim.cmd.wincmd('L')
    vim.cmd.wincmd('=')
  end,
  pattern = 'help',
  group = general,
  desc = 'Open help in vertical split',
})

-- Quit help buffer with q
autocmd('FileType', {
  callback = function()
    vim.keymap.set('n', 'q', '<C-w>c', { buffer = true, desc = 'Quit (or Close) help' })
  end,
  pattern = 'help',
  group = general,
  desc = 'Quit help buffer with q',
})

-- Preserve Last Cursor Position on Quit
autocmd('BufReadPost', {
  callback = function()
    if vim.fn.line('\'"') > 1 and vim.fn.line('\'"') <= vim.fn.line('$') then
      vim.cmd('normal! g`"')
    end
  end,
  group = general,
  desc = 'Preserve Last Cursor Position on Quit',
})

-- Disable New Line Comment
autocmd('BufEnter', {
  callback = function()
    vim.opt.formatoptions:remove({ 'c', 'r', 'o' })
  end,
  group = general,
  desc = 'Disable New Line Comment',
})
