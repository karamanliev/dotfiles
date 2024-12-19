-- Add specific keybindings for a React Native project (Metro)
local wk = require('which-key')

local function is_react_native_project()
  local package_json = vim.fn.getcwd() .. '/package.json'
  local f = io.open(package_json, 'r')
  if not f then
    return false
  end
  local content = f:read('*a')
  f:close()
  return content:match('%"react%-native%"') ~= nil
end

local function find_metro_pane()
  local handle = io.popen("tmux list-panes -F '#{pane_id} #{pane_current_command} #{pane_start_command}' | grep -E 'node|react-native start'")
  if not handle then
    return nil
  end
  local result = handle:read('*a')
  handle:close()

  local pane_id = result:match('(%d+)%s')
  if pane_id then
    return pane_id
  end

  return nil
end

local function open_metro_pane()
  local pane_id = find_metro_pane()
  if pane_id then
    vim.notify('Metro server is already running in tmux pane: ' .. pane_id, vim.log.levels.INFO)
    return
  end

  local project_root = vim.fn.getcwd()
  local start_command = "tmux splitw -h -d -l '35%' -e 'FORCE_COLOR=1' -c " .. project_root .. " 'react-native start | tee /tmp/watcher.log'"
  os.execute(start_command)
end

local function send_to_metro(key)
  if not is_react_native_project() then
    vim.notify('Not a React Native project', vim.log.levels.ERROR)
    return
  end

  local pane_id = find_metro_pane()
  if not pane_id then
    vim.notify('No Metro server pane found', vim.log.levels.ERROR)
    return
  end

  os.execute('tmux send-keys -t %' .. pane_id .. ' ' .. key)
end

wk.add({
  { '<leader>r', group = 'React Native', icon = { icon = '', color = 'blue' } },
  { '<leader>rm', open_metro_pane, desc = 'Start Metro server' },
  {
    '<leader>rr',
    function()
      send_to_metro('r')
    end,
    desc = 'Refresh Metro server',
  },
  {
    '<leader>rd',
    function()
      send_to_metro('d')
    end,
    desc = 'Open Metro dev menu',
  },
  {
    '<leader>rj',
    function()
      send_to_metro('j')
    end,
    desc = 'Open Metro DevTools',
  },
  cond = is_react_native_project,
})
