-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
--
-- NOTE (JM): Define plugins directly in this file (not separate .lua files) to avoid loading errors

-- -- CSV View Plugin - for csv files. Open a csv and use CsvViewToggle to enable the view.

-- Primary commands for the csvview.nvim plugin in Neovim are :CsvViewEnable, :CsvViewDisable, and :CsvViewToggle.
--  These commands allow users to enable, disable, and toggle the CSV view mode, respectively.
--  The :CsvViewToggle command can also accept options to customize the view, such as specifying a delimiter, display mode, or header line number.
--  For example, :CsvViewToggle delimiter=, display_mode=border header_lnum=1 enables the CSV view with a comma delimiter, border display mode, and the first line as the header.
local csvview_plugin = {
  'hat0uma/csvview.nvim',
  ft = { 'csv', 'tsv' },
  config = function()
    require('csvview').setup {
      align = 'center',
      highlight = true,
    }
  end,
}

-- Yazi Plugin - File explorer. Installed to use with CsvView
local yazi_plugin = {
  'mikavilpas/yazi.nvim',
  dependencies = {
    'wylie102/duckdb.yazi',
  },
  config = function()
    require('yazi').setup()
  end,
  cmd = { 'Yazi' },
}

-- Image Plugin
local image_plugin = {
  '3rd/image.nvim',
  dependencies = { 'vhyrro/luarocks.nvim' }, -- magick installed for rendering
  build = false,
  opts = {
    processor = 'magick_cli', -- ImageMagick CLI backend
  },
  config = function()
    require('image').setup {
      backend = 'kitty', -- or 'ueberzug' / 'wezterm'
      integrations = {
        markdown = {
          enabled = true,
          only_render_image_at_cursor = false,
        },
      },
    }
  end,
}

-- Jupyter Notebook plugin (Molten)
local molten_plugin = {
  'benlubas/molten-nvim',
  build = ':UpdateRemotePlugins', -- Required for Jupyter integration
  dependencies = {
    '3rd/image.nvim', -- Enables inline image support if possible
  },
  config = function()
    vim.g.molten_auto_open_output = true
    vim.g.molten_image_provider = 'image' -- Use image.nvim for display of images in the notebook
    vim.g.molten_wrap_output = true
  end,
  ft = { 'python', 'jupyter' },
}

local lsp_with_coq_plugin = {
  'neovim/nvim-lspconfig', -- REQUIRED: for native Neovim LSP integration
  lazy = false, -- REQUIRED: tell lazy.nvim to start this plugin at startup
  dependencies = {
    -- main one
    { 'ms-jpq/coq_nvim', branch = 'coq' },

    -- 9000+ Snippets
    { 'ms-jpq/coq.artifacts', branch = 'artifacts' },

    -- lua & third party sources -- See https://github.com/ms-jpq/coq.thirdparty
    -- Need to **configure separately**
    { 'ms-jpq/coq.thirdparty', branch = '3p' },
    -- - shell repl
    -- - nvim lua api
    -- - scientific calculator
    -- - comment banner
    -- - etc
  },
  init = function()
    vim.g.coq_settings = {
      auto_start = true, -- if you want to start COQ at startup
      -- Your COQ settings here
    }
  end,
  config = function()
    -- Your LSP settings here
  end,
}

