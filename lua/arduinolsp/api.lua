local settings = require 'arduinolsp.settings'
local details = require 'arduinolsp.details'
local utility = require 'arduinolsp.utility'

local Api = {}

---Prints current config
function Api.dump_config()
  if not settings.sketchdir then
    print(('%s Current directory is not a sketch directory')
      :format(details.plugname))
    return
  end

  print(('%s Config Dump\n'):format(details.plugname))

  local fqbn_table = details.get_data_from_config()

  local dir = vim.fn.getcwd()
  local fqbn = fqbn_table[dir]

  print(('Arduino config directory: %q'):format(settings.config_dir))
  print(('Clangd: %q'):format(settings.current.clangd))
  print(('Arduino: %q'):format(settings.current.arduino))
  print(('Current FQBN: %q'):format(fqbn))
end

function Api.set_fqbn(fqbn)
  if not settings.sketchdir then
    details.warn('Current directory is not a sketch directory')
    return
  end

  local data = details.get_data_from_config()
  local dir = vim.fn.getcwd()
  data[dir] = fqbn
  utility.write_file(details.config_file, utility.serialize(data))
end

function Api.clean_config()
  local fqbn_table = details.get_data_from_config()

  print(('%s Clean Config'):format(details.plugname))

  local counter = 0
  for dirname, _ in pairs(fqbn_table) do
    if not details.is_dir(dirname) then
      fqbn_table[dirname] = nil
      counter = counter + 1
    end
  end

  print('Done! Removed ' .. counter
    .. ' nonexistent directories from config')
end

return Api
