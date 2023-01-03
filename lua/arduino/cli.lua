local utility = require "arduino.utility"
local settings = require "arduino.settings"
local arduino_cli = settings.current.arduino

local Cli = {
  --- Name of arduino-cli configuration file
  configfile = "arduino-cli.yaml",

  --- Command to print configuration
  config_dump = { arduino_cli, "config", "dump" },

  list_boards = { arduino_cli, "board", "listall" },

  list_connected = { arduino_cli, "board", "list" },

  --- Regex for finding the data path from 'arduino-cli config dump' output
  data_regexp_pattern = "\\Mdata: \\zs\\[-\\/\\\\.[:alnum:]_~]\\+\\ze\\[[:space:]\\n]",

  boardname_regexp = "\\M \\zs\\w\\*:\\w\\*:\\w\\*",
}

---Invokes cli_command, parses its output with pattern and returns
---table with subtables of data strings. If pattern has more than one regexp,
---subtables may contain several strings.
---@param cli_command table|string
---@param pattern table|string
---@return table
---@nodiscard
function Cli.get_data(cli_command, pattern)
  utility.check_type(cli_command, "string", "table")
  utility.check_type(pattern, "string", "table")

  if type(pattern) == "string" then pattern = { pattern } end
  local patterntable_maxn = table.maxn(pattern)

  local raw_data = vim.fn.systemlist(cli_command)

  local result = {}
  for _, line in ipairs(raw_data) do
    local entry
    for _, exp in ipairs(pattern) do
      local regex = vim.regex(exp)
      local s, e = regex:match_str(line)

      if s then
        local str = string.sub(line, s + 1, e)
        if patterntable_maxn > 1 then
          table.insert(entry, str)
        else
          entry = str
        end
      end
    end
    table.insert(result, entry)
  end

  return result
end

---Prints data returned by Cli.get_data. First prints a header if given.
---@param data table
---@param header string|nil
function Cli.print_data(data, header)
  utility.check_type(data, "table")
  utility.check_type(header, "string", "nil")

  if header then print(header) end

  for index, entry in ipairs(data) do
    local str = index .. " - "
    if type(entry) == "string" then
      str = str .. entry
    else
      for _, value in ipairs(entry) do
        str = str .. value .. " "
      end
    end
    print(str)
  end
end

return Cli
