local settings = require 'arduino.settings'
local arduino_cli = settings.current.arduino

local Cli = {
  --- Name of arduino-cli configuration file
  configfile = 'arduino-cli.yaml',

  --- Command to print configuration
  config_dump = { arduino_cli, 'config', 'dump' },

  --- Regex for finding the data path from 'arduino-cli config dump' output
  data_regexp_pattern =
  '\\Mdata: \\zs\\[-\\/\\\\.[:alnum:]_~]\\+\\ze\\[[:space:]\\n]'
}

return Cli
