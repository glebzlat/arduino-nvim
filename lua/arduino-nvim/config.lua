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

function Config:init()
  self.arduino = self["arduino-cli"] or exepath "arduino-cli"
  self.clangd = self["clangd"] or exepath "clangd"
  self.m_arduino_cli = cli:init(self.arduino)
  self.arduino_config_dir = self.m_arduino_cli:get_arduino_config_dir()

  return self
end

return Config
