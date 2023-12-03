local Arduino = {}

---Setup
---@param config table
function Arduino:setup(config)
  if not config then
    return
  end
  Arduino_nvim = self
  local m_config = require "arduino-nvim.config"
  self.config = m_config:init(config)

  return self
end

return Arduino
