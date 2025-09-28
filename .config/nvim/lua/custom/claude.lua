-- Custom Claude integration with tmux
-- Provides direct tmux integration without the claudecode plugin
local cli = 'claude'

-- Initialize shared Claude pane utilities globally
_G.claude_utils = {
  check_claude_running = function()
    return os.execute("tmux list-panes -F '#{pane_current_command}' | grep -q " .. cli) == 0
  end,

  get_claude_pane_id = function()
    return vim.fn.system('tmux list-panes -F "#{pane_id}:#{pane_current_command}" | grep ' .. cli .. ' | cut -d: -f1'):gsub('\n', '')
  end,

  ensure_claude_running = function(flags)
    if not _G.claude_utils.check_claude_running() then
      -- Start Claude in a new tmux pane
      local cols = vim.o.columns
      local lines = vim.o.lines
      local split_cmd = cols / math.max(lines, 1) >= 1.2 and 'tmux splitw -l 35% -d ' or 'tmux splitw -h -l 45% -d '
      vim.fn.system(split_cmd .. cli .. (flags and (' ' .. flags) or ''))
    end
  end,

  send_to_claude = function(message)
    local pane_id = _G.claude_utils.get_claude_pane_id()
    if pane_id ~= '' then
      vim.fn.system('tmux send-keys -t ' .. pane_id .. ' "' .. message:gsub('"', '\\"') .. ' "')
      return true
    else
      vim.notify('Claude pane not found', vim.log.levels.WARN)
      return false
    end
  end,

  send_to_claude_with_enter = function(message)
    local pane_id = _G.claude_utils.get_claude_pane_id()
    if pane_id ~= '' then
      vim.fn.system('tmux send-keys -t ' .. pane_id .. ' "' .. message:gsub('"', '\\"') .. '"')
      vim.fn.system('tmux send-keys -t ' .. pane_id .. ' C-m')
      return true
    else
      vim.notify('Claude pane not found', vim.log.levels.WARN)
      return false
    end
  end,

  focus_claude_pane = function(flags)
    if _G.claude_utils.check_claude_running() then
      local pane_id = _G.claude_utils.get_claude_pane_id()
      vim.fn.system('tmux select-pane -t ' .. pane_id)
    else
      _G.claude_utils.ensure_claude_running(flags)
    end
  end,

  kill_and_restart_claude = function(flags)
    local pane_id = _G.claude_utils.get_claude_pane_id()
    vim.fn.system('tmux kill-pane -t ' .. pane_id)
    _G.claude_utils.focus_claude_pane(flags)
  end,

  send_key_to_claude = function(key)
    local pane_id = _G.claude_utils.get_claude_pane_id()
    vim.fn.system('tmux send-keys -t ' .. pane_id .. ' ' .. key)
  end,
}

-- Keybinds for Claude integration
vim.keymap.set('n', '\\n', function()
  _G.claude_utils.focus_claude_pane()
end, { desc = 'Toggle/Focus Claude' })

vim.keymap.set('n', '\\c', function()
  _G.claude_utils.kill_and_restart_claude('--continue')
end, { desc = 'Continue Claude' })

vim.keymap.set('n', '\\r', function()
  _G.claude_utils.kill_and_restart_claude('--resume')
end, { desc = 'Resume Claude' })

vim.keymap.set('n', '\\w', function()
  _G.claude_utils.send_key_to_claude('1')
end, { desc = 'Accept Diff' })

vim.keymap.set('n', '\\m', function()
  _G.claude_utils.send_key_to_claude('BTab')
end, { desc = 'Change Mode / Auto Accept' })

vim.keymap.set('n', '\\d', function()
  _G.claude_utils.send_key_to_claude('Escape')
end, { desc = 'Decline Diff / Cancel' })

-- Send buffer to Claude
vim.keymap.set('n', '\\b', function()
  _G.claude_utils.ensure_claude_running()
  local filepath = vim.fn.expand('%:.')
  local message = string.format('@%s', filepath)
  _G.claude_utils.send_to_claude(message)
end, { desc = 'Send buffer to Claude via tmux' })

-- Send selection/line to Claude
vim.keymap.set({ 'n', 'v' }, '\\s', function()
  _G.claude_utils.ensure_claude_running()

  local mode = vim.fn.mode()
  local message
  local filepath = vim.fn.expand('%:.')

  if mode == 'v' or mode == 'V' or mode == '' then
    -- Visual mode: get selection
    local current_line = vim.fn.line('.')
    local visual_start_line = vim.fn.line('v')

    local start_line = math.min(current_line, visual_start_line)
    local end_line = math.max(current_line, visual_start_line)

    -- Exit visual mode
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)

    -- Format message with selection context
    message = string.format('@%s#L%d-%d', filepath, start_line, end_line)
  else
    -- Normal mode: get current line
    local current_line = vim.fn.line('.')
    message = string.format('@%s#L%d-%d', filepath, current_line, current_line)
  end

  _G.claude_utils.send_to_claude(message)
