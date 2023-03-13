local M = {}

local config = require 'tiknot.config'

local a = vim.api
local f = vim.fn
local g = vim.g

local opts = {noremap = true, silent = true}

local state = {}
state.buf = nil
state.win = nil
state.tmp = nil
state.text = nil

vim.cmd([[let g:TikNot={}]])
g.TikNot = 1

M.hide = function()
    if (a.nvim_win_is_valid(state.win)) then a.nvim_win_hide(state.win) end

end

M.open = function()
    if (state.tmp == nil) then state.tmp = os.tmpname() end

    if (state.buf == nil) then
        -- Create a new buffer.
        state.buf = a.nvim_create_buf(false, true)
        a.nvim_buf_set_name(state.buf, 'tiknot')
    end

    -- Open a new window.
    state.win = a.nvim_open_win(state.buf, true, config.values.win)
    a.nvim_set_option_value("cursorline",1,{})
    a.nvim_set_option_value("number",1,{} )
    tmp = a.nvim_get_hl_by_name("Normal", "rgb")
    a.nvim_set_hl(0, "NormalFloat", {bg=tmp.bg}) -- Reset background color.

    if (config.values.hide_on_winleave) then
        a.nvim_exec([[
            augroup TikNot
            au!
            au WinLeave <buffer> lua require"tiknot".hide()
            augroup END
        ]], false)
    end

    -- LuaFormatter off
    if (config.values.key.exit) then
        a.nvim_buf_set_keymap(
            state.buf,
            'n',
            config.values.key.exit,
            '<Cmd>:bw | :lua require"tiknot".hide()<CR>',
            opts
        )
    end

    if type(config.values.on_open) == 'function'
        then
        config.values.on_open(state)
    elseif (config.values.on_open) == 'auto'
        then
        a.nvim_buf_set_keymap(
            state.buf,
            'n',
            config.values.key.hide,
            '<Cmd>:lua require"tiknot".hide()<CR>',
            opts
        )
    end

    if (config.values.terminal == true)
        then
        -- Clear buffer
        a.nvim_buf_set_keymap(
            state.buf,
            'n',
            config.values.key.terminal,
            '<Cmd>:%d | :let g:TikNot=0 | :set nonu | :e term://' .. config.values.shell .. '<CR>',
            opts
        )
    end
    -- LuaFormatter on

    state.text = buffer_to_lines(state.buf)
    write_to_file(state.tmp, lines_to_string(state.text))

end

function buffer_to_lines(buffer)
    return vim.api.nvim_buf_get_lines(buffer, 0, -1, false)

end

function lines_to_string(lines) return table.concat(lines, '\r\n') end

function file_exists(file)
    f = io.open(file, "r")

    if f ~= nil then
        return true
    else
        return false
    end

    f:close()
end

function lines_from(file)
    lines = {}

    if file_exists(file) then
        for line in io.lines(file) do lines[#lines + 1] = line end
    end

    return lines
end

function write_to_file(file, text)
    if file_exists(file) then
        f = io.open(file, "w")
        f:write(text)
        f:close()
    end
end

---@param prefs table
M.setup = function(prefs) config.set_default_values(prefs) end

return M
