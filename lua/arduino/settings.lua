local path = require "arduino.path"

local M = {}

local DEFAULT_SETTINGS = {
  ---Plugin will set FQBN of the current sketch to default, if
  ---user not specified it
  ---@type string
  default_fqbn = "arduino:avr:uno",

  ---Directory where Arduino.nvim will store its data
  ---@type string
  config_dir = path.concat { vim.fn.stdpath "data", "arduino_nvim" },

  ---Path to clangd executable
  ---@type string|nil Nil if clangd is not found
  clangd = path.find_path { "clangd" },

  ---Path to arduino-cli executable
  ---@type string|nil Nil if arduino-cli is not found
  arduino = path.find_path { "arduino-cli" },

  ---Data directory of arduino-cli
  ---@type string
  arduino_config_dir = "",

  --Extra options to arduino-language-server
  --@type table
  extra_opts = {},
}

M._default_settings = DEFAULT_SETTINGS
M.current = M._default_settings

function M.set(config)
  M.current = vim.tbl_deep_extend("force", vim.deepcopy(M.current), config)
end

return M
