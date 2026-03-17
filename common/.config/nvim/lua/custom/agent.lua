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

local function send_keys_to_pane(pane_id, message, with_enter)
  -- Use table form (bypasses shell) and -l (literal) to prevent any character
  -- from being interpreted, which could cause garbled input / autocomplete bugs.
  vim.fn.system({ 'tmux', 'send-keys', '-t', pane_id, '-l', message })
  if with_enter then
    vim.fn.system({ 'tmux', 'send-keys', '-t', pane_id, 'Enter' })
  else
    vim.fn.system({ 'tmux', 'send-keys', '-t', pane_id, '-l', ' ' })
  end
end

-- Delay (ms) between typing a file reference and pressing Tab to confirm
-- the autocomplete. Too short → autocomplete hasn't resolved yet and
-- @general gets selected. Increase if you still see @general.
local FILE_REF_DELAY = 100

-- Sends @filepath, waits for autocomplete to resolve, then Tab to confirm
-- (which loads the file into agent context). Optionally appends a suffix
-- (e.g. line ref / prompt text) and/or submits with Enter.
local function send_file_ref_to_pane(pane_id, filepath, suffix, with_enter)
  vim.fn.system({ 'tmux', 'send-keys', '-t', pane_id, '-l', '@' .. filepath })
  vim.defer_fn(function()
    vim.fn.system({ 'tmux', 'send-keys', '-t', pane_id, 'Tab' })
    if suffix and suffix ~= '' then
      vim.fn.system({ 'tmux', 'send-keys', '-t', pane_id, '-l', suffix })
    end
    if with_enter then
      vim.fn.system({ 'tmux', 'send-keys', '-t', pane_id, 'Enter' })
    end
  end, FILE_REF_DELAY)
end

-- Polls the agent tmux pane until the opencode TUI has rendered (the
-- status bar text "commands" appears in the captured pane content), then
-- calls on_ready(pane_id). Uses async vim.system so Neovim never blocks.
-- Gives up after ~9s (30 × 300ms).
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

-- Ensures the agent is running and ready, then calls on_ready(pane_id).
-- Handles the "not running → show popup → wait" flow in one place.
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

local function send_to_agent(message, with_enter, show_after)
  with_agent_pane(function(pane_id)
    send_keys_to_pane(pane_id, message, with_enter)
  end, show_after)
end

local function send_file_ref_to_agent(filepath, suffix, with_enter, show_after)
  with_agent_pane(function(pane_id)
    send_file_ref_to_pane(pane_id, filepath, suffix, with_enter)
  end, show_after)
end

-- Exits visual mode and returns the selected line range (start, end).
local function get_visual_range()
  local start_line = vim.fn.line('v')
  local end_line = vim.fn.line('.')
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'nx', false)
  return start_line, end_line
end

-- Builds "#L<n> " or "#L<start>-<end> " line reference string (trailing space).
local function make_line_ref(start_line, end_line)
  if start_line == end_line then
    return string.format('#L%d ', start_line)
  end
  return string.format('#L%d-%d ', start_line, end_line)
end

-- Builds a full "@filepath #L<n>" reference string (used for display/prefill).
local function make_file_ref(filepath, start_line, end_line)
  return '@' .. filepath .. ' ' .. make_line_ref(start_line, end_line)
end

_G.agent_utils = {
  continue_agent = function()
    if is_agent_running() then
      local pane_id = get_agent_pane()
      if pane_id ~= '' then
        -- C-s is the leader in opencode, followed by l for sessions
        vim.fn.system({ 'tmux', 'send-keys', '-t', pane_id, 'C-s' })
        vim.fn.system({ 'tmux', 'send-keys', '-t', pane_id, 'l' })
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

vim.keymap.set({ 'n', 'v' }, '\\a', function()
  -- Capture visual selection if in visual mode
  local visual_selection = nil
  if vim.fn.mode():match('^[vV\22]') then
    local filepath = vim.fn.expand('%:.')
    local start_line, end_line = get_visual_range()
    if filepath ~= '' then
      visual_selection = { filepath = filepath, start_line = start_line, end_line = end_line }
    end
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

  local function send_message()
    local input = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '\n'):gsub('^%s*(.-)%s*$', '%1')
    vim.api.nvim_win_close(win, true)
    vim.cmd('stopinsert')

    if input == '' then
      return
    end

    -- Visual selection captured earlier → prepend file ref + line range
    if visual_selection then
      local suffix = make_line_ref(visual_selection.start_line, visual_selection.end_line) .. ' ' .. input
      send_file_ref_to_agent(visual_selection.filepath, suffix, true, true)
      return
    end

    local filepath = vim.fn.expand('%:.')
    if input:match('^@b') and filepath ~= '' then
      local rest = input:gsub('^@b%s*', '')
      send_file_ref_to_agent(filepath, rest, true, true)
    elseif input:match('^@') and filepath ~= '' then
      local line = vim.fn.line('.')
      local rest = input:gsub('^@%s*', '')
      send_file_ref_to_agent(filepath, make_line_ref(line, line) .. ' ' .. rest, true, true)
    else
      send_to_agent(input, true, true)
    end
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
    vim.cmd('startinsert')
  end, 10)
end, { desc = 'Send prompt to Agent' })
