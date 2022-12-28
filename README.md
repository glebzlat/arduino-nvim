# ArduinoLSP.nvim

Simple wrapper for arduino-language-server, written in Lua.
Arduino-language-server is not fully bootstrapped out of the box,
it requires the FQBN (Fully Qualified Board Name) and the 
arduino-cli config. This wrapper stores configs for lsp for each
sketch directory and manages FQBNs.

*Currently plugin is under active development, so documentation
may differ with the plugin code. *

# Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Setup](#setup)
    - [Get arduino data path automatically](#get-arduino-data-path-automatically)
    - [Clang via Mason.nvim](#clang-via-mason.nvim)
- [Commands](#commands)
- [Configuration](#configuration)
    - [Default configuration](#default-configuration)
- [Limitations](#limitations)

# Requirements

Due to the simplicity, `ArduinoLSP.nvim` does not have a lot of requirements.
All requirements are:

- neovim `>= 0.7.0` (but maybe it will work on older versions)
- arduino-cli
- clangd

# Installation

## [Packer](https://github.com/wbthomason/packer.nvim)

```lua
use 'edKotinsky/arduinolsp.nvim'
```

## vim-plug

```vim
Plug 'edKotinsky/arduinolsp.nvim'
```

# Setup

```lua
require 'arduinolsp'.setup({
    arduino_cli_config_dir = arduinolsp.get_arduinocli_datapath()
})
```

```lua
require 'lspconfig' ['arduino_language_server'].setup {
    on_new_config = arduinolsp.on_new_config,
}
```

Plugin will configure the LSP command, and fully configure yourself,
when `arduinolsp.on_new_config()` called.

Note that I have not tested this plugin with other LSP managers 
except [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig/).

## Get arduino data path automatically

Function `arduinolsp.get_arduinocli_datapath()` will automatically invoke
arduino-cli and ask it for a path. You can pass a path to arduino
to this function. In this case function will store this path
to the configs, and, as its called before `setup()` function, you 
don't need to specify this parameter on setup.

Though the `arduinolsp.get_arduinocli_datapath()` function
makes setup easer, it can slow down setup process a bit,
so you can get this path manually from `arduino-cli config dump`
command output (line "Data: /path/to/.arduino"). 

## Clangd via Mason.nvim

If you have not clangd installed in your system, but it is installed via
[mason.nvim](https://github.com/williamboman/mason.nvim), you can get a 
path to it by this way:

```lua
-- This is a default mason path
local mason_root_dir = vim.fn.stdpath 'data' .. '/mason'

require 'mason'.setup({
    install_root_dir = mason_root_dir
    -- other settings
})

require 'arduinolsp'.setup({
    clangd = mason_root_dir .. '/bin/clangd',
    -- other settings
})
```

# Commands

- `:ArduinoSetFQBN <fqbn>` - set fqbn to the current sketch 
(nvim restart required)
- `:ArduinoDump` - prints current config
- `:ArduinoClean` - removes nonexistent sketch directories from config

# Configuration

You must manually specify path to clangd, path to arduino, if they're
not installed in your $PATH. Though, if you're using 
`get_arduinocli_datapath()` function, you can give a path to arduino as
its parameter instead of passing it as a field to `setup()`.

## Default configuration

Plugin will try to locate clangd and arduino-cli automatically,
however, if they're not found, corresponding fields will be empty.

```lua
local DEFAULT_SETTINGS = {
    default_fqbn = 'arduino:avr:uno',
    config_dir = path.concat { vim.fn.stdpath 'data', 'arduinolsp' },
    clangd = '/path/to/clangd' or nil,
    arduino = '/path/to/arduino' or nil,
    arduino_config_dir = '',
}
```

# Limitations

To initialize `ArduinoLSP.nvim` in a sketch directory, you need to
open .ino file first (of course, if you have any files except .ino).

If the current directory is not a sketch directory or if plugin is
not configurated (`on_new_config()` not invoked), invocation of
`:ArduinoDump` and `:ArduinoSetFqbn` commands has no effect.

