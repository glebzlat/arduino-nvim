local M = {}

function M.is_empty(str)
  if type(str) ~= 'string' or str == '' then
    return true
  end
  return false
end

local function serialize_impl(o, level)
  if type(o) == 'string' then return '"' .. o .. '"' end
  if type(o) ~= 'table' then return tostring(o) end

  local result = ''
  local indent = string.rep('\t', level)

  result = result .. '{\n'
  for key, value in pairs(o) do
    if type(key) ~= 'number' then key = '"' .. key .. '"' end
    result = result .. indent .. '\t[' .. key .. '] = '
    local sublevel = level
    if type(value) == 'table' then
      sublevel = sublevel + 1
    end
    result = result .. serialize_impl(value, sublevel) .. ',\n'
  end
  result = result .. indent .. '}'
  return result
end

function M.serialize(o)
  return serialize_impl(o, 0)
end

local function condfail(cond, ...)
  if not cond then return nil, (...) end
  return ...
end

function M.deserialize(str, vars)
  -- create dummy environment
  local env = vars and setmetatable({}, { __index = vars }) or {}
  -- create function that returns deserialized value(s)
  local f, _err = load("return " .. str, "=deserialize", "t", env)
  if not f then return nil, _err end -- syntax error?
  -- set up safe runner
  local co = coroutine.create(f)
  local hook = function(why)
    error('Deserialization error: ' .. why, 1)
  end
  debug.sethook(co, hook, "", 1000000)
  -- now run the deserialization
  return condfail(coroutine.resume(co))
end

function M.read_file(filename)
  local file, msg = io.open(filename, 'r')
  if not file then return nil, msg end
  local str = file:read("a")
  return str
end

function M.write_file(filename, str)
  local file, msg = io.open(filename, 'w')
  if not file then return nil, msg end
  file, msg = file:write(str)
  if msg then return nil, msg end
  return true
end

return M
