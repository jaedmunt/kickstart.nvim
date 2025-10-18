-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
--
-- NOTE (JM): Define plugins directly in this file (not separate .lua files) to avoid loading errors

local is_windows = vim.loop.os_uname().sysname == 'Windows_NT'

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

-- Yazi Plugin - File explorer with DuckDB extension for viewing Parquet files
-- Manual setup required for duckdb.yazi (Linux/WSL):
--   1. Install DuckDB: https://duckdb.org/docs/installation/
--   2. Clone plugin: git clone https://github.com/wylie102/duckdb.yazi ~/.config/yazi/plugins/duckdb.yazi
--   3. Make executable: chmod +x ~/.config/yazi/plugins/duckdb.yazi/preview.sh
--   4. Configure ~/.config/yazi/yazi.toml:
--      [plugin]
--      prepend_previewers = [
--        { name = "*.parquet", run = "duckdb" },
--      ]
local yazi_plugin = {
  'mikavilpas/yazi.nvim',
  config = function()
    require('yazi').setup {
      open_for_directories = false,
      keymaps = {
        show_help = '<f1>',
      },
    }
  end,
  cmd = { 'Yazi' },
}

-- Image Plugin
local image_plugin = {
  '3rd/image.nvim',
  enabled = not is_windows,
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
    local utils = require('dashboard.utils')
    local uv = vim.loop
    local footer_timer
    local header_timer
    local header_ns = vim.api.nvim_create_namespace('DashboardAnimatedHeader')

    -- - Diagram of a Chain Reaction -
    local header_lines = vim.split(
      [[============================================================================
        - Fall seven times, stand up eight. -
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
        o o        |        o o
  [4]----------------------> o_0_o        |       o_0_o <-----------------[5]
        o~0~o        |        o~0~o
        o o )       |       ( o o
        /        o        \
        /        [1]        \
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
        ~.:.<>.:.~
        .:.~.:.~.:.~.:.<>.:.~.:.~.:.~.:.
        ~.:.~.:.~.:.~.:.~.:.~.:.~.:.~.:.~.:.~.:.~.:.<>.:.~.:.~.:.~.:.~.:.~.:.~.:.~.:.~.:.~.:.~.:.~
=============================================================================]],
      '\n',
      { plain = true }
    )

    local centered_header = utils.center_align(header_lines)
    local header_placeholder = {}
    for idx, line in ipairs(centered_header) do
      if line == '' then
        header_placeholder[idx] = ''
      else
        header_placeholder[idx] = line:gsub('.', ' ')
      end
    end

    local function stop_footer_timer()
      if footer_timer and not footer_timer:is_closing() then
        footer_timer:stop()
        footer_timer:close()
      end
      footer_timer = nil
    end

    local function stop_header_timer()
      if header_timer and not header_timer:is_closing() then
        header_timer:stop()
        header_timer:close()
      end
      header_timer = nil
    end

    local function stop_all_timers()
      stop_footer_timer()
      stop_header_timer()
    end

    local header_animated = false

    vim.api.nvim_create_autocmd('VimLeavePre', {
      once = true,
      callback = function()
        header_animated = false
        stop_all_timers()
      end,
    })

    dashboard.setup {
      theme = 'doom',
      hide = {
        statusline = true,
        tabline = true,
        winbar = true,
      },
      config = {
        header = header_placeholder,
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
          'Time To First Byte: 0.000s',
        },
      },
    }

    vim.api.nvim_create_autocmd('User', {
      pattern = 'DashboardLoaded',
      callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].filetype ~= 'dashboard' then
          return
        end

        stop_all_timers()

        local opened_at = uv.hrtime()
        footer_timer = uv.new_timer()
        footer_timer:start(0, 25, vim.schedule_wrap(function()
          if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].filetype ~= 'dashboard' then
            stop_footer_timer()
            return
          end

          local elapsed = (uv.hrtime() - opened_at) / 1e9
          local formatted = string.format('Time To First Byte: %.3fs', elapsed)
          vim.cmd({ cmd = 'DashboardUpdateFooter', args = { formatted } })
        end))

        local total_header_lines = #centered_header

        -- restore initial header placeholder
        vim.bo[bufnr].modifiable = true
        vim.api.nvim_buf_set_lines(bufnr, 0, total_header_lines, false, header_placeholder)
        vim.bo[bufnr].modifiable = false

        local function schedule_header_line(idx, delay)
          if header_animated then
            vim.bo[bufnr].modifiable = true
            vim.api.nvim_buf_set_lines(bufnr, 0, total_header_lines, false, centered_header)
            for line = 1, total_header_lines do
              vim.api.nvim_buf_add_highlight(bufnr, header_ns, 'DashboardHeader', line - 1, 0, -1)
            end
            vim.bo[bufnr].modifiable = false
            stop_header_timer()
            return
          end

          if idx > total_header_lines then
            stop_header_timer()
            return
          end

          header_timer = uv.new_timer()
          header_timer:start(delay, 0, vim.schedule_wrap(function()
            if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].filetype ~= 'dashboard' then
              stop_header_timer()
              return
            end

            vim.bo[bufnr].modifiable = true
            vim.api.nvim_buf_set_lines(bufnr, idx - 1, idx, false, { centered_header[idx] })
            vim.api.nvim_buf_add_highlight(bufnr, header_ns, 'DashboardHeader', idx - 1, 0, -1)
            vim.bo[bufnr].modifiable = false
            stop_header_timer()

            if idx == total_header_lines then
              header_animated = true
              stop_footer_timer()
              return
            end

            local next_delay = idx >= total_header_lines - 2 and 420 or math.max(20, delay * 0.8)
            schedule_header_line(idx + 1, next_delay)
          end))
        end

        schedule_header_line(1, 140)

        vim.api.nvim_create_autocmd({ 'BufLeave', 'BufWipeout', 'BufHidden' }, {
          buffer = bufnr,
          once = true,
          callback = function()
            header_animated = false
            stop_all_timers()
          end,
        })
      end,
    })
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
  cond = function()
    return vim.fn.executable('playerctl') == 1
  end,
  config = function()
    if vim.fn.executable('playerctl') == 0 then
      vim.notify('music-controls.nvim disabled: playerctl not found', vim.log.levels.WARN)
      return
    end
    require('music-controls').setup()
  end,
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
