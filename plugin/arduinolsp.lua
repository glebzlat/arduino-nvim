local api = require 'arduinolsp.api'
-- local details = require 'arduinolsp.details'

local command = vim.api.nvim_create_user_command

command('ArduinoDump', function()
  api.dump_config()
end, {})

command('ArduinoSetFQBN', function(arg)
  api.set_fqbn(arg.args)
end, {
  nargs = 1
})

command('ArduinoClean', function()
  api.clean_config()
end, {})
