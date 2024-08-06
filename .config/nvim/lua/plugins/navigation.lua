return {
  -- Tmux Navigator
  {
    'christoomey/vim-tmux-navigator',
    cmd = {
      'TmuxNavigateLeft',
      'TmuxNavigateDown',
      'TmuxNavigateUp',
      'TmuxNavigateRight',
      'TmuxNavigatePrevious',
    },
    keys = {
      { '<c-h>', '<cmd><C-U>TmuxNavigateLeft<cr>' },
      { '<c-j>', '<cmd><C-U>TmuxNavigateDown<cr>' },
      { '<c-k>', '<cmd><C-U>TmuxNavigateUp<cr>' },
      { '<c-l>', '<cmd><C-U>TmuxNavigateRight<cr>' },
      { '<c-\\>', '<cmd><C-U>TmuxNavigatePrevious<cr>' },
    },
  },

  -- Harpoon
  {
    'ThePrimeagen/harpoon',
    event = { 'BufReadPre', 'BufNewFile' },
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local harpoon = require('harpoon')

      harpoon:setup()

      vim.keymap.set('n', '<leader>a', function()
        harpoon:list():add()
      end, { desc = 'Add to Harpoon' })

      vim.keymap.set('n', '<C-e>', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = 'Toggle Harpoon' })

      vim.keymap.set('n', '<M-1>', function()
        harpoon:list():select(1)
      end, { desc = 'Select 1st Harpoon' })
      vim.keymap.set('n', '<M-2>', function()
        harpoon:list():select(2)
      end, { desc = 'Select 2nd Harpoon' })
      vim.keymap.set('n', '<M-3>', function()
        harpoon:list():select(3)
      end, { desc = 'Select 3rd Harpoon' })
      vim.keymap.set('n', '<M-4>', function()
        harpoon:list():select(4)
      end, { desc = 'Select 4th Harpoon' })

      vim.keymap.set('n', '<leader><M-1>', function()
        harpoon:list():replace_at(1)
      end, { desc = 'Replace 1st Harpoon' })
      vim.keymap.set('n', '<leader><M-2>', function()
        harpoon:list():replace_at(2)
      end, { desc = 'Replace 2nd Harpoon' })
      vim.keymap.set('n', '<leader><M-3>', function()
        harpoon:list():replace_at(3)
      end, { desc = 'Replace 3rd Harpoon' })
      vim.keymap.set('n', '<leader><M-4>', function()
        harpoon:list():replace_at(4)
      end, { desc = 'Replace 4th Harpoon' })

      -- Toggle previous & next buffers stored within Harpoon list
      vim.keymap.set('n', '<C-S-p>', function()
        harpoon:list():prev({ ui_nav_wrap = true })
      end, { desc = 'Previous Harpoon' })
      vim.keymap.set('n', '<C-S-n>', function()
        harpoon:list():next({ ui_nav_wrap = true })
      end, { desc = 'Next Harpoon' })
    end,
  },

  -- Bookmarks
  {
    'LintaoAmons/bookmarks.nvim',
    enabled = true,
    dependencies = {
      { 'nvim-telescope/telescope.nvim' },
      { 'stevearc/dressing.nvim' },
    },
    keys = {
      { '<leader>bb', '<cmd>BookmarksMark<cr>', mode = { 'n', 'v' }, desc = 'Mark current line into active BookmarkList.' },
      { '<leader>bf', '<cmd>BookmarksGoto<cr>', mode = { 'n', 'v' }, desc = 'Go to bookmark at current active BookmarkList' },
      { '<leader>bt', '<cmd>BookmarksTree<cr>', mode = { 'n', 'v' }, desc = 'Display all bookmarks with tree-view' },
      { '<leader>bc', '<cmd>BookmarksCommands<cr>', mode = { 'n', 'v' }, desc = 'Find and trigger a bookmark command.' },
      { '<leader>br', '<cmd>BookmarksGotoRecent<cr>', mode = { 'n', 'v' }, desc = 'Go to latest visited/created Bookmark' },
    },
    config = function()
      local opts = {
        -- where you want to put your bookmarks db file (a simple readable json file, which you can edit manually as well, dont forget run `BookmarksReload` command to clean the cache)
        json_db_path = vim.fs.normalize(vim.fn.stdpath('data') .. '/bookmarks/bookmarks.db.json'),
        -- This is how the sign looks.
        signs = {
          mark = { icon = '󰃁', color = 'red', line_bg = '#572626' },
        },
        -- optional, backup the json db file when a new neovim session started and you try to mark a place
        -- you can find the file under the same folder
        enable_backup = false,
        -- treeview options
        treeview = {
          bookmark_format = function(bookmark)
            return bookmark.name .. ' [' .. bookmark.location.project_name .. '] ' .. bookmark.location.relative_path -- .. ' : ' .. bookmark.content
          end,
          keymap = {
            quit = { 'q', '<ESC>' },
            refresh = 'R',
            create_folder = 'a',
            tree_cut = 'x',
            tree_paste = 'p',
            collapse = 'o',
            delete = 'd',
            active = 's',
            copy = 'c',
          },
        },
        -- do whatever you like by hooks
        hooks = {
          {
            ---a sample hook that change the working directory when goto bookmark
            ---@param bookmark Bookmarks.Bookmark
            ---@param projects Bookmarks.Project[]
            callback = function(bookmark, projects)
              local project_path
              for _, p in ipairs(projects) do
                if p.name == bookmark.location.project_name then
                  project_path = p.path
                end
              end
              if project_path then
                vim.cmd('cd ' .. project_path)
              end
            end,
          },
        },
      }
      require('bookmarks').setup(opts)
    end,
  },
}
