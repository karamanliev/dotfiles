local M = {}

M.get_bg_color = function()
  local bg = vim.api.nvim_get_hl(0, { name = 'Normal' }).bg
  local bgHex = string.format('#%06x', bg)

  return bgHex
end

M.get_fg_color = function()
  local fg = vim.api.nvim_get_hl(0, { name = 'Normal' }).fg
  local fgHex = string.format('#%06x', fg)

  return fgHex
end

M.get_cursorline_bg = function()
  local bg = vim.api.nvim_get_hl(0, { name = 'CursorLine' }).bg
  local bgHex = string.format('#%06x', bg)

  return bgHex
end

M.get_statusline_bg = function()
  local bg = vim.api.nvim_get_hl(0, { name = 'StatusLine' }).bg
  local bgNc = vim.api.nvim_get_hl(0, { name = 'StatusLineNC' }).bg
  local bgHex = string.format('#%06x', bg)
  local bgNcHex = string.format('#%06x', bgNc)

  return { bg = bgHex, bgNc = bgNcHex }
end

M.get_hl_color = function(group, attr)
  return vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(group)), attr)
end

return M
