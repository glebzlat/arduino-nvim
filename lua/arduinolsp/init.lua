local settings = require 'arduinolsp.settings'
local utility = require 'arduinolsp.utility'
local path = require 'arduinolsp.path'
local details = require 'arduinolsp.details'

local M = {}

function M.setup(config)
  settings.sketchdir = false

  if not config then return end

  settings.set(config)
  local conf = settings.current

  if utility.is_empty(conf.clangd_path) then
    details.error('clangd_path is empty')
    return
  end

  if utility.is_empty(conf.arduino_cli_config_dir) then
    details.error('arduino_cli_config_dir is empty')
    return
  end

  if vim.fn.isdirectory(conf.config_dir) ~= 1 then
    vim.fn.mkdir(conf.config_dir, '')
  end
end

function M.on_new_config(config, root_dir)
  local m_settings = settings.current
  local fqbn = details.get_fqbn(root_dir)

  local config_dir = path.concat {
    m_settings.arduino_cli_config_dir, 'arduino-cli.yaml'
  }

  settings.config_dir = config_dir
  settings.sketchdir = true

  config.cmd = {
    'arduino-language-server',
    '-cli-config', config_dir,
    '-clangd', m_settings.clangd_path,
    '-fqbn', fqbn
  }
end

function M.dump_config()
  if not settings.sketchdir then
    print(('%s Current directory is not a sketch directory')
      :format(details.plugname))
    return
  end

  print(('%s Config Dump\n'):format(details.plugname))

  local fqbn_table = details.get_data_from_config()

  local dir = vim.fn.getcwd()
  local fqbn = fqbn_table[dir]

  print('Arduino-cli config directory: ' .. settings.config_dir)
  print('Clangd path: ' .. settings.current.clangd_path)

  print('Current FQBN: ' .. fqbn)
end

function M.set_fqbn(fqbn)
  if not settings.sketchdir then
    details.warn('Current directory is not a sketch directory')
    return
  end

  local data = details.get_data_from_config()
  local dir = vim.fn.getcwd()
  data[dir] = fqbn
  utility.write_file(details.config_file, utility.serialize(data))
end

function M.clean_config()
  local fqbn_table = details.get_data_from_config()

  print(('%s Clean Config'):format(details.plugname))

  local counter = 0
  for dirname, _ in pairs(fqbn_table) do
    if vim.fn.isdirectory(dirname) ~= 1 then
      fqbn_table[dirname] = nil
      counter = counter + 1
    end
  end

  print('Done! Removed ' .. counter
    .. ' nonexistent directories from config')
end

-- Helper function
-- Automatically invokes command 'arduino-cli config dump',
-- parses result and returns path to arduino-cli data
-- Unnecessary argument arduinocli_path is intended for
-- the case, if arduino-cli is not placed in $PATH
---@ param arduinocli_path string
function M.get_arduinocli_datapath(arduinocli_path)
  if type(arduinocli_path) ~= 'string' then
    arduinocli_path = 'arduino-cli'
  end

  if vim.fn.executable(arduinocli_path) ~= 1 then
    details.error(("%q executable not found"):format(arduinocli_path))
    return nil
  end

  local output = vim.fn.system({
    arduinocli_path, 'config', 'dump'
  })

  if not output then
    details.error(('no output from %q'):format(arduinocli_path))
    return nil
  end

  local regex = vim.regex(details.data_regexp_pattern)
  local str_beg, str_end = regex:match_str(output)

  if not str_beg then
    details.error(('unexpected data from %q, regex error')
      :format(arduinocli_path))
    return nil
  end

  local datapath = string.sub(output, str_beg, str_end)

  return datapath
end

return M