-- Don't change the ascii art. It is formatted correctly
--https://ascii.co.uk/art
local dashboard_plugin = {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  dependencies = {
    { 'nvim-tree/nvim-web-devicons' },
  },
  config = function()
    local dashboard = require('dashboard')

    dashboard.setup {
      theme = 'doom',
      hide = {
        statusline = true,
        tabline = true,
        winbar = true,
      },
      config = {
        header = vim.split(
      [[============================================================================
      - Diagram of a Chain Reaction -
      -------------------------------
      |
      |
      |
      |
      [1]------------------------------> o

      . o o .
[2]---->. o_0_o . 
      . o 0 o .
      . o o .

      |
      \|/
      ~

      . o o. .o o .
[3]--> . o_0_o"o_0_o .
      . o 0 o~o 0 o .
      . o o.".o o .
      |
      /    |    \
      |/_    |    _\|
      ~~     |     ~~
      |
      o o         |        o o
[4]----------------------> o_0_o        |       o_0_o <-----------------[5]
      o~0~o        |       o~0~o
      o o )       |      ( o o
      /        o       \
      /        [1]       \
      /                    \
      /                      \
      /                        \
o [1]                  [1] o
      . o o .            . o o .            . o o .
      . o_0_o .          . o_0_o .          . o_0_o .
      . o 0 o .  <-[2]-> . o 0 o . <-[2]->  . o 0 o .
      . o o .            . o o .            . o o .

      /                    |                    \
      |/_                   \|/                   _\|
      ~~                     ~                     ~~
============================================================================]],
 '\n', { plain = true }),
        center = {
          {
            icon = ' ',
            icon_hl = 'DashboardIcon',
            desc = 'Find File',
            desc_hl = 'DashboardDesc',
            key = 'f',
            key_hl = 'DashboardKey',
            keymap = 'SPC f f',
            action = 'Telescope find_files',
          },
          {
            icon = ' ',
            icon_hl = 'DashboardIcon',
            desc = 'Recent Files',
            desc_hl = 'DashboardDesc',
            key = 'r',
            key_hl = 'DashboardKey',
            keymap = 'SPC f r',
            action = 'Telescope oldfiles',
          },
          {
            icon = ' ',
            icon_hl = 'DashboardIcon',
            desc = 'Config',
            desc_hl = 'DashboardDesc',
            key = 'c',
            key_hl = 'DashboardKey',
            keymap = 'SPC f p',
            action = 'edit $MYVIMRC',
          },
          {
            icon = ' ',
            icon_hl = 'DashboardIcon',
            desc = 'Update Plugins',
            desc_hl = 'DashboardDesc',
            key = 'u',
            key_hl = 'DashboardKey',
            keymap = 'SPC u',
            action = 'Lazy sync',
          },
          {
            icon = ' ',
            icon_hl = 'DashboardIcon',
            desc = 'Quit',
            desc_hl = 'DashboardDesc',
            key = 'q',
            key_hl = 'DashboardKey',
            action = 'qa',
          },
        },
        footer = {
          'Time To First Byte.',
        },
      },
    }
  end,
}

local feed_plugin = {
  'neo451/feed.nvim',
  cmd = 'Feed',
  -- stylua: ignore start
  opts = {
    -- see :h feed.config for configuration details
  },
  -- stylua: ignore end
}

local music_controls_plugin = {
  'AntonVanAssche/music-controls.nvim',
}

local luxmotion_plugin = {
  'LuxVim/nvim-luxmotion',
  config = function()
    require('luxmotion').setup {
      cursor = {
        duration = 250, -- Cursor animation duration (ms)
        easing = 'ease-out', -- Cursor easing function
        enabled = true,
      },
      scroll = {
        duration = 400, -- Scroll animation duration (ms)
        easing = 'ease-out', -- Scroll easing function
        enabled = true,
      },
      performance = {
        enabled = false, -- Enable performance mode
      },
      keymaps = {
        cursor = true, -- Enable cursor motion keymaps
        scroll = true, -- Enable scroll motion keymaps
      },
    }
  end,
}

local vim_be_good_plugin = {
  'ThePrimeagen/vim-be-good',
  cmd = 'VimBeGood',
}

local leetcode_plugin = {
  'kawre/leetcode.nvim',
  cmd = 'Leet',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
  },
  opts = {
    lang = 'rust',
    plugins = {
      non_standalone = true,
    },
    storage = {
      home = vim.fn.stdpath('data') .. '/leetcode',
      cache = vim.fn.stdpath('cache') .. '/leetcode',
    },
    console = {
      open_on_runcode = true,
    },
  },
}

return {
  csvview_plugin,
  yazi_plugin,
  image_plugin,
  molten_plugin,
  lsp_with_coq_plugin,
  dashboard_plugin,
  feed_plugin,
  music_controls_plugin,
  luxmotion_plugin,
  vim_be_good_plugin,
  leetcode_plugin,
}
