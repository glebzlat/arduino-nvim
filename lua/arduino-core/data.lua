local utility = require "arduino-core.utility"
local details = require "arduino-core.details"
local path = require "arduino-core.path"

local Data = {
  deprecated_config_file = path.concat {
    vim.fn.stdpath "data",
    "arduino",
    "arduino.txt",
  },
  config_file = path.concat {
    vim.fn.stdpath "data",
    "arduino",
    "arduino.json",
  },
}

---Reads config file and returns a deserialized data or empty table
---@return table
function Data.get_data()
  local file, deprecated = Data.config_file, false

  if vim.fn.filereadable(Data.deprecated_config_file) == 1 then
    file = Data.deprecated_config_file
    deprecated = true
  end

  local data, message = utility.read_file(file)

  if not data then return {} end

  local fqbn_table = {}

  if deprecated then
    fqbn_table, message = utility.deserialize(data)
  else
    fqbn_table = vim.fn.json_decode(data)
  end

  if not fqbn_table then
    details.warn(("Config deserialization error: %s"):format(message))
    return {}
  end

  return fqbn_table
end

function Data.write(data)
  utility.write_file(Data.config_file, vim.fn.json_encode(data))
end

return Data
