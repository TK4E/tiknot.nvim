local defaults_values = {
    hide_on_winleave = true,
    on_open = 'auto',
    terminal = true,
    shell = 'bash',
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

local config = {}
config.values = {}

---@param opts table
function config.set_default_values(opts)
    config.values = vim.tbl_deep_extend('force', defaults_values, opts or {})
end

return config
