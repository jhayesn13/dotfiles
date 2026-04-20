--  See `:help vim.keymap.set()`
-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- format only selected in visual mode
vim.keymap.set('v', '<leader>lf', vim.lsp.buf.format, { remap = false })

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Close all other windows and quit without saving
vim.keymap.set('n', '<leader>qa', '<cmd>only | q!<CR>', { desc = 'Close other windows and [Q]uit [A]ll' })

-- Copy path or basename of current file to system clipboard (@+).
vim.keymap.set('n', '<leader>cfp', function()
  vim.fn.setreg('+', vim.fn.expand('%:p'))
end, { desc = '[C]opy [f]ull [p]ath' })

vim.keymap.set('n', '<leader>cfn', function()
  vim.fn.setreg('+', vim.fn.expand('%:t'))
end, { desc = '[C]opy [f]ile [n]ame' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
-- Ws = [W]idth [S]hrink: shrink active window to 1/5 terminal width
vim.keymap.set('n', '<leader>Ws', function()
  local width = math.floor(vim.o.columns / 5)
  vim.cmd('vertical resize ' .. width)
end, { desc = '[W]idth [S]hrink to 1/5 width' })

-- hs = [H]eight [S]hrink: shrink active window to 1/5 terminal height
vim.keymap.set('n', '<leader>hs', function()
  local height = math.floor(vim.o.lines / 5)
  vim.cmd('resize ' .. height)
end, { desc = '[H]eight [S]hrink to 1/5 height' })

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set("n", "gx", function()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()

  -- find markdown link under cursor
  for text, url in line:gmatch("%[([^%]]+)%]%(([^%)]+)%)") do
    local start_col = line:find(text, 1, true)
    local end_col = start_col + #text

    if col >= start_col - 1 and col <= end_col then
      vim.fn.jobstart({ "open", url }) -- macOS
      -- vim.fn.jobstart({ "xdg-open", url }) -- Linux
      -- vim.fn.jobstart({ "start", url }, { detach = true }) -- Windows
      return
    end
  end

  -- fallback for raw URLs
  vim.cmd("normal! gx")
end, { desc = "Open markdown link" })

-- External change review workflow (for AI tools like Cursor)
-- <leader>vd  — open side-by-side diff (buffer vs disk)
-- do           — obtain (accept) a hunk from disk into your buffer
-- ]c / [c      — jump between hunks in diff mode
-- :q           — close the [disk] split (auto-cleans up diff mode)
-- :w!          — save your cherry-picked changes
-- :e           — accept everything from disk as-is
vim.keymap.set('n', '<leader>vd', function()
  local current_file = vim.fn.expand '%:p'
  if current_file == '' or vim.fn.filereadable(current_file) == 0 then
    vim.notify('No file on disk to diff against', vim.log.levels.WARN)
    return
  end

  local orig_buf = vim.api.nvim_get_current_buf()

  vim.cmd 'diffthis'
  vim.cmd 'vnew'

  local disk_buf = vim.api.nvim_get_current_buf()
  vim.bo[disk_buf].buftype = 'acwrite'
  vim.bo[disk_buf].bufhidden = 'wipe'
  vim.bo[disk_buf].buflisted = false
  local lines = vim.fn.readfile(current_file)
  vim.api.nvim_buf_set_lines(disk_buf, 0, -1, false, lines)
  vim.bo[disk_buf].filetype = vim.bo[orig_buf].filetype
  vim.api.nvim_buf_set_name(disk_buf, '[disk] ' .. vim.fn.fnamemodify(current_file, ':t'))
  vim.cmd 'diffthis'

  vim.api.nvim_create_autocmd('BufWriteCmd', {
    buffer = disk_buf,
    callback = function()
      local buf_lines = vim.api.nvim_buf_get_lines(disk_buf, 0, -1, false)
      vim.fn.writefile(buf_lines, current_file)
      vim.bo[disk_buf].modified = false
      vim.notify('Saved to ' .. vim.fn.fnamemodify(current_file, ':~:.'), vim.log.levels.INFO)
    end,
  })

  vim.api.nvim_create_autocmd('BufWipeout', {
    buffer = disk_buf,
    once = true,
    callback = function()
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(orig_buf) then
          vim.api.nvim_buf_call(orig_buf, function()
            vim.cmd 'diffoff'
          end)
          vim.notify('Diff closed — :e to load changes', vim.log.levels.INFO)
        end
      end)
    end,
  })
end, { desc = '[V]iew [d]iff buffer vs disk' })
