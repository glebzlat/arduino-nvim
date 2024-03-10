if vim.g.arduino_nvim ~= nil then return end
vim.g.arduino_nvim = 1

local config = require("arduino-nvim").config
local arduino_cli = require("arduino-nvim.cli")
local lsp = require("arduino-nvim.lsp")

local api = vim.api

local function setup()
  local bufnr = api.nvim_get_current_buf()

  local lsp_clients = vim.lsp.buf_get_clients(bufnr)
  for id, client in pairs(lsp_clients) do
    if client.name == "clangd" then vim.lsp.stop_client(id) end
  end

  local cli = arduino_cli:init(config.arduino)
  local fqbn = config.default_fqbn
  local arduino_cmd = lsp.create_lsp_cmd(fqbn, config, cli)
  lsp.start(arduino_cmd, bufnr, config)
end

setup()
