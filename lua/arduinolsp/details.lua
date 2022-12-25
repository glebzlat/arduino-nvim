local settings = require 'arduinolsp.settings'
local utility = require 'arduinolsp.utility'
local path = require 'arduinolsp.path'

local M = {
  plugname = '[ArduinoLSP.nvim]',
  configname = 'arduinolsp_config',
  -- Regex for finding the data path from 'arduino-cli config dump' output
  data_regexp_pattern =
  '\\Mdata: \\zs\\[-\\/\\\\.[:alnum:]_~]\\+\\ze\\[[:space:]\\n]'
}

M.config_file = path.concat {
  settings.current.config_dir, M.configname
}

function M.error(msg)
  vim.notify(M.plugname .. ' error: ' .. msg, vim.log.levels.ERROR)
end

function M.warn(msg)
  vim.notify(M.plugname .. ' warning: ' .. msg, vim.log.levels.WARN)
end

function M.get_data_from_config()
  local data, message = utility.read_file(M.config_file)

  if not data then return {} end

  local fqbn_table = {}
  fqbn_table, message = utility.deserialize(data)

  if not fqbn_table then
    M.vim_warn(('%s Config deserialization error: %s')
      :format(M.plugname, message))
    return {}
  end

  return fqbn_table
end

function M.ask_user_for_fqbn()
  local fqbn = settings._default_settings.default_fqbn

  vim.ui.input({
    prompt = ('%s enter the FQBN: '):format(M.plugname),
  },
    function(input)
      if input then fqbn = input end
    end)

  return fqbn
end

function M.get_fqbn(directory)
  local data = M.get_data_from_config()
  local fqbn = data[directory]

  if fqbn then return fqbn end

  fqbn = M.ask_user_for_fqbn()
  data[directory] = fqbn

  utility.write_file(M.config_file, utility.serialize(data))

  return fqbn

end

return M
