-- Add the selections to Harpoon
local M = {}

local actions = require('telescope.actions')
local actions_state = require('telescope.actions.state')
local from_entry = require('telescope.from_entry')
local harpoon = require('harpoon')

local get_selections = function(prompt_bufnr)
  local picker = actions_state.get_current_picker(prompt_bufnr)
  local selections = {}

  if #picker:get_multi_selection() > 0 then
    selections = picker:get_multi_selection()
  else
    table.insert(selections, actions_state.get_selected_entry())
  end

  return selections
end

local add_to_harpoon = function(selections)
  local filenames = {}

  -- iterate over selections and add to harpoon
  for _, entry in ipairs(selections) do
    local file_path = from_entry.path(entry, false, false)

    if file_path then
      local filename = file_path:match('([^/]+)$')
      table.insert(filenames, filename)

      harpoon:list():add({ value = file_path, context = { row = 1, col = 0 } })
    end
  end

  return filenames
end

local notify_on_add = function(filenames)
  local filenames_str = table.concat(filenames, '\n')
  local padded_filenames_str = '  ' .. filenames_str:gsub('\n', '\n  ')
  vim.notify('\n  Added ' .. #filenames .. ' files to Harpoon:  \n' .. padded_filenames_str, vim.log.levels.INFO, { title = 'Telescope', timeout = 5000 })
end

M.mark = function(prompt_bufnr)
  local selections = get_selections(prompt_bufnr)
  local filenames = add_to_harpoon(selections)

  notify_on_add(filenames)

  -- close telescope after adding to harpoon
  actions.drop_all(prompt_bufnr)
end

return M
