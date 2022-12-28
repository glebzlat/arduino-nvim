local api = require 'arduino.api'
local details = require 'arduino.details'

local command = vim.api.nvim_create_user_command

command('ArduinoDump', function()
  local output = api.dump_config()

  if not output then
    details.warn('ArduinoDump: output is nil')
    return
  end

  if type(output) == "string" then
    print(output)
    return
  end

  print(output.header)
  print(('Clangd: %q'):format(output.clangd))
  print(('Arduino: %q'):format(output.arduino))
  print(('FQBN: %s'):format(output.fqbn))
end, {})

command('ArduinoSetFQBN', function(arg)
  local msg = api.set_fqbn(arg.args)
  details.on_fqbn_reset()
  print(msg)
end, {
  nargs = 1
})

command('ArduinoClean', function()
  local msg = api.clean_config()
  print(msg)
end, {})
