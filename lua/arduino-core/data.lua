local utility = require "arduino-core.utility"
local details = require "arduino-core.details"
local path = require "arduino-core.path"

local Data = {
  config_file = path.concat {
    vim.fn.stdpath "data",
    "arduino",
    "arduino.txt",
  },
}

---Reads config file and returns a deserialized data or empty table
---@return table
function Data.get_data()
  local data, message = utility.read_file(Data.config_file)

  if not data then return {} end

  local fqbn_table = {}
  fqbn_table, message = utility.deserialize(data)

  if not fqbn_table then
    details.warn(("Config deserialization error: %s"):format(message))
    return {}
  end

  return fqbn_table
end

function Data.write(data)
  utility.write_file(Data.config_file, utility.serialize(data))
end

return Data
