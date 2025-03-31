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
  if vim.env.SSH_CONNECTION then
    local file_path = opts.args ~= '' and opts.args or vim.fn.expand('%:p')
    local dir = vim.fn.expand('%:p:h')
    local ssh_host = 'mindphuq'
    local open_cmd = 'gio open'

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

command('LazyGit', function()
  local bg = require('utils.misc').get_bg_color()
  vim.cmd(
    'silent !tmux set -w popup-border-lines none; tmux popup -E -eTERM=screen-256color -xC -yS -w100\\% -h99\\% -sbg=\\'
      .. bg
      .. ' -Sbg=\\'
      .. bg
      .. ' -d "'
      .. vim.fn.getcwd()
      .. '" lazygit -ucf $XDG_CONFIG_HOME/lazygit/config_nvim.yml'
  )
end, { desc = 'LazyGit' })

-- Highlight when yanking (copying) text
autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank({ timeout = 650 }) -- Highlight stays for 1000 milliseconds (1 second)
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

-- Open images in vsplit
autocmd('BufReadPre', {
  callback = function(ev)
    local last_buf = vim.fn.bufnr('#')

    if last_buf > 0 then
      vim.bo.bufhidden = 'unload'
      vim.cmd('vsplit ' .. ev.file)

      vim.cmd.wincmd('p') -- focus last window
      vim.cmd('buffer #')
      vim.cmd.wincmd('p')
    end
  end,
  pattern = { '*.png', '*.jpg', '*.jpeg', '*.JPEG', '*.JPG', '*.gif', '*.webp', '*.avif' },
  group = general,
  desc = 'Open images in vsplit',
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
    'gitsigns-blame',
    'git',
    'image_nvim',
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

-- Disable LSP and TS when opening large files
local big_file = autogroup('BigFile', { clear = true })
vim.filetype.add({
  pattern = {
    ['.*'] = {
      function(path, buf)
        return vim.bo[buf] and vim.bo[buf].filetype ~= 'bigfile' and path and vim.fn.getfsize(path) > 1024 * 500 and 'bigfile' or nil -- bigger than 500KB
      end,
    },
  },
})

autocmd({ 'FileType' }, {
  group = big_file,
  pattern = 'bigfile',
  callback = function(ev)
    vim.cmd('syntax off')
    -- vim.cmd('UfoDetach')
    vim.cmd('Gitsigns detach')
    vim.opt_local.foldmethod = 'manual'
    vim.opt_local.spell = false
    vim.schedule(function()
      vim.bo[ev.buf].syntax = vim.filetype.match({ buf = ev.buf }) or ''
    end)
  end,
})

-- Open signature help automatically
-- autocmd('LspAttach', {
--   group = autogroup('LspSignatureHelp', { clear = true }),
--   callback = function(args)
--     local client = vim.lsp.get_client_by_id(args.data.client_id)
--
--     if client then
--       local signatureProvider = client.server_capabilities.signatureHelpProvider
--       if signatureProvider and signatureProvider.triggerCharacters then
--         require('utils.lsp').setup(client, args.buf)
--       end
--     end
--   end,
-- })

-- Refresh colorscheme highlights on change
autocmd({ 'ColorScheme' }, {
  pattern = '*',
  group = general,
  callback = function()
    vim.cmd('source ' .. vim.fn.stdpath('config') .. '/lua/custom/highlights.lua')
    vim.cmd('set background=dark')
  end,
  desc = 'Source highlights.lua',
})

-- Set filetype to image
autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = { '*.png', '*.jpg', '*.jpeg', '*.gif', '*.bmp' },
  group = general,
  callback = function()
    vim.bo.filetype = 'image'
  end,
  desc = 'Set filetype to image',
})
