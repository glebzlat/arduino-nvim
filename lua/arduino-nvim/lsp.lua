local api = vim.api
local fn = vim.fn

local Lsp = {
  name = "arduino-language-server",
}

---@param fqbn? string FQBN
---@param config ArduinoNvimConfig
---@param cli ArduinoCli
---@return table
function Lsp.create_lsp_cmd(fqbn, config, cli)
  fqbn = fqbn or config.default_fqbn
  -- stylua: ignore start
  local command = {
    fn.exepath(Lsp.name),
    "-cli-config", cli:get_configfile_path(),
    "-clangd", config.clangd,
    "-cli", config.arduino,
    "-fqbn", fqbn
  }
  -- stylua: ignore end

  if config.extra_args then vim.list_extend(command, config.extra_args) end

  return command
end

function Lsp.find_root(filenames, bufnr)
  local dirs = vim.fs.find(filenames, {
    upward = true,
    stop = vim.loop.os_homedir(),
    path = vim.fs.dirname(api.nvim_buf_get_name(bufnr)),
  })
  return vim.fs.dirname(dirs[1])
end

---@param command table
---@param bufnr integer
---@param config ArduinoNvimConfig
function Lsp.start(command, bufnr, config)
  if not config.capabilities then
    local default_capabilities = vim.lsp.protocol.make_client_capabilities()
    default_capabilities.textDocument.semanticTokens = vim.NIL
    default_capabilities.workspace.semanticTokens = vim.NIL
    config.capabilities = default_capabilities
  end

  local filetypes = config.filetypes or { "arduino" }

  local cfg = {
    name = Lsp.name,
    root_dir = (
      config.root_dir
      or Lsp.find_root("sketch.yaml", bufnr)
      or fn.getcwd()
    ),
    cmd = command,
    capabilities = config.capabilities,
    filetypes = filetypes,
  }

  vim.tbl_deep_extend("keep", cfg, config.callbacks)

  vim.lsp.start(cfg, {})
end

return Lsp
