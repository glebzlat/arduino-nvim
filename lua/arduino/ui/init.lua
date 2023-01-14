---User input
---@param prompt string
---@return string
---@nodiscard
local function ask_user_cmd(prompt)
  assert(type(prompt) == "string")
  local result
  vim.ui.input({ prompt = prompt }, function(input)
    result = input
  end)
  return result
end

local function choose_dialog_cmd(list, prompt)
  for _, value in ipairs(list) do
    print(value)
  end
  return ask_user_cmd(prompt)
end


local Ui = {
  ask_user = ask_user_cmd,
  choose_dialog = choose_dialog_cmd
}

return Ui
