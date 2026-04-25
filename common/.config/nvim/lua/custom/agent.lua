-- Custom Agent integration with tmux popup
local function get_session_name()
  return vim.fn.system('tmux display-message -p "#{session_name}"'):gsub('\n', '')
end

local function get_current_path()
  return vim.fn.system('tmux display-message -p "#{pane_current_path}"'):gsub('\n', '')
end

local function get_agent_session()
  return get_session_name() .. '_agent-popup'
end

local function is_agent_running()
  return os.execute('tmux has-session -t "' .. get_agent_session() .. '" 2>/dev/null') == 0
end

local function get_agent_pane()
  local result = vim.fn.system({ 'tmux', 'list-panes', '-t', get_agent_session(), '-F', '#{pane_id}' })
  return (result:match('[^\n]+')) or ''
end

local function show_popup()
  local session = get_session_name()
  local path = get_current_path()
  local agent_cmd = vim.env.AGENT_CMD or 'opencode'
  local cmd = string.format(
    '~/.config/tmux/scripts/toggle-popup.sh "%s" "%s" "agent" "tmux attach -t %s_agent-popup || tmux new -s %s_agent-popup \\"%s\\" \\; set-option -t %s_agent-popup default-command \\"%s\\""',
    session,
    path,
    session,
    session,
    agent_cmd,
    session,
    agent_cmd
  )
  vim.fn.jobstart(cmd)
end

local FILE_REF_DELAY = 350

local function send_file_ref_to_pane(pane_id, filepath, suffix, with_enter)
  vim.fn.system({ 'tmux', 'send-keys', '-t', pane_id, '-l', '@' .. filepath })
  vim.defer_fn(function()
    vim.fn.system({ 'tmux', 'send-keys', '-t', pane_id, 'Tab' })
    if suffix and suffix ~= '' then
      if suffix:sub(1, 1) == ':' then
        vim.fn.system({ 'tmux', 'send-keys', '-t', pane_id, 'BSpace' })
      end
      vim.fn.system({ 'tmux', 'send-keys', '-t', pane_id, '-l', suffix })
    end
    if with_enter then
      vim.fn.system({ 'tmux', 'send-keys', '-t', pane_id, 'Enter' })
    end
  end, FILE_REF_DELAY)
end

local function wait_for_agent_ready(on_ready, attempts)
  attempts = attempts or 0
  if attempts >= 30 then
    return
  end

  local pane_id = get_agent_pane()
  if pane_id == '' then
    vim.defer_fn(function()
      wait_for_agent_ready(on_ready, attempts + 1)
    end, 300)
    return
  end

  vim.system({ 'tmux', 'capture-pane', '-t', pane_id, '-p' }, {}, function(result)
    vim.schedule(function()
      if result.code == 0 and (result.stdout or ''):find('commands') then
        on_ready(pane_id)
      else
        vim.defer_fn(function()
          wait_for_agent_ready(on_ready, attempts + 1)
        end, 300)
      end
    end)
  end)
end

local function with_agent_pane(on_ready, show_after)
  if not is_agent_running() then
    show_popup()
    wait_for_agent_ready(on_ready)
    return
  end

  local pane_id = get_agent_pane()
  if pane_id == '' then
    return
  end
  on_ready(pane_id)
  if show_after then
    show_popup()
  end
end

local function send_file_ref_to_agent(filepath, suffix, with_enter, show_after)
  with_agent_pane(function(pane_id)
    send_file_ref_to_pane(pane_id, filepath, suffix, with_enter)
  end, show_after)
end

local function get_visual_range()
  local start_line = vim.fn.line('v')
  local end_line = vim.fn.line('.')
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'nx', false)
  return start_line, end_line
end

local function make_line_ref(start_line, end_line)
  if start_line == end_line then
    return string.format(':%d ', start_line)
  end
  return string.format(':%d-%d ', start_line, end_line)
end

vim.keymap.set('n', '\\b', function()
  local filepath = vim.fn.expand('%:.')
  if filepath == '' then
    return
  end
  send_file_ref_to_agent(filepath, nil, false, true)
end, { desc = 'Send buffer to Agent' })

vim.keymap.set('n', '\\B', function()
  local filepath = vim.fn.expand('%:.')
  if filepath == '' then
    return
  end
  send_file_ref_to_agent(filepath, nil, false, false)
end, { desc = 'Send buffer to Agent (silent)' })

vim.keymap.set({ 'n', 'v' }, '\\l', function()
  local filepath = vim.fn.expand('%:.')
  if filepath == '' then
    return
  end
  local start_line, end_line
  if vim.fn.mode():match('^[vV\22]') then
    start_line, end_line = get_visual_range()
  else
    start_line = vim.fn.line('.')
    end_line = start_line
  end
  send_file_ref_to_agent(filepath, make_line_ref(start_line, end_line), false, true)
end, { desc = 'Send selection/line to Agent' })

vim.keymap.set({ 'n', 'v' }, '\\\\', function()
  local filepath = vim.fn.expand('%:.')
  if filepath == '' then
    return
  end
  local start_line, end_line
  if vim.fn.mode():match('^[vV\22]') then
    start_line, end_line = get_visual_range()
  else
    start_line = vim.fn.line('.')
    end_line = start_line
  end
  local ref = '@' .. filepath .. make_line_ref(start_line, end_line)
  vim.fn.setreg('+', ref)
  vim.notify('Copied: ' .. ref, vim.log.levels.INFO)
end, { desc = 'Copy buffer + line ref to clipboard' })

vim.keymap.set('n', '\\|', function()
  local filepath = vim.fn.expand('%:.')
  if filepath == '' then
    return
  end
  local ref = '@' .. filepath .. ' '
  vim.fn.setreg('+', ref)
  vim.notify('Copied: ' .. ref, vim.log.levels.INFO)
end, { desc = 'Copy buffer ref to clipboard' })

vim.keymap.set({ 'n', 'v' }, '\\L', function()
  local filepath = vim.fn.expand('%:.')
  if filepath == '' then
    return
  end
  local start_line, end_line
  if vim.fn.mode():match('^[vV\22]') then
    start_line, end_line = get_visual_range()
  else
    start_line = vim.fn.line('.')
    end_line = start_line
  end
  send_file_ref_to_agent(filepath, make_line_ref(start_line, end_line), false, false)
end, { desc = 'Send selection/line to Agent (silent)' })
