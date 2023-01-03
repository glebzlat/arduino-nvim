-- file from mason.nvim
-- mason-core/path.lua

local utility = require "arduino.utility"

local sep = (function()
  ---@diagnostic disable-next-line: undefined-global
  if jit then
    ---@diagnostic disable-next-line: undefined-global
    local os = string.lower(jit.os)
    if os == "linux" or os == "osx" or os == "bsd" then
      return "/"
    else
      return "\\"
    end
  else
    return string.sub(package.config, 1, 1)
  end
end)()

local M = {}

---@param path_components string[]
---@return string
function M.concat(path_components)
  return table.concat(path_components, sep)
end

---@path root_path string
---@path path string
function M.is_subdirectory(root_path, path)
  return root_path == path
    or path:sub(1, #root_path + 1) == root_path .. sep
end

function M.find_path(programs)
  for _, programname in ipairs(programs) do
    if utility.is_empty(programname) then
      error("find_path: incorrect data", 1)
      return nil
    end

    local programpath = vim.fn.exepath(programname)

    if not utility.is_empty(programpath) then return programpath end
  end

  return nil
end

return M
