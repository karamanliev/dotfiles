local M = {}
local function filepath()
  local fpath = vim.fn.fnamemodify(vim.fn.expand('%'), ':~:.:h')
  if fpath == '' or fpath == '.' then
    return ' '
  end

  return string.format(' %%<%s/', fpath)
end

local function filename()
  local fname = vim.fn.expand('%:t')
  if fname == '' then
    return ''
  end
  return fname .. ' '
end

local function lsp()
  local count = {}
  local levels = {
    errors = 'Error',
    warnings = 'Warn',
    info = 'Info',
    hints = 'Hint',
  }

  for k, level in pairs(levels) do
    count[k] = vim.tbl_count(vim.diagnostic.get(0, { severity = level }))
  end

  local errors = ''
  local warnings = ''
  local hints = ''
  local info = ''

  if count['errors'] ~= 0 then
    errors = ' %#LspDiagnosticError#■ ' .. count['errors']
  end
  if count['warnings'] ~= 0 then
    warnings = ' %#DiagnosticWarn#■ ' .. count['warnings']
  end
  if count['hints'] ~= 0 then
    hints = ' %#DiagnosticHint#■ ' .. count['hints']
  end
  if count['info'] ~= 0 then
    info = ' %#DiagnosticInfo#■ ' .. count['info']
  end

  return errors .. warnings .. hints .. info .. '%#Normal#'
end

local function lineinfo()
  if vim.bo.filetype == 'alpha' then
    return ''
  end
  return ' %P %l:%c '
end

local vcs = function()
  local git_info = vim.b.gitsigns_status_dict
  if not git_info or git_info.head == '' then
    return ''
  end
  local added = git_info.added and ('%#GitSignsAdd#+' .. git_info.added .. ' ') or ''
  local changed = git_info.changed and ('%#GitSignsChange#~' .. git_info.changed .. ' ') or ''
  local removed = git_info.removed and ('%#GitSignsDelete#-' .. git_info.removed .. ' ') or ''
  if git_info.added == 0 then
    added = ''
  end
  if git_info.changed == 0 then
    changed = ''
  end
  if git_info.removed == 0 then
    removed = ''
  end
  return table.concat({
    ' %#GitSignsAdd# ',
    git_info.head,
    ' ',
    ' %#Normal#',
    added,
    changed,
    removed,
    ' %#Normal#',
  })
end

Statusline = {}
M.custom_modules = {}

Statusline.active = function()
  local custom_modules = {}

  for _, func in pairs(M.custom_modules) do
    table.insert(custom_modules, func())
  end

  return table.concat({
    '%#StatusLine#',
    -- '%#Normal# ',
    '%#StatusLine#',
    vcs(),
    '%#StatusLine#',
    filepath(),
    '%#StatusLine#',
    filename(),
    '%=%#Normal#',
    table.concat(custom_modules, ' '),
    lsp(),
    ' ',
    '%#StatusLine#',
    lineinfo(),
  })
end

function Statusline.inactive()
  return ' %F'
end

function Statusline.short()
  return '%#StatusLineNC#   NvimTree'
end

local augroup = vim.api.nvim_create_augroup('Statusline', { clear = true })

vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' }, {
  group = augroup,
  pattern = '*',
  command = 'setlocal statusline=%!v:lua.Statusline.active()',
})

vim.api.nvim_create_autocmd({ 'WinLeave', 'BufLeave' }, {
  group = augroup,
  pattern = '*',
  command = 'setlocal statusline=%!v:lua.Statusline.inactive()',
})

vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter', 'FileType' }, {
  group = augroup,
  pattern = 'NvimTree',
  command = 'setlocal statusline=%!v:lua.Statusline.short()',
})

return M
