# Arduino.nvim

Simple wrapper for arduino-language-server, written in Lua.
Arduino-language-server is not fully bootstrapped out of the box,
it requires the FQBN (Fully Qualified Board Name) and the
arduino-cli config. This wrapper stores configs for lsp for each
sketch directory and manages FQBNs.

*:zap::zap::zap:Plugin is under development. Something may not work,
documentation may differ with the code and some features may be undocumented
at all. If you found a mistake, or you have an idea how to improve
*`Arduino.nvim`*, feel free to create an issue or open a pull request.
Enjoy!:zap::zap::zap:*

# Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Setup](#setup)
    - [Clang via Mason.nvim](#clang-via-mason.nvim)
- [Commands](#commands)
- [Configuration](#configuration)
    - [Autocommands](#autocommands)
- [Limitations](#limitations)

# Requirements

Due to the simplicity, `Arduino.nvim` does not have a lot of requirements.
All requirements are:

- neovim `>= 0.7.0` (but maybe it will work on older versions)
- arduino-cli
- clangd
- arduino-language-server

# Installation

## [Packer](https://github.com/wbthomason/packer.nvim)

```lua
use 'edKotinsky/arduino.nvim'
```

## vim-plug

```vim
Plug 'edKotinsky/arduino.nvim'
```

# Setup

You must manually specify path to clangd and path to arduino, if they're
not installed in your $PATH. Plugin will try to locate clangd, arduino-cli 
and arduino-cli data path automatically, however, if they're not found, 
corresponding fields will be empty.

```lua
require 'arduino'.setup({
    
})
```

```lua
require 'lspconfig' ['arduino_language_server'].setup {
    on_new_config = arduino.on_new_config,
}
```

This plugin does not depend on nvim-lspconfig. However, I have not tested it
with another configurators, so, if you wanna help, you can find a way to use
`Arduino.nvim` with your configurator and test it.

Plugin will configure the LSP command, and fully configure yourself,
when `arduino.on_new_config()` called.

Also you can use `arduino.configure()` function. It gets a root directory as
an argument and returns command to invoke LSP as a list. I think, it is may
be useful in case if you're using something different than nvim-lspconfig.

```lua
local arduino_cmd = require 'arduino'.configure(vim.fn.getcwd())
```

## Clangd via Mason.nvim

If you have not clangd installed in your system, but it is installed via
[mason.nvim](https://github.com/williamboman/mason.nvim), you can get a
[package path](https://github.com/williamboman/mason.nvim/blob/main/doc/reference.md#packageget_install_path):

```lua
local clangd_path = require 'mason-registry'.get_package('clangd'):get_install_path()

require 'arduino'.setup({
    clangd = clangd_path,
    -- other settings
})
```

# Commands

- `:ArduinoSetFQBN [fqbn]` - set fqbn to the current sketch. You can create
autocommand to be executed right after this command performed. So you don't
need to restart nvim after resetting FQBN, see [autocommands](#autocommands).
Without argument, will present choose dialog.
- `:ArduinoChooseBoard [fqbn]` - same as `:ArduinoSetFQBN`.
- `:ArduinoDump` - prints current config
- `:ArduinoClean` - removes nonexistent sketch directories from config

# Configuration

`Arduino.nvim` is configured, when `configure()` or `on_new_config()`
functions called. Normally it will happen only if lspconfig (or another
configurator) called they.

You can check inside your config, is `Arduino.nvim` configured:

```lua
require 'arduino'.configured
```

## Autocommands

`Arduino.nvim` has its own events to allow user to customize its behaviour.

- `ArduinoFqbnReset` - After `:ArduinoSetFQBN` and `:ArduinoChooseBoard`.
You can automatically restart LSP to apply board change:

```lua
vim.api.nvim_create_autocmd('User', {
  pattern = 'ArduinoFqbnReset',
  callback = function()
    vim.cmd('LspRestart')
  end
})
```

# Limitations

To initialize `Arduino.nvim` in a sketch directory, you need to
open .ino file first (of course, if you have any files except .ino).

If `Arduino.nvim` is not initialized, invocation of
`:ArduinoDump` and `:ArduinoSetFQBN` commands has no effect.

If you have clangd installed and you open a C/C++ file while `Arduino.nvim`
configured, nvim-lspconfig will attach both clangd and arduino-language-server.
Clangd without compile_commands.json will give a lot of errors. It is not
a mistake, just clangd is not configured. Stop it with `:LspStop clangd`.
*Fix will be soon*.

If your arduino-language-server is really slow, it is not caused by the plugin.
Though, I will work on it.
