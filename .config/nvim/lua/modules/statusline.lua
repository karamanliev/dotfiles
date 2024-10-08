local M = {}
local get_hl_color = require('utils.misc').get_hl_color

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

  return string.format('%s', mode_name:sub(1, 2)):upper()
end

local function update_mode_colors()
  local fg = get_hl_color('StatusLine', 'fg#')
  local bg = get_hl_color('StatusLine', 'bg#')
  local c1 = get_hl_color('DiagnosticSignOk', 'fg#')
  local c2 = get_hl_color('DiagnosticSignHint', 'fg#')
  local c3 = get_hl_color('DiagnosticSignInfo', 'fg#')
  local c4 = get_hl_color('DiagnosticSignWarn', 'fg#')

  vim.api.nvim_set_hl(0, 'StatusLineAccent', { bg = bg, fg = fg, bold = true })
  vim.api.nvim_set_hl(0, 'StatusLineAccentElement', { bg = bg, fg = fg })

  vim.api.nvim_set_hl(0, 'StatuslineInsertAccent', { bg = bg, fg = c1, bold = true })
  vim.api.nvim_set_hl(0, 'StatusLineInsertAccentElement', { bg = bg, fg = c1 })

  vim.api.nvim_set_hl(0, 'StatuslineVisualAccent', { bg = bg, fg = c2, bold = true })
  vim.api.nvim_set_hl(0, 'StatusLineVisualAccentElement', { bg = bg, fg = c2 })

  vim.api.nvim_set_hl(0, 'StatuslineReplaceAccent', { bg = bg, fg = c3, bold = true })
  vim.api.nvim_set_hl(0, 'StatusLineReplaceAccentElement', { bg = bg, fg = c3 })

  vim.api.nvim_set_hl(0, 'StatuslineCmdLineAccent', { bg = bg, fg = c4, bold = true })
  vim.api.nvim_set_hl(0, 'StatusLineCmdLineAccentElement', { bg = bg, fg = c4 })

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
  local inactive_fg = get_hl_color('LineNr', 'fg#')
  local statusline_bg = get_hl_color('StatusLine', 'bg#')
  vim.api.nvim_set_hl(0, 'StatusLineNoChanges', { fg = inactive_fg, bg = statusline_bg })

  local path = vim.fn.fnamemodify(vim.fn.expand('%'), ':~:.:h')
  if path == '' or path == '.' or path == '/' then
    path = ' '
  end

  local fpath = string.format(' %%<%s/', path)
  if #fpath > 50 then
    fpath = ' ...' .. fpath:sub(-47) -- Keep the last 47 characters and add '...'
  end

  local fname = vim.fn.expand('%:t')
  if fname == '' then
    fname = ''
  end

  local ftype = vim.bo.filetype
  local ficon = require('nvim-web-devicons').get_icon_by_filetype(ftype)
  if ficon == nil then
    ficon = ''
  end

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
  for _, sign in ipairs({ 'Add', 'Change', 'Delete' }) do
    local git_fg = get_hl_color('GitSigns' .. sign, 'fg#')
    local statusline_bg = get_hl_color('StatusLine', 'bg#')

    vim.api.nvim_set_hl(0, 'StatusLineGitSigns' .. sign, { fg = git_fg, bg = statusline_bg })
  end

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

local function lsp()
  for _, level in ipairs({ 'Error', 'Warn', 'Hint', 'Info' }) do
    local diag_fg = get_hl_color('Diagnostic' .. level, 'fg#')
    local statusline_bg = get_hl_color('StatusLine', 'bg#')

    vim.api.nvim_set_hl(0, 'StatusLineDiagnostic' .. level, { fg = diag_fg, bg = statusline_bg })
  end

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
  local inactive_fg = get_hl_color('LineNr', 'fg#')
  local statusline_bg = get_hl_color('StatusLine', 'bg#')
  vim.api.nvim_set_hl(0, 'LineInfo', { fg = inactive_fg, bg = statusline_bg })

  if vim.bo.filetype == 'alpha' then
    return ''
  end
  return '%#LineInfo#' .. ' %P %l:%c ' .. '%#StatusLine#'
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

Statusline.active = function()
  local custom_modules = {}

  for _, func in pairs(M.custom_modules) do
    local result = func()

    if result and result ~= '' then
      table.insert(custom_modules, result)
    end
  end

  return table.concat({
    update_mode_colors(),
    mode(),
    '%#StatusLine#',
    filename(),
    ' %#StatusLine#',
    git_changes(),
    '%=%#StatusLine#',
    table.concat(custom_modules, ' '),
    ' %#StatusLine#',
    lsp(),
    ' %#StatusLine#',
    lineinfo(),
    ' ',
    branch(),
    ' ',
  })
end

function Statusline.inactive()
  return table.concat({
    update_mode_colors(),
    mode(),
    '%#StatusLine#',
    filename(),
    '%=',
    branch(),
    ' ',
  })
end

function Statusline.short()
  return '%#StatusLineNC#   NvimTree'
end

local augroup = vim.api.nvim_create_augroup('Statusline', { clear = true })

vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' }, {
  group = augroup,
  pattern = '*',
  callback = function()
    vim.o.laststatus = 2
    vim.o.statusline = '%!v:lua.Statusline.active()'
  end,
})

vim.api.nvim_create_autocmd({ 'WinLeave', 'BufLeave' }, {
  group = augroup,
  pattern = '*',
  command = 'setlocal statusline=%!v:lua.Statusline.inactive()',
})

--
vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter', 'FileType' }, {
  group = augroup,
  pattern = { 'alpha' },
  callback = function()
    vim.o.laststatus = 0
    vim.o.statusline = '%!v:lua.Statusline.short()'
  end,
})

return M
