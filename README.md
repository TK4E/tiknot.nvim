# tiknot.nvim

A disposable floating window.

![tiknot.gif](https://github.com/tamago324/images/blob/master/tiknot.nvim/tiknot.gif)

## Requirements

* Neovim

## Installation

```vim
Plug 'tamago324/tiknot.nvim'
```

## Usage

```vim
:lua require'tiknot'.open()
:lua require'tiknot'.hide()
```


## Configuration

```lua
require('tiknot').setup {
    hide_on_winleave = true,
    on_open = 'auto',
    shell = 'zsh',
    win = {
        relative = 'cursor',
        width = 40,
        height = 15,
        col = 10,
        row = 3,
        focusable = true,
        style = 'minimal',
        border = 'shadow'
    },

    key = {
        hide = '<F7>',
        exit = 'qq',
        terminal = '<c-t>',
    },

}

vim.api.nvim_set_keymap(
    'n',
    '<F7>',
    '<Cmd>lua require"tiknot".open()<CR>',
    {noremap = true, silent = true}
)
```

## Contributing

* All contributions are welcome.


## License

MIT
