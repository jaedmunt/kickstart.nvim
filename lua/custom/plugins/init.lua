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
          only_render_image_at_cursor = false
        }
      }
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

return {
  csvview_plugin,
  yazi_plugin,
  image_plugin,
  molten_plugin,
}
