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

local hide_when_small = function(module)
  if vim.o.columns < 120 then
    return ''
  else
    return module
  end
end

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

  return branch_name
end

local last_commit_cache = {}
local last_commit_ttl_seconds = 60

local function format_committer_name(name)
  local initials = {}

  for word in vim.trim(name or ''):gmatch('%S+') do
    table.insert(initials, word:sub(1, 1):upper())
  end

  return table.concat(initials)
end

local function format_commit_age(commit_ts)
  local age = math.max(os.time() - commit_ts, 0)

  if age < 3600 then
    return tostring(math.max(math.floor(age / 60), 1)) .. 'm'
  end

  if age < 86400 then
    return tostring(math.floor(age / 3600)) .. 'h'
  end

  if age < 30 * 86400 then
    return tostring(math.floor(age / 86400)) .. 'd'
  end

  if age < 365 * 86400 then
    return tostring(math.floor(age / (30 * 86400))) .. 'mo'
  end

  return tostring(math.floor(age / (365 * 86400))) .. 'y'
end

local function get_last_commit(bufnr)
  local now = os.time()
  local filepath = vim.api.nvim_buf_get_name(bufnr)

  if filepath == '' or vim.bo[bufnr].buftype ~= '' or vim.fn.filereadable(filepath) == 0 then
    return nil
  end

  local cached = last_commit_cache[bufnr]
  if cached and cached.filepath == filepath and now - cached.fetched_at < last_commit_ttl_seconds then
    return cached
  end

  -- Avoid spawning multiple concurrent jobs for the same buffer
  if cached and cached.filepath == filepath and cached.pending then
    return cached
  end

  last_commit_cache[bufnr] = { filepath = filepath, fetched_at = now, pending = true, found = false }

  local dir = vim.fn.fnamemodify(filepath, ':h')

  vim.system({ 'git', '-C', dir, 'log', '-n', '1', '--format=%ct%x1f%cn', '--', filepath }, { text = true }, function(result)
    local entry = { filepath = filepath, fetched_at = now, pending = false, found = false }
    if result.code == 0 and result.stdout then
      local line = vim.trim(result.stdout)
      local ts, committer = line:match('^(%d+)\31(.+)$')
      if ts and committer then
        entry.found = true
        entry.commit_ts = tonumber(ts)
        entry.committer = committer
      end
    end
    last_commit_cache[bufnr] = entry
    vim.schedule(function()
      vim.cmd('redrawstatus')
    end)
  end)

  return last_commit_cache[bufnr]
end

local function last_commit_module()
  local commit = get_last_commit(vim.api.nvim_get_current_buf())

  if not commit or not commit.found or not commit.commit_ts or not commit.committer then
    return ''
  end

  local committer = format_committer_name(commit.committer)
  if committer == '' then
    return ''
  end

  return '%#StatusLine#'
    .. ' '
    .. hide_when_small('%#StatusLineNoChanges#' .. committer .. '(')
    .. '%#StatusLine#'
    .. format_commit_age(commit.commit_ts)
    .. hide_when_small(' ago%#StatusLineNoChanges#)')
    .. ' %#StatusLineNoChanges#on%#StatusLine#'
end

Statusline.active = function()
  local custom_modules = {}
  local last_commit = last_commit_module()
  local last_commit_segment = last_commit ~= '' and (' ' .. last_commit) or ''

  for _, func in pairs(M.custom_modules) do
    local result = func()

    if result and result ~= '' then
      table.insert(custom_modules, result)
    end
  end

  return table.concat({
    -- hide_when_small(update_mode_colors()),
    -- hide_when_small(mode()),
    update_mode_colors(),
    mode(),
    '%#StatusLine#',
    filename(),
    ' %#StatusLine#',
    git_changes(),
    '%=%#StatusLine#',
    table.concat(custom_modules, ' '),
    ' %#StatusLine#',
    diagnostics(),
    ' %#StatusLine#',
    lineinfo(),
    last_commit_segment,
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

local excluded_filetypes = {
  -- Add filetype to exlcude here:
  -- 'snacks_picker',
  -- 'snacks_picker_input',
  -- 'snacks_picker_list',
  -- 'snacks_picker_preview',
  -- 'snacks_input',
  -- 'snacks_dashboard',
  -- 'snacks_notifier',
  -- 'snacks_terminal',
}

local function should_skip_statusline()
  local ft = vim.bo.filetype
  return vim.tbl_contains(excluded_filetypes, ft) or vim.w.snacks_win
end

vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' }, {
  group = augroup,
  pattern = '*',
  callback = function()
    if not should_skip_statusline() then
      vim.wo.statusline = '%!v:lua.Statusline.active()'
    end
  end,
})

vim.api.nvim_create_autocmd({ 'WinLeave', 'BufLeave' }, {
  group = augroup,
  pattern = '*',
  callback = function()
    if not should_skip_statusline() then
      vim.wo.statusline = '%!v:lua.Statusline.inactive()'
    end
  end,
})

-- redraw statusline when gitsigns updates
vim.api.nvim_create_autocmd('User', {
  pattern = 'GitSignsUpdate',
  callback = function()
    vim.cmd('redrawstatus')
  end,
})

-- vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter', 'FileType' }, {
--   group = augroup,
--   pattern = { 'alpha' },
--   callback = function()
--     vim.wo.statusline = '%!v:lua.Statusline.short()'
--   end,
-- })

return M
