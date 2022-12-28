local path = require 'arduino.path'

local M = {}

local DEFAULT_SETTINGS = {
  default_fqbn = 'arduino:avr:uno',
  config_dir = path.concat { vim.fn.stdpath 'data', 'arduino_nvim' },
  -- clangd = find_for_clangd(),
  clangd = path.find_path { 'clangd' },
  arduino = path.find_path { 'arduino-cli' },
  arduino_config_dir = '',
  after_fqbn_reset = function() end
}

M._default_settings = DEFAULT_SETTINGS
M.current = M._default_settings
M.sketchdir = false

function M.set(config)
  M.current = vim.tbl_deep_extend('force',
    vim.deepcopy(M.current), config)
end

return M
