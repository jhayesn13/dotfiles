-- See `:help lua-guide-autocommands`
-- Handle external file changes: notify instead of auto-reloading so you can
-- review diffs before accepting. Oil buffers are silently cleaned up.
vim.api.nvim_create_autocmd('FileChangedShell', {
  desc = 'Notify on external file changes instead of auto-reloading',
  group = vim.api.nvim_create_augroup('external-change-notify', { clear = true }),
  callback = function(args)
    local bufname = vim.api.nvim_buf_get_name(args.buf)

    if bufname:match '^oil://' then
      vim.schedule(function()
        pcall(vim.api.nvim_buf_delete, args.buf, { force = true })
      end)
      return true
    end

    vim.v.fcs_choice = ''
    vim.notify(
      'File changed on disk: ' .. vim.fn.fnamemodify(bufname, ':~:.') .. '  (<leader>vd to view diff)',
      vim.log.levels.WARN
    )
    return true
  end,
})

-- Auto-change window-local directory to current buffer's directory (like autochdir),
-- but skip oil:// buffers so Oil works correctly.
vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter' }, {
  desc = 'Set lcd to buffer directory (autochdir replacement, oil-safe)',
  group = vim.api.nvim_create_augroup('oil-safe-autochdir', { clear = true }),
  callback = function()
    local bufname = vim.api.nvim_buf_get_name(0)
    local dir

    if bufname:match '^oil://' then
      dir = bufname:gsub('^oil://', '')
    else
      dir = vim.fn.expand '%:p:h'
    end

    if dir and dir ~= '' and vim.fn.isdirectory(dir) == 1 then
      vim.cmd.lcd(dir)
    end
  end,
})

-- Detect external file changes (triggers FileChangedShell above, does NOT reload)
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold' }, {
  desc = 'Detect external file changes without reloading',
  group = vim.api.nvim_create_augroup('detect-file-changes', { clear = true }),
  command = 'silent! checktime',
})

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Create necessary sub-directories when creating a
-- new file through vim and saving with :w in a
-- non-existing file.
local mkdir_group = vim.api.nvim_create_augroup('Mkdir', { clear = true })

vim.api.nvim_create_autocmd('BufWritePre', {
  group = mkdir_group,
  callback = function()
    vim.fn.mkdir(vim.fn.expand '%:p:h', 'p')
  end,
})
-- Disable auto-commenting on new lines
-- vim.api.nvim_create_autocmd('BufEnter', {
--   desc = 'Disable auto-commenting on new lines',
--   group = vim.api.nvim_create_augroup('kickstart-formatoptions', { clear = true }),
--   pattern = '*',
--   callback = function()
--     vim.opt_local.formatoptions-='cro'
--   end,
-- })
