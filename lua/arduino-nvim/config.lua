local cli = require "arduino-nvim.cli"
local exepath = vim.fn.exepath

---@class Config
---@field default_fqbn string Default FQBN
---@field clangd string|nil Path to `clangd` exe
---@field arduino string|nil Path to `arduino-cli` exe
---@field arduino_config_dir string|nil `arduino-cli` data dir
---@field extra_opts table Extra options to arduino-language-server
---@field m_arduino_cli Cli Cli
local Config = {
  default_fqbn = "arduino:avr:uno",
  clangd = "",
  arduino = "",
  arduino_config_dir = "",
  extra_opts = {},
}

---Initialize config
---TODO: Add config validation
---@param config table
---@return Config
---@nodiscard
function Config:init(config)
  self.arduino = config["arduino"] or exepath "arduino-cli"
  self.clangd = config["clangd"] or exepath "clangd"
  self.extra_opts = config["extra_opts"]
  self.default_fqbn = config["default_fqbn"]

  self.m_arduino_cli = cli:init(self.arduino)
  self.arduino_config_dir = self.m_arduino_cli:get_arduino_config_dir()

  return self
end

return Config
