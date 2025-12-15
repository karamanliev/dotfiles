local M = {}

M.custom_modules = {}
Statusline = {}

local modes = {
  ['n'] = 'NORMAL',
  ['no'] = 'NORMAL',
  ['v'] = 'VISUAL',
  ['V'] = 'VISUAL LINE',
  [''] = 'VISUAL BLOCK',
  ['s'] = 'SELECT',
  ['S'] = 'SELECT LINE',
  [''] = 'SELECT BLOCK',
  ['i'] = 'INSERT',
  ['ic'] = 'INSERT',
  ['R'] = 'REPLACE',
  ['Rv'] = 'VISUAL REPLACE',
  ['c'] = 'COMMAND',
  ['cv'] = 'VIM EX',
  ['ce'] = 'EX',
  ['r'] = 'PROMPT',
  ['rm'] = 'MOAR',
  ['r?'] = 'CONFIRM',
  ['!'] = 'SHELL',
  ['t'] = 'TERMINAL',
}

local function mode()
  local current_mode = vim.api.nvim_get_mode().mode
  local mode_name = modes[current_mode] or 'UNKNOWN'

  return string.format('%s', mode_name:sub(1, 1)):upper()
end

local function update_mode_colors()
  local current_mode = vim.api.nvim_get_mode().mode
  local mode_color = '%#StatusLineAccent#'
  local element_color = '%#StatusLineAccentElement#'

  if current_mode == 'n' then
    mode_color = '%#StatuslineAccent#'
    element_color = '%#StatusLineAccentElement#'
  elseif current_mode == 'i' or current_mode == 'ic' then
    mode_color = '%#StatuslineInsertAccent#'
    element_color = '%#StatusLineInsertAccentElement#'
  elseif current_mode == 'v' or current_mode == 'V' or current_mode == '' then
    mode_color = '%#StatuslineVisualAccent#'
    element_color = '%#StatusLineVisualAccentElement#'
  elseif current_mode == 'R' then
    mode_color = '%#StatuslineReplaceAccent#'
    element_color = '%#StatusLineReplaceAccentElement#'
  elseif current_mode == 'c' then
    mode_color = '%#StatuslineCmdLineAccent#'
    element_color = '%#StatusLineCmdLineAccentElement#'
  end

  return element_color .. '▌' .. mode_color
end

local function filename()
  local path = vim.fn.fnamemodify(vim.fn.expand('%'), ':~:.:h')
  if path == '' or path == '.' or path == '/' then
    path = ' '
  end

  local fpath = string.format(' %%<%s/', path)
  if #fpath > 60 then
    fpath = ' ...' .. fpath:sub(-47) -- Keep the last 57 characters and add '...'
  end

  if vim.o.columns < 80 then
    fpath = ' '
  end

  local fname = vim.fn.expand('%:t')
  if fname == '' then
    fname = ''
  end

  -- local ftype = vim.bo.filetype
  -- local ficon = require('nvim-web-devicons').get_icon_by_filetype(ftype)
  -- if ficon == nil then
  --   ficon = ''
  -- end

  local msymbol = vim.bo.modified and ' [+]' or ''
  local mhl = vim.bo.modified and '%#StatusLine#' or '%#StatusLineNoChanges#'

  return mhl
    -- .. ficon
    .. fpath
    .. '%#StatusLine#'
    .. fname
    .. msymbol
end

local function git_changes()
  local git_info = vim.b.gitsigns_status_dict
  if not git_info or git_info.head == '' then
    return ''
  end

  local added = git_info.added and ('%#StatusLineGitSignsAdd#+' .. git_info.added .. ' ') or ''
  local changed = git_info.changed and ('%#StatusLineGitSignsChange#~' .. git_info.changed .. ' ') or ''
  local removed = git_info.removed and ('%#StatusLineGitSignsDelete#-' .. git_info.removed .. ' ') or ''

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
    added,
    changed,
    removed,
  })
end

local function diagnostics()
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
    errors = ' %#StatusLineDiagnosticError#■ ' .. count['errors']
  end
  if count['warnings'] ~= 0 then
    warnings = ' %#StatusLineDiagnosticWarn#■ ' .. count['warnings']
  end
  if count['hints'] ~= 0 then
    hints = ' %#StatusLineDiagnosticHint#■ ' .. count['hints']
  end
  if count['info'] ~= 0 then
    info = ' %#StatusLineDiagnosticInfo#■ ' .. count['info']
  end

  return errors .. warnings .. hints .. info
end

local function lineinfo()
  if vim.bo.filetype == 'alpha' then
    return ''
  end

  return '%#LineInfo#' .. ' %7(%l/%3L%):%2c %P ' .. '%#StatusLine#'
end

local function branch()
  local b = vim.b.gitsigns_head

  if not b then
    return ''
  end

  local branch_name = b:gsub('^[^/]+/', '')
  if #branch_name > 30 then
    branch_name = branch_name:sub(1, 30) .. '...'
  end

  return ' ' .. branch_name
end

local function lsp_msg()
  local msg = vim.lsp.status()

  if msg == '' or vim.o.columns < 80 then
    return ''
  end

  local spinners = { '', '󰪞', '󰪟', '󰪠', '󰪢', '󰪣', '󰪤', '󰪥' }
  local ms = vim.uv.hrtime() / 1e6
  local frame = math.floor(ms / 100) % #spinners

  return '%#StatusLineNoChanges#' .. spinners[frame + 1] .. ' ' .. msg
end

local hide_when_small = function(module)
  if vim.o.columns < 120 then
    return ''
  else
    return module
  end
end

Statusline.active = function()
  local custom_modules = {}

  for _, func in pairs(M.custom_modules) do
    local result = func()

    if result and result ~= '' then
      table.insert(custom_modules, result)
    end
  end

  return table.concat({
    hide_when_small(update_mode_colors()),
    hide_when_small(mode()),
    '%#StatusLine#',
    filename(),
    ' %#StatusLine#',
    git_changes(),
    '%=%#StatusLine#',
    table.concat(custom_modules, ' '),
    ' %#StatusLine#',
    lsp_msg(),
    diagnostics(),
    ' %#StatusLine#',
    lineinfo(),
    ' ',
    branch(),
    ' ',
  })
end

function Statusline.inactive()
  return ' %F'
end

function Statusline.short()
  return '%#StatusLineNC#   ' .. vim.fn.getcwd()
end

local augroup = vim.api.nvim_create_augroup('Statusline', { clear = true })

-- vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' }, {
--   group = augroup,
--   pattern = '*',
--   command = 'setlocal statusline=%!v:lua.Statusline.active()',
-- })
--
-- vim.api.nvim_create_autocmd({ 'WinLeave', 'BufLeave' }, {
--   group = augroup,
--   pattern = '*',
--   command = 'setlocal statusline=%!v:lua.Statusline.inactive()',
-- })

vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter', 'FileType' }, {
  group = augroup,
  pattern = { 'alpha' },
  command = 'setlocal statusline=%!v:lua.Statusline.short()',
})

-- Redraw statusline when LSP progress updates
vim.api.nvim_create_autocmd('LspProgress', {
  callback = function()
    vim.cmd('redrawstatus')
  end,
})

return M
