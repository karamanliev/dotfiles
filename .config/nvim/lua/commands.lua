local command = vim.api.nvim_create_user_command
local autocmd = vim.api.nvim_create_autocmd
local autogroup = vim.api.nvim_create_augroup
local general = autogroup('General', { clear = true })

-- Close all buffers, but the active one
command('ClearBuffers', function(args)
  local current_line = vim.fn.line('.')

  if args.bang then
    vim.cmd([[%bd!|e#|bd#]])
  else
    vim.cmd([[%bd|e#|bd#]])
  end

  vim.cmd(current_line .. 'norm! zz')
end, { bang = true, desc = 'Close all buffers, but the active one' })

-- Show current buffer CWD for 5 seconds
command('BufCWD', function()
  local function print_buffer_cwd()
    local cwd = vim.fn.expand('%:p:h')
    local padded_cwd = cwd .. string.rep(' ', 2) -- Adding 2 spaces of padding
    vim.notify('Current Buffer CWD: ' .. padded_cwd, vim.log.levels.INFO, { ttl = 10000 })
  end

  print_buffer_cwd()
end, {})

command('ToggleFoldColumn', function()
  local foldcolumn = vim.wo.foldcolumn
  vim.wo.foldcolumn = foldcolumn == '0' and '1' or '0'

  vim.notify('Fold column ' .. (foldcolumn == '1' and 'disabled' or 'enabled'), vim.log.levels.INFO)
end, {
  desc = 'Toggle fold column',
})

-- Copy current buffer file path to clipboard
command('CopyFilePathToClipboard', function()
  vim.fn.setreg('+', vim.fn.expand('%:p'))
end, {})

-- Write current buffer without auto-formatting
command('WriteWithoutFormat', function()
  vim.b.dont_format_on_write = true
  vim.cmd('write')

  vim.defer_fn(function()
    vim.b.dont_format_on_write = false
  end, 0)
end, {
  desc = 'Write without formatting the buffer',
})

-- Enable global/buffer formatting
command('FormatEnable', function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
  vim.notify('Autoformat-on-save re-enabled', vim.log.levels.INFO)
end, {
  desc = 'Re-enable autoformat-on-save',
})

-- Toggle global autoformatting
command('ToggleGlobalAutoformat', function()
  vim.g.disable_autoformat = not vim.g.disable_autoformat
  vim.notify('Global Autoformat-on-save ' .. (vim.g.disable_autoformat and 'disabled' or 'enabled'), vim.log.levels.INFO)
end, {
  desc = 'Toggle global autoformat-on-save',
})

-- Toggle buffer autoformatting
command('ToggleBufferAutoformat', function()
  vim.b.disable_autoformat = not vim.b.disable_autoformat
  vim.notify('Buffer Autoformat-on-save ' .. (vim.b.disable_autoformat and 'disabled' or 'enabled'), vim.log.levels.INFO)
end, {
  desc = 'Toggle buffer autoformat-on-save',
})

-- Open SSH file/dir locally with xdg-open
command('OpenSshFile', function(opts)
  if vim.env.SSH_TTY then
    local file_path = opts.args ~= '' and opts.args or vim.fn.expand('%:p')
    local dir = vim.fn.expand('%:p:h')
    local ssh_host = 'mindphuq'
    local open_cmd = 'xdg-open'

    -- open dir if arg dir is passed
    local open_path = opts.args == 'dir' and dir or file_path
    local ssh_url = 'sftp://macbook' .. open_path

    vim.cmd(string.format('silent! !ssh %s -t "%s %s"', ssh_host, open_cmd, ssh_url))
  else
    vim.notify('Not in SSH!')
  end
end, {
  desc = 'Open SSH file',
  nargs = '?',
})

-- Highlight when yanking (copying) text
autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = general,
  desc = 'Highlight when yanking (copying) text',
})

-- resize splits if window got resized
autocmd({ 'VimResized' }, {
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd('tabdo wincmd =')
    vim.cmd('tabnext ' .. current_tab)
  end,
  group = general,
  desc = 'Resize splits if window got resized',
})

-- Show cursor line only in active window
autocmd({ 'InsertLeave', 'WinEnter' }, {
  callback = function()
    if vim.w.auto_cursorline then
      vim.wo.cursorline = true
      vim.w.auto_cursorline = nil
    end
  end,
})
autocmd({ 'InsertEnter', 'WinLeave' }, {
  callback = function()
    if vim.wo.cursorline then
      vim.w.auto_cursorline = true
      vim.wo.cursorline = false
    end
  end,
})

-- Trim trailing whitespace on save
autocmd({ 'BufWritePre' }, {
  pattern = '*',
  command = [[%s/\s\+$//e]],
  group = general,
  desc = 'Trim trailing whitespace on save',
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

-- close Some windows with <q>
autocmd('FileType', {
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = event.buf, silent = true })
  end,
  pattern = {
    'PlenaryTestPopup',
    'help',
    'lspinfo',
    'notify',
    'qf',
    'spectre_panel',
    'startuptime',
    'tsplayground',
    'neotest-output',
    'checkhealth',
    'neotest-summary',
    'neotest-output-panel',
    'dbout',
    'gitsigns.blame',
    'git',
  },
  group = general,
  desc = 'Close some windows with <q>',
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

-- Disable eslint on node_modules
local disable_node_modules_eslint_group = vim.api.nvim_create_augroup('DisableEslintOnNodeModules', { clear = true })
autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = { '**/node_modules/**', 'node_modules', '/node_modules/*' },
  callback = function()
    vim.diagnostic.enable(false)
  end,
  group = disable_node_modules_eslint_group,
})
