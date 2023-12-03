local cli = require("arduino-nvim.cli")
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
---@param config table
---@return Config
---@nodiscard
function Config:init(config)
  self.arduino = self.validate(config["arduino"], { "string", "nil" })
    or exepath("arduino-cli")
  self.clangd = self.validate(config["clangd"], { "string", "nil" })
    or exepath("clangd")
  self.extra_opts = self.validate(config["extra_opts"], { "table", "nil" })
  self.default_fqbn = self.validate(config["default_fqbn"], { "string", "nil" })
    or self.default_fqbn

  self.m_arduino_cli = cli:init(self.arduino)
  self.arduino_config_dir = self.m_arduino_cli:get_arduino_config_dir()

  return self
end

---Validate type of a value against types. `types` may be a table of types or
---a single type. If `type(value)` found in `types`, then the value is returned.
---Otherwise, exception will be raised.
---@param value any
---@param types table|type
---@return any
---@nodiscard
function Config.validate(value, types)
  if type(types) ~= "table" then
    if type(value) == type(types) then return value end
  else
    for _, t in ipairs(types) do
      if type(value) == t then return value end
    end
  end
  error(
    "Config.validate: expected value of type "
      .. table.concat(types, "|")
      .. ", got value of type '"
      .. type(value)
      .. "'"
  )
end

return Config
