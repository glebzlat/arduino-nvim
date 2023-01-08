local settings = require "arduino.settings"
local arduino_cli = settings.current.arduino
local path = require "arduino-core.path"

local commands = {
  config_dump = { arduino_cli, "config", "dump", "--format", "json" },

  list_boards = { arduino_cli, "board", "listall", "--format", "json" },

  list_connected = { arduino_cli, "board", "list", "--format", "json" },
}

local configfile = "arduino-cli.yaml"

local Cli = {}

---Invokes a command, gets its output in json format and returns value of an
---entry. If not entry, then returns json decoded table. Entry may be a list
---of entries.
---@param command table|string
---@param entry string|table|nil
---@return string|table|nil
---@nodiscard
local function get_data(command, entry)
  local ok, data = pcall(vim.fn.system, command)
  ok, data = pcall(vim.fn.json_decode, data)
  if not ok then return nil end
  if not entry then return data end

  if type(entry) == "string" then return data[entry] end

  for _, value in ipairs(entry) do
    data = data[value]
    if not data then return nil end
  end
  return data
end

---Get path to arduino-cli.yaml
---@return string
function Cli.get_configfile()
  local data = get_data(commands.config_dump, { "directories", "data" })
  if not data or type(data) ~= "string" then return configfile end
  return path.concat { data, configfile }
end

---Get list of installed boards:
---{
---  [n] = {
---    ['name'] = '...',
---    ['fqbn'] = '...',
---  },
---  ...
---}
---@return table|nil
function Cli.board_listall()
  local data = get_data(commands.list_boards)
  if not data then return nil end
  data = data["boards"]
  for _, value in ipairs(data) do
    value["platform"] = nil
  end
  return data
end

---Get list of connected boards
---@return table|nil
function Cli.connected_boards()
  local data = get_data(commands.list_connected)
  if type(data) ~= "table" then return nil end
  return data
end

return Cli
