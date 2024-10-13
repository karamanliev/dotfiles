local function set_hl(group, colors)
  vim.api.nvim_set_hl(0, group, colors)
end
local get_hl_color = require('utils.misc').get_hl_color
local statusline_fg = get_hl_color('StatusLine', 'fg#')
local statusline_bg = get_hl_color('StatusLine', 'bg#')

local lineNr_fg = get_hl_color('LineNr', 'fg#')
local cursorline_bg = require('utils.misc').get_cursorline_bg()
local text_fg = require('utils.misc').get_fg_color()
local comment_fg = require('utils.misc').get_hl_color('@comment', 'fg')

local diagnosticSignOk_fg = get_hl_color('DiagnosticSignOk', 'fg#')
local diagnosticSignHint_fg = get_hl_color('DiagnosticSignHint', 'fg#')
local diagnosticSignInfo_fg = get_hl_color('DiagnosticSignInfo', 'fg#')
local diagnosticSignWarn_fg = get_hl_color('DiagnosticSignWarn', 'fg#')

-- Statusline
set_hl('StatusLineAccent', { bg = statusline_bg, fg = statusline_fg, bold = true })
set_hl('StatusLineAccentElement', { bg = statusline_bg, fg = statusline_fg })
set_hl('StatuslineInsertAccent', { bg = statusline_bg, fg = diagnosticSignOk_fg, bold = true })
set_hl('StatusLineInsertAccentElement', { bg = statusline_bg, fg = diagnosticSignOk_fg })
set_hl('StatuslineVisualAccent', { bg = statusline_bg, fg = diagnosticSignHint_fg, bold = true })
set_hl('StatusLineVisualAccentElement', { bg = statusline_bg, fg = diagnosticSignHint_fg })
set_hl('StatuslineReplaceAccent', { bg = statusline_bg, fg = diagnosticSignInfo_fg, bold = true })
set_hl('StatusLineReplaceAccentElement', { bg = statusline_bg, fg = diagnosticSignInfo_fg })
set_hl('StatuslineCmdLineAccent', { bg = statusline_bg, fg = diagnosticSignWarn_fg, bold = true })
set_hl('StatusLineCmdLineAccentElement', { bg = statusline_bg, fg = diagnosticSignWarn_fg })
set_hl('StatusLineNoChanges', { fg = lineNr_fg, bg = statusline_bg })
set_hl('LineInfo', { fg = lineNr_fg, bg = statusline_bg })

for _, sign in ipairs({ 'Add', 'Change', 'Delete' }) do
  local git_fg = get_hl_color('GitSigns' .. sign, 'fg#')
  set_hl('StatusLineGitSigns' .. sign, { fg = git_fg, bg = statusline_bg })
end

for _, level in ipairs({ 'Error', 'Warn', 'Hint', 'Info' }) do
  local diag_fg = get_hl_color('Diagnostic' .. level, 'fg#')
  set_hl('StatusLineDiagnostic' .. level, { fg = diag_fg, bg = statusline_bg })
end

-- CMP
set_hl('CmpBorder', { fg = statusline_bg, bg = statusline_bg })
set_hl('CmpNormal', { bg = statusline_bg })
set_hl('CmpDocBorder', { bg = cursorline_bg, fg = cursorline_bg })
set_hl('CmpDoc', { bg = cursorline_bg })

-- Telescope
set_hl('TelescopeNormal', { fg = text_fg, bg = statusline_bg })
set_hl('TelescopeBorder', { fg = statusline_bg, bg = statusline_bg })
set_hl('TelescopeResultsNormal', { fg = text_fg, bg = statusline_bg })
set_hl('TelescopeResultsBorder', { fg = statusline_bg, bg = statusline_bg })
set_hl('TelescopePreviewNormal', { fg = text_fg, bg = cursorline_bg })
set_hl('TelescopePreviewBorder', { fg = cursorline_bg, bg = cursorline_bg })
set_hl('TelescopePromptNormal', { bg = comment_fg, fg = cursorline_bg, bold = true })
set_hl('TelescopePromptBorder', { fg = comment_fg, bg = comment_fg })
set_hl('TelescopePromptCounter', { fg = cursorline_bg, bold = true })
set_hl('TelescopePromptTitle', { link = 'TodoBgNOTE' })
set_hl('TelescopePreviewTitle', { link = 'TodoBgTODO' })
set_hl('TelescopeResultsTitle', { fg = statusline_bg, bg = statusline_bg })
set_hl('TelescopeSelection', { link = 'CursorLine' })

-- Floats like diagnostics and gitsigns preview, hover and signature help
set_hl('FloatBorder', { fg = statusline_bg, bg = statusline_bg })
set_hl('NormalFloat', { bg = statusline_bg })

-- Package.json
set_hl('PackageInfoOutdatedVersionStatusLine', { fg = diagnosticSignHint_fg, bg = statusline_bg })
