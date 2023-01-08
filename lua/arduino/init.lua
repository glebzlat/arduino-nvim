local settings = require "arduino.settings"

local M = {
  configured = false,
}

---Setup function
---@param config table
function M.setup(config)
  if not config then return end
  settings.set(config)
end

---Configure Arduino.nvim; returns command to call arduino-language-server
---Can be called manually or used with another lsp configurator
---@param root_dir string
---@return table
function M.configure(root_dir)
  return require "arduino.api".configure(root_dir)
end

---Called by lspconfig, configure Arduino.nvim
---@param config table
---@param root_dir string
function M.on_new_config(config, root_dir)
  config.cmd = M.configure(root_dir)
end

---Please, do not use this function, it is deprecated and will be deleted.
---@return nil
---@deprecated
function M.get_arduinocli_datapath()
  return nil
end

return M
