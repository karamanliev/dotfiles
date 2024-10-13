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
vim.api.nvim_set_hl(0, 'StatusLineAccent', { bg = statusline_bg, fg = statusline_fg, bold = true })
vim.api.nvim_set_hl(0, 'StatusLineAccentElement', { bg = statusline_bg, fg = statusline_fg })

vim.api.nvim_set_hl(0, 'StatuslineInsertAccent', { bg = statusline_bg, fg = diagnosticSignOk_fg, bold = true })
vim.api.nvim_set_hl(0, 'StatusLineInsertAccentElement', { bg = statusline_bg, fg = diagnosticSignOk_fg })

vim.api.nvim_set_hl(0, 'StatuslineVisualAccent', { bg = statusline_bg, fg = diagnosticSignHint_fg, bold = true })
vim.api.nvim_set_hl(0, 'StatusLineVisualAccentElement', { bg = statusline_bg, fg = diagnosticSignHint_fg })

vim.api.nvim_set_hl(0, 'StatuslineReplaceAccent', { bg = statusline_bg, fg = diagnosticSignInfo_fg, bold = true })
vim.api.nvim_set_hl(0, 'StatusLineReplaceAccentElement', { bg = statusline_bg, fg = diagnosticSignInfo_fg })

vim.api.nvim_set_hl(0, 'StatuslineCmdLineAccent', { bg = statusline_bg, fg = diagnosticSignWarn_fg, bold = true })
vim.api.nvim_set_hl(0, 'StatusLineCmdLineAccentElement', { bg = statusline_bg, fg = diagnosticSignWarn_fg })

vim.api.nvim_set_hl(0, 'StatusLineNoChanges', { fg = lineNr_fg, bg = statusline_bg })
vim.api.nvim_set_hl(0, 'LineInfo', { fg = lineNr_fg, bg = statusline_bg })

for _, sign in ipairs({ 'Add', 'Change', 'Delete' }) do
  local git_fg = get_hl_color('GitSigns' .. sign, 'fg#')
  vim.api.nvim_set_hl(0, 'StatusLineGitSigns' .. sign, { fg = git_fg, bg = statusline_bg })
end

for _, level in ipairs({ 'Error', 'Warn', 'Hint', 'Info' }) do
  local diag_fg = get_hl_color('Diagnostic' .. level, 'fg#')
  vim.api.nvim_set_hl(0, 'StatusLineDiagnostic' .. level, { fg = diag_fg, bg = statusline_bg })
end

-- CMP
vim.api.nvim_set_hl(0, 'CmpBorder', { fg = statusline_bg, bg = statusline_bg })
vim.api.nvim_set_hl(0, 'CmpNormal', { bg = statusline_bg })
vim.api.nvim_set_hl(0, 'CmpDocBorder', { bg = cursorline_bg, fg = cursorline_bg })
vim.api.nvim_set_hl(0, 'CmpDoc', { bg = cursorline_bg })

-- Telescope
vim.api.nvim_set_hl(0, 'TelescopeNormal', { fg = text_fg, bg = statusline_bg })
vim.api.nvim_set_hl(0, 'TelescopeBorder', { fg = statusline_bg, bg = statusline_bg })
vim.api.nvim_set_hl(0, 'TelescopeResultsNormal', { fg = text_fg, bg = statusline_bg })
vim.api.nvim_set_hl(0, 'TelescopeResultsBorder', { fg = statusline_bg, bg = statusline_bg })
vim.api.nvim_set_hl(0, 'TelescopePreviewNormal', { fg = text_fg, bg = cursorline_bg })
vim.api.nvim_set_hl(0, 'TelescopePreviewBorder', { fg = cursorline_bg, bg = cursorline_bg })
vim.api.nvim_set_hl(0, 'TelescopePromptNormal', { bg = comment_fg, fg = cursorline_bg, bold = true })
vim.api.nvim_set_hl(0, 'TelescopePromptBorder', { fg = comment_fg, bg = comment_fg })
vim.api.nvim_set_hl(0, 'TelescopePromptCounter', { fg = cursorline_bg, bold = true })
vim.api.nvim_set_hl(0, 'TelescopePromptTitle', { link = 'TodoBgNOTE' })
vim.api.nvim_set_hl(0, 'TelescopePreviewTitle', { link = 'TodoBgTODO' })
vim.api.nvim_set_hl(0, 'TelescopeResultsTitle', { fg = statusline_bg, bg = statusline_bg })
vim.api.nvim_set_hl(0, 'TelescopeSelection', { link = 'CursorLine' })

-- Floats like diagnostics and gitsigns preview, hover and signature help
vim.api.nvim_set_hl(0, 'FloatBorder', { fg = statusline_bg, bg = statusline_bg })
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = statusline_bg })

-- Package.json
vim.api.nvim_set_hl(0, 'PackageInfoOutdatedVersionStatusLine', { fg = diagnosticSignHint_fg, bg = statusline_bg })
