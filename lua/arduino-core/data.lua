local utility = require "arduino-core.utility"
local details = require "arduino-core.details"
local path = require "arduino-core.path"

local Data = {
  config_dir = path.concat { vim.fn.stdpath "data", "arduino" },
}

Data.config_file = path.concat {
  Data.config_dir,
  "arduino.json",
}

function Data.ensure_path()
  if not vim.fn.isdirectory(Data.config_dir) then
    vim.fn.mkdir(Data.config_file)
  end
end

---Reads config file and returns a deserialized data or empty table
---@return table
function Data.get_data()
  local file = Data.config_file
  local data, message = utility.read_file(file)
  if not data then return {} end
  local fqbn_table = vim.fn.json_decode(data)

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
