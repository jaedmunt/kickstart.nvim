-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
--
-- NOTE (JM): Define plugins directly in this file (not separate .lua files) to avoid loading errors

-- CSV View Plugin
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

-- Yazi Plugin
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

return {
  csvview_plugin,
  yazi_plugin,
}
