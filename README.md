# nvim-hello-world

A simple Neovim plugin that prints "Hello World".

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "nisibz/nvim-hello-world",
    event = "VeryLazy",
    config = function()
        require("hello-world").setup()
    end
}
```
