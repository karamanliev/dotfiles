-- LSP progress in cmdline (requires nvim 0.12+)
if vim.fn.has('nvim-0.12') == 1 then
  local lsp_progress = {}
  vim.api.nvim_create_autocmd('LspProgress', {
    group = vim.api.nvim_create_augroup('my.lsp.config', { clear = true }),
    callback = function(ev)
      local value = ev.data.params.value
      local client_id = ev.data.client_id
      local token = ev.data.params.token
      if value.kind == 'begin' then
        local client = vim.lsp.get_client_by_id(client_id)
        if not client then
          return
        end
        if not lsp_progress[client_id] then
          lsp_progress[client_id] = {}
        end
        local progress = {
          kind = 'progress',
          status = 'running',
          percent = value.percentage,
          title = string.format('LSP (%s[%d])', client.name, ev.data.client_id),
        }
        lsp_progress[client_id][token] = progress
        progress.id = vim.api.nvim_echo({ { value.title } }, false, progress)
        return
      end
      local progress = lsp_progress[client_id][token]
      if value.kind == 'report' then
        progress.percent = value.percentage
        vim.api.nvim_echo({ { value.title } }, false, progress)
      else
        progress.percent = 100
        progress.status = 'success'
        vim.api.nvim_echo({ { value.title } }, true, progress)
        lsp_progress[client_id][token] = nil
        if not next(lsp_progress[client_id]) then
          lsp_progress[client_id] = nil
        end
      end
    end,
  })
end
