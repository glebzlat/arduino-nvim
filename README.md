# Arduino.nvim

Simple Arduino-language-server bootstrapper.

# Requirements

- arduino-cli
- clangd
- arduino-language-server

# Installation

## Lazy.nvim

```lua
{
  "glebzlat/arduino-nvim",
  config = {
    function() require("arduino-nvim").setup() end,
    filetype = "arduino",
  }
}
```

# Settings

This is the list of currently supported settings. Settings with values
`nil|some-type` are optional and are initialized on plugin startup. Settings
with ordinary values are also optional and their values are set by default.

```lua
require("arduino-nvim").setup {
  default_fqbn = "arduino:avr:uno",
  clangd = nil|string, -- path to a clangd executable
  arduino = nil|string, -- path to a arduino-cli executable
  extra_args = nil|table, -- command line args to arduino lsp
  root_dir = nil|string,
  capabilities = nil
  filetypes = {"arduino"},
  callbacks = {
    on_attach = nil|function(client, bufnr)
  }
}
```

# License

`arduino-nvim` licensed under the MIT License. Check the [LICENSE](./LICENSE.md)
file.
