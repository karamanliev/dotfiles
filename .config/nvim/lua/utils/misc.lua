local M = {}

M.get_bg_color = function()
  local bg = vim.api.nvim_get_hl(0, { name = 'Normal' }).bg
  local bgHex = string.format('#%06x', bg)

  return bgHex
end

return M
