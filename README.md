# Arduino.nvim

Simple wrapper for arduino-language-server, written in Lua.
Arduino-language-server is not fully bootstrapped out of the box,
it requires the FQBN (Fully Qualified Board Name) and the
arduino-cli config. This wrapper stores configs for lsp for each
sketch directory and manages FQBNs.

# Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Setup](#setup)
    - [Clang via Mason.nvim](#clangd-via-masonnvim)
- [Commands](#commands)
- [Configuration](#configuration)
    - [Autocommands](#autocommands)
- [Limitations](#limitations)
- [License](#license)

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

Default settings:

```lua
require('arduino').setup {
    default_fqbn = "arduino:avr:uno",

    --Path to clangd (all paths must be full)
    clangd = <path/to/your/clangd>,

    --Path to arduino-cli
    arduino = <path/to/arduino-cli>,

    --Data directory of arduino-cli
    arduino_config_dir = <arduino-cli/data/dir>,

    --Extra options to arduino-language-server
    extra_opts = { ... }
}

require 'lspconfig' ['arduino_language_server'].setup {
    on_new_config = arduino.on_new_config,
}
```

This plugin does not depend on nvim-lspconfig. However, I have not tested it
with another configurators, so, if you wanna help, you can find a way to use
`Arduino.nvim` with your configurator and test it.

`configure()` returns a command to launch arduino-language-server if the
plugin is configured properly, and fully configures a plugin. After this
function call plugin commands becomes accesible. `on_new_config()` actually
just a wrapper for `configure()` for better usability with lspconfig.

```lua
local arduino_cmd = require 'arduino'.configure(vim.fn.getcwd())
```

## Clangd via Mason.nvim

If you have not clangd installed in your system, but it is installed via
[mason.nvim](https://github.com/williamboman/mason.nvim):

```lua
require 'arduino'.setup({
    clangd = require 'mason-core.path'.bin_prefix 'clangd',
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

If you have clangd installed and you open a C/C++ file while `Arduino.nvim`
configured, nvim-lspconfig will attach both clangd and arduino-language-server.
Clangd without compile_commands.json will give a lot of errors. It is not
a mistake, just clangd is not configured. Stop it with `:LspStop clangd`.
*Fix will be soon*.

# License

`Arduino.nvim` licensed under the MIT License. Check the [LICENSE](./LICENSE) 
file.
