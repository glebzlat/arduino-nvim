local settings = require 'arduino.settings'
local utility = require 'arduino.utility'
local path = require 'arduino.path'
local cli = require 'arduino.cli'

local M = {
  plugname = '[ArduinoLSP.nvim]',
  configname = 'arduinolsp_config',
}

M.config_file = path.concat {
  settings.current.config_dir, M.configname
}

function M.error(msg)
  vim.notify(M.plugname .. ' error: ' .. msg, vim.log.levels.ERROR)
end

function M.warn(msg)
  vim.notify(M.plugname .. ' warning: ' .. msg, vim.log.levels.WARN)
end

---Returns true, if o is an executable, false otherwise
---@param o string
---@nodiscard
---@return boolean
function M.is_exe(o)
  if not o then return false end
  assert(type(o) == "string")
  return vim.fn.executable(o) == 1
end

---Returns true, if o is a directory, false otherwise
---@nodiscard
---@param o string
---@return boolean
function M.is_dir(o)
  if not o then return false end
  assert(type(o) == "string")
  return vim.fn.isdirectory(o) == 1
end

---Reads config file and returns a deserialized data or empty table
---@return table
function M.get_data_from_config()
  local data, message = utility.read_file(M.config_file)

  if not data then return {} end

  local fqbn_table = {}
  fqbn_table, message = utility.deserialize(data)

  if not fqbn_table then
    M.warn(('Config deserialization error: %s'):format(message))
    return {}
  end

  return fqbn_table
end

function M.get_boardlist()
  local regex = vim.regex(cli.boardname_regexp)
  local boards = vim.fn.systemlist(cli.list_boards)
  local fqbns = {}
  for i, line in ipairs(boards) do
    if i ~= 1 and not utility.is_empty(line) then
      local s, e = regex:match_str(line)
      if not s then
        M.warn('get_boardlist regexp error')
        break
      end
      fqbns[i - 1] = string.sub(line, s + 1, e)
    end
  end
  return { fqbns = fqbns, boards = boards }
end

local function print_list(list)
  for index, value in ipairs(list) do
    print(index .. ' - ' .. value)
  end
end

---User input
---@param prompt string
---@return string
---@nodiscard
function M.ask_user(prompt)
  assert(type(prompt) == "string")
  local result
  vim.ui.input({ prompt = prompt },
    function(input) result = input end)
  return result
end

---Gets user input and checks if it is correct; also can provide a list
---@param str string
---@return string
function M.fqbn_input(str)
  assert(type(str) == "string" or not str)

  local boardlist = M.get_boardlist()
  local fqbns = boardlist.fqbns
  local boards = boardlist.boards

  local num
  if str == 'list' or utility.is_empty(str) then
    -- print(utility.serialize(boardlist))
    print_list(boards)
    str = M.ask_user('Enter the number or FQBN: ')
    num = tonumber(str, 10)
  end

  for index, value in ipairs(fqbns) do
    if num == index or str == value then
      return value
    end
  end

  local default = settings.current.default_fqbn
  M.warn(('Incorrect FQBN: %s, defaulting to %s')
    :format(str, default))
  return default
end

function M.get_fqbn(directory)
  local data = M.get_data_from_config()
  local fqbn = data[directory]

  if fqbn then return fqbn end

  fqbn = M.ask_user(('%s enter the FQBN: '):format(M.plugname))
  fqbn = M.fqbn_input(fqbn)
  data[directory] = fqbn

  utility.write_file(M.config_file, utility.serialize(data))

  return fqbn

end

return M
