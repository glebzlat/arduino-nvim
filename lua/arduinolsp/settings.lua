local M = {}

local DEFAULT_SETTINGS = {
  default_fqbn = 'arduino:avr:uno',
  config_dir = vim.fn.stdpath 'data' .. '/arduinolsp',
  clangd_path = '',
  arduino_cli_config_dir = '',
}

M._default_settings = DEFAULT_SETTINGS
M.current = M._default_settings
M.sketchdir = false

function M.set(config)
  M.current = vim.tbl_deep_extend('force',
    vim.deepcopy(M.current), config)
end

return M
