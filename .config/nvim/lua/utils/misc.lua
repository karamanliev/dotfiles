local M = {}

M.set_hl = function(group, colors)
  vim.api.nvim_set_hl(0, group, colors)
end

M.link_hl = function(from, to)
  vim.api.nvim_set_hl(0, from, { link = to })
end

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
          return not vim.tbl_contains({
            -- returns error because of dependency missing
            'randombones',
            -- main themes
            'catppuccin',
            'rose-pine',
            'kanagawa',
            'tokyonight',
            -- light themes
            'kanagawa-lotus',
            'daylight',
            'catppuccin-latte',
            'dawnfox',
            'dayfox',
            'vimbones',
            'tokyonight-day',
            'rose-pine-dawn',
          }, color)
        end, target('', 'color'))
      end

      vim.cmd('Telescope colorscheme previewer=false layout_config={height=100,width=25,anchor="NE"}')
      vim.fn.getcompletion = target
    end,
    desc = 'Toggle Theme',
  },
}

M.adjust_hex_brightness = function(hex, mode, percent)
  -- Convert hex to RGB
  local r = tonumber(hex:sub(2, 3), 16)
  local g = tonumber(hex:sub(4, 5), 16)
  local b = tonumber(hex:sub(6, 7), 16)

  -- Calculate the adjustment factor based on mode
  local factor
  if mode == 'lighten' then
    factor = 1 + (percent / 100)
  elseif mode == 'darken' then
    factor = 1 - (percent / 100)
  else
    error("Mode must be either 'lighten' or 'darken'")
  end

  -- Adjust each color channel and clamp between 0 and 255
  r = math.max(0, math.min(255, math.floor(r * factor)))
  g = math.max(0, math.min(255, math.floor(g * factor)))
  b = math.max(0, math.min(255, math.floor(b * factor)))

  -- Convert back to hex and return
  return string.format('#%02x%02x%02x', r, g, b)
end
return M
