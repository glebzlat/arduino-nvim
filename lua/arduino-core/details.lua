local settings = require "arduino.settings"

local M = {
  plugname = "[ArduinoLSP.nvim]",

  current = {
    configured = false,
    fqbn = settings.current.default_fqbn,
    programmer = "",
    port = "",
  },
}

---Error
---@param msg string
function M.error(msg)
  vim.notify(M.plugname .. " error: " .. msg, vim.log.levels.ERROR)
end

---Warning
---@param msg string
function M.warn(msg)
  vim.notify(M.plugname .. " warning: " .. msg, vim.log.levels.WARN)
end

---Info
---@param msg string
function M.info(msg)
  vim.notify(M.plugname .. ": " .. msg, vim.log.levels.INFO)
end

---Safely invokes autocommand with event event
---@param event string
function M.autocmd_event(event)
  pcall(vim.cmd, "doautocmd User " .. event)
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

---Takes a list of assosiative arrays and an assosiative array of column
---widths and returns list of aligned strings.
---@param data table
---@param widths table
---@return table
function M.get_printable_data(data, widths)
  local lines = {}

  local maxn = table.maxn(data)
  local number_size = 1
  while maxn >= math.pow(10, number_size) do
    number_size = number_size + 1
  end
  number_size = number_size + 2
  local idx_template = "%-" .. tostring(number_size) .. "s"

  for index, element in ipairs(data) do
    lines[index] = string.format(idx_template, index .. ") ")
    for key, value in pairs(element) do
      local w = vim.fn.strdisplaywidth(value)
      local len = #value
      local delta = len - w

      local width = widths[key]
      if not width then
        width = 0
        widths[key] = width
      end

      local spcw = width + delta - len
      if spcw <= 0 then spcw = 1 end
      local spc = string.rep(" ", spcw)

      lines[index] = lines[index] .. value .. spc
    end
  end

  return lines
end

return M
