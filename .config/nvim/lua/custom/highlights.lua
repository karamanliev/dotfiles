local set_hl = require('utils.misc').set_hl
local link_hl = require('utils.misc').link_hl
local get_hl_color = require('utils.misc').get_hl_color
local adjust_hex = require('utils.misc').adjust_hex_brightness
local statusline_fg = get_hl_color('StatusLine', 'fg#')
local statusline_bg = get_hl_color('StatusLine', 'bg#')

local lineNr_fg = get_hl_color('LineNr', 'fg#')
local cursorline_bg = require('utils.misc').get_cursorline_bg()
local text_fg = require('utils.misc').get_fg_color()
local comment_fg = get_hl_color('@comment', 'fg')

local diagnosticSignOk_fg = get_hl_color('DiagnosticSignOk', 'fg#')
local diagnosticSignHint_fg = get_hl_color('DiagnosticSignHint', 'fg#')
local diagnosticSignInfo_fg = get_hl_color('DiagnosticSignInfo', 'fg#')
local diagnosticSignWarn_fg = get_hl_color('DiagnosticSignWarn', 'fg#')

-- CursorLine (spans across linenr and signcolumn)
set_hl('CursorLineNr', { fg = 'none', bg = cursorline_bg, bold = true })
link_hl('CursorLineSign', 'CursorLineNr')
link_hl('CursorLineFold', 'CursorLineNr')

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
local prompt_bg = adjust_hex(cursorline_bg, 'lighten', 15)
local selection_carret_fg = get_hl_color('TelescopeSelectionCaret', 'fg#')

set_hl('TelescopeNormal', { fg = text_fg, bg = statusline_bg })
set_hl('TelescopeBorder', { fg = statusline_bg, bg = statusline_bg })
set_hl('TelescopeResultsNormal', { fg = text_fg, bg = statusline_bg })
set_hl('TelescopeSelectionCaret', { fg = selection_carret_fg, bg = cursorline_bg })
set_hl('TelescopeResultsBorder', { fg = statusline_bg, bg = statusline_bg })
set_hl('TelescopePreviewNormal', { fg = text_fg, bg = cursorline_bg })
set_hl('TelescopePreviewBorder', { fg = cursorline_bg, bg = cursorline_bg })
set_hl('TelescopePromptNormal', { bg = prompt_bg, fg = text_fg, bold = true })
set_hl('TelescopePromptBorder', { fg = prompt_bg, bg = prompt_bg })
set_hl('TelescopePromptCounter', { fg = comment_fg, bold = true })
set_hl('TelescopePromptTitle', { link = 'TodoBgNOTE' })
set_hl('TelescopePreviewTitle', { link = 'TodoBgTODO' })
set_hl('TelescopeResultsTitle', { fg = statusline_bg, bg = statusline_bg })
set_hl('TelescopeSelection', { link = 'CursorLine' })

-- Floats like diagnostics and gitsigns preview, hover and signature help
set_hl('FloatBorder', { fg = statusline_bg, bg = statusline_bg })
set_hl('NormalFloat', { bg = statusline_bg })

-- Package.json
set_hl('PackageInfoOutdatedVersionStatusLine', { fg = diagnosticSignHint_fg, bg = statusline_bg })
