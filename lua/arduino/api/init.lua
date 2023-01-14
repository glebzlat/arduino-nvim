local settings = require "arduino.settings"
local details = require "arduino-core.details"
-- local utility = require "arduino-core.utility"
local config = require "arduino-core.data"
local ui = require "arduino.ui"
local cli = require "arduino-core.cli"
-- local path = require "arduino-core.path"

local command = vim.api.nvim_create_user_command

local Api = {}

---Returns a table with data or a string with error message
function Api.dump_config()
  local fqbn_table = config.get_data()
  local dir = vim.fn.getcwd()

  print(string.format("%s Config Dump", details.plugname))
  print(string.format("Clangd: %q", settings.current.clangd))
  print(string.format("Arduino: %q", settings.current.arduino))
  print(string.format("FQBN: %q", fqbn_table[dir]))
end

command("ArduinoDump", function()
  Api.dump_config()
end, {})

---Sets the FQBN for the current directory, if ArduinoLSP.nvim is configured
---and returns a message
---@param fqbn string|nil
function Api.set_fqbn(fqbn)
  -- Get list of installed boards
  local boards = cli.board_listall()
  if not boards then return end

  -- If a command is invoked without argument
  if fqbn == "" then
    fqbn = ui.choose_dialog(
      details.get_printable_data(boards, { name = 35 }),
      "Enter the number or FQBN: "
    )

    -- If result is a number
    local result_num = tonumber(fqbn, 10)
    if result_num then
      fqbn = boards[result_num]
      if fqbn then fqbn = fqbn["fqbn"] end
    end
  end

  -- Check if the fqbn exists
  local fqbn_correct = false
  for _, board in ipairs(boards) do
    if fqbn == board["fqbn"] then
      fqbn_correct = true
      break
    end
  end

  -- If result is not correct
  if not fqbn or not fqbn_correct then
    details.warn "Incorrect FQBN"
    return
  end

  local data = config.get_data()
  local dir = vim.fn.getcwd()
  data[dir] = fqbn
  details.current_fqbn = fqbn
  config.write(data)

  details.autocmd_event "ArduinoFqbnReset"

  details.info(string.format("New FQBN is set: %s", fqbn))
end

command("ArduinoSetFQBN", function(arg)
  Api.set_fqbn(arg.args)
end, {
  nargs = "?",
})

command("ArduinoChooseBoard", function(arg)
  Api.set_fqbn(arg.args)
end, {
  nargs = "?",
})

---Removes entries with a directories, which are not exist in a filesystem
function Api.clean_config()
  local data = config.get_data()

  local counter = 0
  for dirname, _ in pairs(data) do
    if not details.is_dir(dirname) then
      data[dirname] = nil
      counter = counter + 1
    end
  end

  config.write(data)

  details.info(string.format("Removed %d entries", counter))
end

command("ArduinoClean", function()
  Api.clean_config()
end, {})

local function get_fqbn(directory)
  local data = config.get_data()
  local fqbn = data[directory]

  if fqbn then return fqbn end

  fqbn = ui.ask_user(("%s enter the FQBN: "):format(details.plugname))
  if not fqbn then fqbn = settings.current.default_fqbn end
  data[directory] = fqbn

  config.write(data)

  return fqbn
end

function Api.configure(root_dir)
  local current = settings.current
  local fqbn = get_fqbn(root_dir)
  local cli_config = cli.get_configfile()

  details.current_fqbn = fqbn
  details.current.configured = true

  details.autocmd_event "ArduinoOnNewConfig"

  -- stylua: ignore start
  local cmd = {
    "arduino-language-server",
    "-cli-config",  cli_config,
    "-clangd",      current.clangd,
    "-cli",         current.arduino,
    "-fqbn",        fqbn,
  }
  -- stylua: ignore end

  vim.list_extend(cmd, settings.current.extra_opts)

  return cmd
end

return Api
