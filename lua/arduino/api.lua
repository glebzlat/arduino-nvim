local settings = require "arduino.settings"
local details = require "arduino.details"
local utility = require "arduino.utility"

local Api = {}

---Returns a table with data or a string with error message
---@nodiscard
---@return table|string
function Api.dump_config()
  if not details.current.configured then
    return ("%s Current directory is not a sketch directory"):format(
      details.plugname
    )
  end

  local fqbn_table = details.get_data_from_config()
  local dir = vim.fn.getcwd()

  local output = {
    header = ("%s Config Dump\n"):format(details.plugname),
    -- config_dir = settings.config_dir,
    clangd = settings.current.clangd,
    arduino = settings.current.arduino,
    fqbn = fqbn_table[dir],
  }

  return output
end

---Sets the FQBN for the current directory, if ArduinoLSP.nvim is configured
---and returns a message
---@param fqbn string
---@return string
function Api.set_fqbn(fqbn)
  if not details.current.configured then
    return ("%s Current directory is not a sketch directory"):format(
      details.plugname
    )
  end

  fqbn = details.fqbn_input(fqbn)

  local data = details.get_data_from_config()
  local dir = vim.fn.getcwd()
  data[dir] = fqbn
  details.current_fqbn = fqbn
  utility.write_file(details.config_file, utility.serialize(data))

  details.autocmd_event "ArduinoFqbnReset"

  return ("%s New FQBN is set: %s"):format(details.plugname, fqbn)
end

---Removes entries with a directories, which are not exist in a filesystem
---@return string
function Api.clean_config()
  local data = details.get_data_from_config()

  local counter = 0
  for dirname, _ in pairs(data) do
    if not details.is_dir(dirname) then
      data[dirname] = nil
      counter = counter + 1
    end
  end

  utility.write_file(details.config_file, utility.serialize(data))

  return ("%s Cleaning done: removed %d entries"):format(
    details.plugname,
    counter
  )
end

return Api
