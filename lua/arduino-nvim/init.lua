local path = require("arduino-nvim.path")

local validate = vim.validate
local fn = vim.fn

local _Arduino = {}

---@class ArduinoLSPCallbacks
---@field on_attach function(client, bufnr: integer)

---@class ArduinoNvimConfig
---@field config_path? string Path to a dir/file, where plugin will store
---                           its data
---@field default_fqbn? string Default FQBN
---@field clangd? string Path to `clangd` executable
---@field arduino? string Path to `arduino-cli` executable
---@field extra_args? table Extra command line arguments to arduino-lsp
---@field root_dir? string Path to the project root
---@field capabilities? table Client capabilities
---@field filetypes? table LSP filetypes
---@field callbacks ArduinoLSPCallbacks
local _Config = {
  config_path = path.concat({ fn.stdpath("data"), "arduino-nvim.json" }),
  default_fqbn = "arduino:avr:uno",
}

_Arduino.config = _Config

---Setup
---Creates global variable `Arduino_nvim`, which points to an Arduino instance
---@param config? ArduinoNvimConfig
function _Arduino.setup(config)
  if vim.bo.filetype == "arduino" then
    config = config or {}
    validate({
      default_fqbn = { config.default_fqbn, "string", true },
      clangd = { config.clangd, "string", true },
      arduino = { config.arduino, "string", true },
      extra_args = { config.extra_args, "table", true },
      root_dir = { config.root_dir, "string", true },
      capabilities = { config.capabilities, "table", true },
      filetypes = { config.filetypes, "table", true },
      callbacks = { config.callbacks, "table", true },
    })

    if config.callbacks then
      local callbacks = config.callbacks
      validate({
        on_attach = {callbacks.on_attach, "function", true}
      })
    else
      config.callbacks = {}
    end

    _Arduino.config = vim.tbl_deep_extend("force", _Arduino.config, config)
    local _config = _Arduino.config
    _config.clangd = _config.clangd or fn.exepath("clangd")
    _config.arduino = _config.arduino or fn.exepath("arduino-cli")
  end
end

return _Arduino
