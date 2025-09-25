local M = {}

M.action = setmetatable({}, {
  __index = function(_, action)
    return function()
      vim.lsp.buf.code_action({
        apply = true,
        context = {
          only = { action },
          diagnostics = {},
        },
      })
    end
  end,
})

function M.execute(opts)
  local params = {
    command = opts.command,
    arguments = opts.arguments,
  }
  if opts.open then
    vim.lsp.buf_request(0, 'workspace/executeCommand', params, function(err, result, ctx, config)
      if err then
        vim.notify('Error executing command: ' .. vim.inspect(err), vim.log.levels.ERROR)
        return
      end

      local items = {}
      if result then
        for _, item in ipairs(result) do
          table.insert(items, {
            filename = item.uri and vim.uri_to_fname(item.uri) or '',
            lnum = item.range and item.range.start.line + 1 or 0,
            col = item.range and item.range.start.character + 1 or 0,
            text = item.message or item.title or '',
            type = item.severity and (item.severity == 1 and 'E' or 'W') or 'I',
          })
        end
      end

      if #items == 1 and opts.open ~= 'always' then
        local item = items[1]
        vim.cmd('edit ' .. vim.fn.fnameescape(item.filename))
        vim.api.nvim_win_set_cursor(0, { item.lnum, item.col - 1 })
      elseif #items > 0 then
        vim.fn.setqflist({}, 'r', {
          title = 'LSP Command: ' .. opts.command,
          items = items,
        })
        vim.cmd('copen')
      else
        vim.notify('No results from LSP command: ' .. opts.command, vim.log.levels.INFO)
      end

      if opts.handler then
        opts.handler(err, result, ctx, config)
      end
    end)
  else
    return vim.lsp.buf_request(0, 'workspace/executeCommand', params, opts.handler)
  end
end

return M
