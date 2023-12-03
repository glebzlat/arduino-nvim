local path = require("arduino-nvim.path_util")
local path_concat = path.concat
local json_decode = vim.json.decode

---@class Cli
---Interacts with `arduino-cli`.
local Cli = {}

---Initialize Cli
---@param arduino_exe string `arduino-cli` executable
---@return Cli
---@nodiscard
function Cli:init(arduino_exe)
  self.arduino = arduino_exe
  return self
end

---Intended for `arduino-cli`. Takes command `cmd`, appends `--format json`,
---invokes it and returns decoded result.
---@param cmd table
---@return table|nil
---@nodiscard
function Cli:invoke_cli(cmd)
  cmd:insert("---format")
  cmd:insert("json")
  local ok, data = pcall(vim.fn.system, cmd)
  if not ok then return nil end
  ok, data = pcall(json_decode, data)
  if not ok then return nil end
  return data
end

---Returns arduino-cli config directory. `nil` if failed.
---@return string|nil
---@nodiscard
function Cli:get_arduino_config_dir()
  local cmd = { self.arduino, "config", "dump" }
  local data = self:invoke_cli(cmd)
  if not data then return nil end
  return data["directories"]["data"]
end

---Returns path of a `arduino-cli.yaml` file. `nil` if failed.
---@return string|nil
---@nodiscard
function Cli:get_configfile_path()
  local filename = "arduino-cli.yaml"
  local config_path = self:get_arduino_config_dir()
  if not config_path then return nil end
  return path_concat({ config_path, filename })
end

---Returns result of `arduino-cli board listall` command in json.
---@return table|nil
---@nodiscard
function Cli:get_installed_boards()
  local cmd = { self.arduino, "board", "listall" }
  return self:invoke_cli(cmd)
end

---Sorts `board listall` result by platform.
---Resulting table's schema:
---```
---boards = {
---  platform = {
---    name = "fqbn",
---    ...
---  },
---  ...
---}
---```
---@param boards table
---@return table
---@nodiscard
function Cli.sort_boards_by_platform(boards)
  local platforms = {}
  for _, board in ipairs(boards) do
    local id = board["platform"]["id"]
    if not platforms[id] then platforms[id] = {} end
    platforms[id][boards["name"]] = boards["fqbn"]
  end
  return platforms
end

return Cli
