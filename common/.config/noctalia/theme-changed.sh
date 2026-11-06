#!/usr/bin/env bash
niri msg action do-screen-transition --delay-ms 500

case "${1:-}" in
dark) noctalia msg brightness-set all 50 ;;
light) noctalia msg brightness-set all 70 ;;
*) exit 0 ;;
esac
command -v nvim >/dev/null 2>&1 || exit 0

# Sync Noctalia's mode without replacing the editor's colorscheme.
exec nvim -l /dev/stdin "$1" <<'LUA'
local uv = vim.uv
local uid = uv.getuid()
local roots = '/tmp,/run/user/' .. uid
local sockets = vim.fn.globpath(roots, 'nvim*', true, true)
vim.list_extend(sockets, vim.fn.globpath(roots, 'nvim*/**', true, true))

for _, socket in ipairs(sockets) do
  local info = uv.fs_lstat(socket)
  if info and info.type == 'socket' and info.uid == uid then
    local connected, channel = pcall(vim.fn.sockconnect, 'pipe', socket, { rpc = true })
    if connected and channel > 0 then
      local ok, err = pcall(vim.rpcrequest, channel, 'nvim_exec_lua', 'vim.o.background = ...', { arg[1] })
      vim.fn.chanclose(channel)
      assert(ok, err)
    end
  end
end
LUA