end, { desc = 'Send selection/line to Claude via tmux' })

-- Send prompt to Claude via popup
vim.keymap.set({ 'n', 'v' }, '\\a', function()
  _G.claude_utils.ensure_claude_running()

  -- Check if we're in visual mode and get selection
  local visual_selection = nil
  local mode = vim.fn.mode()
  if mode == 'v' or mode == 'V' or mode == '' then
    -- Get visual selection using current cursor and visual start
    local current_line = vim.fn.line('.')
    local visual_start_line = vim.fn.line('v')

    local start_line = math.min(current_line, visual_start_line)
    local end_line = math.max(current_line, visual_start_line)

    visual_selection = {
      start_line = start_line,
      end_line = end_line,
      filepath = vim.fn.expand('%:.'),
    }

    -- Exit visual mode
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
  end

  -- Create a scratch buffer for input
  local buf = vim.api.nvim_create_buf(false, true)
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local win_height = vim.api.nvim_win_get_height(0)
  local win_width = vim.api.nvim_win_get_width(0)

  -- Calculate position relative to cursor
  local popup_height = 4
  local popup_width = math.min(50, win_width - 4)
  local row = cursor_pos[1] + 1 -- Place right below cursor

  -- If there's not enough space below, place above
  if row + popup_height > win_height then
    row = cursor_pos[1] - popup_height - 1
  end

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'cursor',
    width = popup_width,
    height = popup_height,
    row = 1, -- 1 line below cursor
    col = 0, -- Same column as cursor
    style = 'minimal',
    border = 'single',
    title = ' Send to Claude ',
    title_pos = 'center',
  })

  -- Set buffer options
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].filetype = 'markdown'

  -- Position cursor at the beginning
  vim.api.nvim_win_set_cursor(win, { 1, 0 })

  -- Set up keymaps
  local function send_message()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local input = table.concat(lines, '\n'):gsub('^%s*', ''):gsub('%s*$', '')

    vim.api.nvim_win_close(win, true)

    if input and input ~= '' then
      local message

      -- Check if we have visual selection - always send with context
      if visual_selection then
        -- Format as @filepath#LSTARTING-ENDING .. input
        message = string.format('@%s#L%d-%d %s', visual_selection.filepath, visual_selection.start_line, visual_selection.end_line, input)
      -- Check if input starts with @ to include file context
      elseif input:match('^@b') then
        -- Remove @b from input
        local clean_input = input:gsub('^@b', ''):gsub('^%s*', ''):gsub('%s*$', '')
        local filepath = vim.fn.expand('%:.')

        -- Format as @filepath .. input
        message = string.format('@%s %s', filepath, clean_input)
      elseif input:match('^@') then
        -- Remove @ from input
        local clean_input = input:gsub('^@', ''):gsub('^%s*', ''):gsub('%s*$', '')

        -- Get cursor position (current line only)
        local cursor_line = vim.fn.line('.')
        local filepath = vim.fn.expand('%:.')

        -- Format as @filepath#LSTARTING-ENDING .. input
        message = string.format('@%s#L%d-%d %s', filepath, cursor_line, cursor_line, clean_input)
      else
        message = input
      end

      _G.claude_utils.send_to_claude_with_enter(message)

      -- Return to normal mode
      vim.cmd('stopinsert')
    end
  end

  local function cancel()
    vim.api.nvim_win_close(win, true)
    vim.cmd('stopinsert')
  end

  -- Set keymaps for the buffer
  vim.keymap.set({ 'n', 'i' }, '<C-s>', send_message, { buffer = buf, silent = true })
  vim.keymap.set({ 'n', 'i' }, '<CR>', send_message, { buffer = buf, silent = true })
  vim.keymap.set({ 'n', 'i' }, '<C-c>', cancel, { buffer = buf, silent = true })
  vim.keymap.set('n', '<Esc>', cancel, { buffer = buf, silent = true })
  vim.keymap.set('n', 'q', cancel, { buffer = buf, silent = true })

  -- Start in insert mode (defer to ensure it works after visual mode exit)
  vim.defer_fn(function()
    vim.cmd('startinsert')
  end, 10)
end, { desc = 'Send prompt to Claude via tmux' })
