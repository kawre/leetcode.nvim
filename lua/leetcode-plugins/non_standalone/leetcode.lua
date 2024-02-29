local leetcode = require("leetcode")
local config = require("leetcode.config")

local standalone = true
local prev_cwd = nil

---@param on_vimenter boolean
leetcode.should_skip = function(on_vimenter)
    if on_vimenter then
        if vim.fn.argc() ~= 1 then
            return true
        end

        local usr_arg, arg = vim.fn.argv()[1], config.user.arg
        if usr_arg ~= arg then
            return true
        end

        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
        if #lines > 1 or (#lines == 1 and lines[1]:len() > 0) then
            local log = require("leetcode.logger")
            log.warn(("Failed to initialize: `%s` is not an empty buffer"):format(usr_arg))
            return true
        end
    else
        for _, buf_id in pairs(vim.api.nvim_list_bufs()) do
            local bufinfo = vim.fn.getbufinfo(buf_id)[1]
            if bufinfo and (bufinfo.listed == 1 and #bufinfo.windows > 0) then
                return false, true
            end
        end
    end

    return false
end

---@param on_vimenter boolean
leetcode.start = function(on_vimenter)
    local skip, buflisted = leetcode.should_skip(on_vimenter)
    if skip then
        return false
    end

    config.setup()

    leetcode.setup_cmds()

    local theme = require("leetcode.theme")
    theme.setup()

    if not on_vimenter then
        if buflisted then
            prev_cwd = vim.fn.getcwd()
            vim.cmd.tabe()
        else
            vim.cmd.enew()
        end

        standalone = not buflisted
    end

    vim.api.nvim_set_current_dir(config.storage.home:absolute())

    local Menu = require("leetcode-ui.renderer.menu")
    Menu():mount()

    local utils = require("leetcode.utils")
    utils.exec_hooks("enter")

    return true
end

leetcode.stop = vim.schedule_wrap(function()
    if standalone then
        return vim.cmd("qa!")
    end

    _Lc_state.menu:unmount()

    vim.api.nvim_create_user_command("Leet", require("leetcode.command").start_with_cmd, {
        bar = true,
        bang = true,
        desc = "Open leetcode.nvim",
    })

    local utils = require("leetcode.utils")
    utils.exec_hooks("leave")

    if prev_cwd then
        vim.api.nvim_set_current_dir(prev_cwd)
        prev_cwd = nil
    end
end)
