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
  return vim.fn.system('tmux list-panes -t "' .. get_agent_session() .. '" -F "#{pane_id}" 2>/dev/null'):gsub('\n', '')
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

local function send_keys_to_pane(pane_id, message, with_enter)
  vim.fn.system('tmux send-keys -t ' .. pane_id .. ' "' .. message:gsub('"', '\\"') .. '"')
  if with_enter then
    vim.fn.system('tmux send-keys -t ' .. pane_id .. ' C-m')
  else
    vim.fn.system('tmux send-keys -t ' .. pane_id .. ' Space')
  end
end

local function send_to_agent(message, with_enter, show_after)
  if not is_agent_running() then
    show_popup()
    vim.defer_fn(function()
      local pane_id = get_agent_pane()
      if pane_id ~= '' then
        send_keys_to_pane(pane_id, message, with_enter)
      end
    end, 2500)
    return
  end

  local pane_id = get_agent_pane()
  if pane_id == '' then
    return
  end

  send_keys_to_pane(pane_id, message, with_enter)

  if show_after then
    show_popup()
  end
end

_G.agent_utils = {
  continue_agent = function()
    if is_agent_running() then
      local pane_id = get_agent_pane()
      if pane_id ~= '' then
        -- C-s is the leader in opencode, followed by l for sessions
        vim.fn.system('tmux send-keys -t ' .. pane_id .. ' C-s')
        vim.fn.system('tmux send-keys -t ' .. pane_id .. ' l')
      end
      show_popup()
    else
      -- Start agent with --continue
      local session = get_session_name()
      local path = get_current_path()
      local agent_cmd = vim.env.AGENT_CMD or 'opencode'
      local cmd = string.format(
        '~/.config/tmux/scripts/toggle-popup.sh "%s" "%s" "agent" "tmux new -s %s_agent-popup \\"%s --continue\\" \\; set-option -t %s_agent-popup default-command \\"%s\\""',
        session,
        path,
        session,
        agent_cmd,
        session,
        agent_cmd
      )
      vim.fn.jobstart(cmd)
    end
  end,
}

-- Keybinds
vim.keymap.set('n', '\\c', _G.agent_utils.continue_agent, { desc = 'Continue Agent or show sessions' })

vim.keymap.set('n', '\\b', function()
  send_to_agent('@' .. vim.fn.expand('%:.'), true, true)
end, { desc = 'Send buffer to Agent' })

vim.keymap.set({ 'n', 'v' }, '\\s', function()
  local mode = vim.fn.mode()
  local filepath = vim.fn.expand('%:.')
  local message

  if filepath == '' then
    return
  end

  if mode == 'v' or mode == 'V' or mode == '' then
    -- Read marks before exiting visual mode
    local start_line = vim.fn.line('v')
    local end_line = vim.fn.line('.')
    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'nx', false)
    message = string.format('@%s #L%d-%d', filepath, start_line, end_line)
  else
    local line = vim.fn.line('.')
    message = string.format('@%s #L%d-%d', filepath, line, line)
  end

  send_to_agent(message, false, true)
end, { desc = 'Send selection/line to Agent' })

vim.keymap.set({ 'n', 'v' }, '\\a', function()
  -- Capture visual selection if in visual mode
  local visual_selection = nil
  local mode = vim.fn.mode()
  if mode == 'v' or mode == 'V' or mode == '' then
    -- Read marks before exiting visual mode
    local start_line = vim.fn.line('v')
    local end_line = vim.fn.line('.')
    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end
    local filepath = vim.fn.expand('%:.')
    if filepath ~= '' then
      visual_selection = {
        start_line = start_line,
        end_line = end_line,
        filepath = filepath,
      }
    end
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'nx', false)
  end

  -- Create input popup
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'cursor',
    width = math.min(50, vim.api.nvim_win_get_width(0) - 4),
    height = 4,
    row = 1,
    col = 0,
    style = 'minimal',
    border = 'single',
    title = ' Send to Agent ',
    title_pos = 'center',
  })

  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].filetype = 'markdown'

  -- Pre-fill with file reference if in visual mode
  if visual_selection then
    local prefill = string.format('@%s #L%d-%d ', visual_selection.filepath, visual_selection.start_line, visual_selection.end_line)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { prefill })
  end

  local function send_message()
    local input = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '\n'):gsub('^%s*(.-)%s*$', '%1')
    vim.api.nvim_win_close(win, true)
    vim.cmd('stopinsert')

    if input == '' then
      return
    end

    local message
    local filepath = vim.fn.expand('%:.')
    if input:match('^@b') and filepath ~= '' then
      message = string.format('@%s %s', filepath, input:gsub('^@b%s*', ''))
    elseif input:match('^@') and filepath ~= '' then
      local line = vim.fn.line('.')
      message = string.format('@%s #L%d-%d %s', filepath, line, line, input:gsub('^@%s*', ''))
    else
      message = input
    end

    send_to_agent(message, true, true)
  end

  local function cancel()
    vim.api.nvim_win_close(win, true)
    vim.cmd('stopinsert')
  end

  vim.keymap.set({ 'n', 'i' }, '<C-s>', send_message, { buffer = buf, silent = true })
  vim.keymap.set({ 'n' }, '<CR>', send_message, { buffer = buf, silent = true })
  vim.keymap.set({ 'n', 'i' }, '<C-c>', cancel, { buffer = buf, silent = true })
  vim.keymap.set('n', '<Esc>', cancel, { buffer = buf, silent = true })
  vim.keymap.set('n', 'q', cancel, { buffer = buf, silent = true })

  vim.defer_fn(function()
    if visual_selection then
      vim.cmd('startinsert!')
    else
      vim.cmd('startinsert')
    end
  end, 10)
end, { desc = 'Send prompt to Agent' })
