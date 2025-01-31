local function keymap(lhs, rhs, desc)
  return vim.api.nvim_buf_set_keymap(0, 'n', lhs, rhs, { noremap = true, silent = true, desc = desc })
end

keymap('<CR>', "<cmd>lua require('kulala').run()<cr>", 'Execute the request')
keymap('[', "<cmd>lua require('kulala').jump_prev()<cr>", 'Jump to the previous request')
keymap(']', "<cmd>lua require('kulala').jump_next()<cr>", 'Jump to the next request')
keymap('<leader>i', "<cmd>lua require('kulala').inspect()<cr>", 'Inspect the current request')
keymap('<leader>s', "<cmd>lua require('kulala').search()<cr>", 'Search Requests')
keymap('<leader>C', "<cmd>lua require('kulala').clear_cached_files()<cr>", 'Clear Kulala Cache')
keymap('<leader>D', "<cmd>lua require('kulala').download_graphql_schema()<cr>", 'Download GQL Schema')
keymap('<leader>q', "<cmd>lua require('kulala').close()<cr>", 'Close Kulala')
keymap('<leader>co', "<cmd>lua require('kulala').copy()<cr>", 'Copy the current request as a curl command')
keymap('<leader>ci', "<cmd>lua require('kulala').from_curl()<cr>", 'Paste curl from clipboard as http request')
