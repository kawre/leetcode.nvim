---@diagnostic disable: invisible, duplicate-set-field

local leetcode = require("leetcode")
local config = require("leetcode.config")

local is_standalone = true
local prev_cwd = nil

---@param on_vimenter boolean
leetcode.start = function(on_vimenter)
    local skip, standalone = leetcode.should_skip(on_vimenter)
    if skip then
        return false
    end

    config.setup()
    leetcode.setup_globals()

    leetcode.setup_cmds()

    local theme = require("leetcode.theme")
    theme.setup()

    if not on_vimenter then
        if not standalone then
            prev_cwd = vim.fn.getcwd()
            vim.cmd.tabe()
        else
            vim.cmd.enew()
        end

        is_standalone = standalone ---@diagnostic disable-line: cast-local-type
    end

    vim.api.nvim_set_current_dir(config.storage.home)

    local menu = require("leetcode.ui.menu")
    menu.win.buf = vim.api.nvim_get_current_buf()
    menu.win:show()
    menu.render()

    local utils = require("leetcode.util")
    utils.exec_hooks("enter")

    return true
end

leetcode.stop = vim.schedule_wrap(function()
    if is_standalone then
        return vim.cmd("qa!")
    end

    Leet.menu.view:unmount()

    vim.api.nvim_create_user_command("Leet", require("leetcode.cmd").start_with_cmd, {
        bar = true,
        bang = true,
        desc = "Open leetcode.nvim",
    })

    local utils = require("leetcode.util")
    utils.exec_hooks("leave")

    if prev_cwd then
        vim.api.nvim_set_current_dir(prev_cwd)
        prev_cwd = nil
    end
end)
