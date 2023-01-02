local settings = require 'arduino.settings'
local utility = require 'arduino.utility'
local path = require 'arduino.path'
local details = require 'arduino.details'

local M = {}

---Setup function
---@param config table
function M.setup(config)
  if not config then return end

  settings.set(config)
  local conf = settings.current

  if not details.is_exe(conf.clangd) then
    details.error(('%s is not an executable'):format(tostring(conf.clangd)))
    return
  end

  if utility.is_empty(conf.arduino_config_dir) then
    details.error('arduino_config_dir is empty')
    return
  end

  if utility.is_empty(conf.config_dir) then
    details.error('Config dir is not specified')
    return
  end

  if not details.is_dir(conf.config_dir) then
    vim.fn.mkdir(conf.config_dir, '')
  end
end

local cli = require 'arduino.cli'

---Configure Arduino.nvim; returns command to call arduino-language-server
---Can be called manually or used with another lsp configurator
---@param root_dir string
---@return table
function M.configure(root_dir)
  local current = settings.current
  local fqbn = details.get_fqbn(root_dir)
  local cli_congfig = path.concat {
    current.arduino_config_dir, cli.configfile
  }

  details.current_fqbn = fqbn
  details.current.configured = true

  pcall(details.autocmd_event, 'ArduinoOnNewConfig')

  return {
    'arduino-language-server',
    '-cli-config', cli_congfig,
    '-clangd', current.clangd,
    '-cli', current.arduino,
    '-fqbn', fqbn
  }
end

---Called by lspconfig, configure Arduino.nvim
---@param config table
---@param root_dir string
function M.on_new_config(config, root_dir)
  config.cmd = M.configure(root_dir)
end

---Calls arduino program, parses its data path and returns.
---Unnecessary argument - path to the program (by default function finds
---path to 'arduino-cli'). If passed, it will be stored in settings and
---called to determine the data path.
---@nodiscard
---@param arduino? string
---@return string|nil
function M.get_arduinocli_datapath(arduino)
  if type(arduino) == "string" then
    if not details.is_exe(arduino) then
      details.error(("%q is not an executable"):format(arduino))
      return nil
    end

    settings.current.arduino = arduino
  else
    arduino = settings.current.arduino
  end

  local output = vim.fn.system(cli.config_dump)

  if not output then
    details.error(('no output from %q'):format(arduino))
    return nil
  end

  local regex = vim.regex(cli.data_regexp_pattern)
  local str_beg, str_end = regex:match_str(output)

  if not str_beg then
    details.error(('unexpected data from %q, regex error')
      :format(arduino))
    return nil
  end

  local datapath = string.sub(output, str_beg, str_end)

  return datapath
end

return M
