local M = {}

local a = vim.api

local config = require 'tiknot.config'

local opts = {
    noremap = true,
    silent = true
}
local state = {
    buf = nil,
    win = nil,
    text = nil,
    tmpfile = nil
}

M.hide = function()
    if (a.nvim_win_is_valid(state.win)) then
        a.nvim_win_hide(state.win)
    end

end

M.open = function()
    -- Create a new buffer.
    if (state.buf == nil) then
        state.buf = a.nvim_create_buf(false, true)
        a.nvim_buf_set_name(state.buf, 'tiknot')

        state.tmpfile = os.tmpname()
    end

    -- Open a new window.
    state.win = a.nvim_open_win(state.buf, true, config.values.win)
    a.nvim_set_option_value("cursorline",1,{})
    a.nvim_set_option_value("number",1,{} )
    a.nvim_win_set_option(state.win, "winhighlight", "NormalFloat:,FloatBorder:") -- TODO:

    if (config.values.hide_on_winleave) then
        a.nvim_exec([[
            augroup TikNot
            au!
            au WinLeave <buffer> lua require"tiknot".hide()
            augroup END

        ]], false)
    end

    if (config.values.key.exit) then
        a.nvim_buf_set_keymap(
            state.buf,
            'n',
            config.values.key.exit,
            ':bd!<CR>',
            opts
        )
    end

    if type(config.values.on_open) == 'function' then
        config.values.on_open(state)
    elseif (config.values.on_open) == 'auto' then
        a.nvim_buf_set_keymap(
            state.buf,
            'n',
            config.values.key.hide,
            ':lua require"tiknot".hide()<CR>',
            opts
        )
    end

    -- Clear buffer
    if (config.values.terminal == true) then
        a.nvim_buf_set_keymap(
            state.buf,
            'n',
            config.values.key.terminal,
            ':%d |:set nonu |:e term://' .. config.values.shell .. '<CR>',
            opts
        )
    end

    state.text = buffer_to_lines(state.buf)
    write_to_file(state.tmpfile, lines_to_string(state.text))

end

function buffer_to_lines(buffer)
    return vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
end

function lines_to_string(lines)
    return table.concat(lines, '\r\n')
end

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
        for line in io.lines(file) do
            lines[#lines + 1] = line
        end
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
