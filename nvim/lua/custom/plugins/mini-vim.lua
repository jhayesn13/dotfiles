return { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      -- Diff against last saved version on disk — no git commit needed
      local minidiff = require 'mini.diff'
      minidiff.setup {
        view = {
          style = 'sign',
          signs = { add = '+', change = '~', delete = '_' },
        },
        source = minidiff.gen_source.save(),
      }

      vim.keymap.set('n', ']h', function()
        require('mini.diff').goto_hunk 'next'
      end, { desc = 'Jump to next [h]unk' })

      vim.keymap.set('n', '[h', function()
        require('mini.diff').goto_hunk 'prev'
      end, { desc = 'Jump to previous [h]unk' })

      vim.keymap.set('n', '<leader>ha', function()
        require('mini.diff').apply_hunk()
      end, { desc = '[H]unk [a]pply (stage)' })

      vim.keymap.set('n', '<leader>hr', function()
        require('mini.diff').reset_hunk()
      end, { desc = '[H]unk [r]eset' })

      vim.keymap.set('n', '<leader>ho', function()
        require('mini.diff').toggle_overlay()
      end, { desc = '[H]unk [o]verlay toggle' })
    end,
  }
