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

M.theme_switch_kb = {
  {
    '<leader>tt',
    function()
      local target = vim.fn.getcompletion

      ---@diagnostic disable-next-line: duplicate-set-field
      vim.fn.getcompletion = function()
        return vim.tbl_filter(function(color)
          return not vim.tbl_contains({ 'randombones' }, color)
        end, target('', 'color'))
      end

      vim.cmd('Telescope colorscheme previewer=false layout_config={height=100,width=25,anchor="NE"}')
      vim.fn.getcompletion = target
    end,
    desc = 'Toggle Theme',
  },
}

return M
