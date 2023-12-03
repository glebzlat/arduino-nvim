---@class Path
---Path manipulation utilities.
local Path = {}

---@param path_components string[]
---@return string
function Path.concat(path_components)
  return table.concat(path_components, "/")
end

---@param root string
---@param path string
---@return boolean
function Path.is_subdir(root, path)
  return root == path or path:sub(1, #root + 1) == root .. "/"
end

return Path
