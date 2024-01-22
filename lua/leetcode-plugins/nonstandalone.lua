local leetcode = require("leetcode")
local config = require("leetcode.config")

local started_with_cmd = false
local did_init = false

---@param on_vimenter boolean
leetcode.should_skip = function(on_vimenter)
    if on_vimenter then
        if vim.fn.argc() ~= 1 then return true end

        local usr_arg, arg = vim.fn.argv()[1], config.user.arg
        if usr_arg ~= arg then return true end

        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
        if #lines > 1 or (#lines == 1 and lines[1]:len() > 0) then
            local log = require("leetcode.logger")
            log.warn(("Failed to initialize: `%s` is not an empty buffer"):format(usr_arg))
            return true
        end
    else
        -- for _, buf_id in pairs(vim.api.nvim_list_bufs()) do
        --     local bufinfo = vim.fn.getbufinfo(buf_id)[1]
        --     if bufinfo and (bufinfo.listed == 1 and #bufinfo.windows > 0) then --
        --         return false, true
        --     end
        -- end
        return false
    end

    return false
end

---@param on_vimenter boolean
leetcode.start = function(on_vimenter)
    local skip = leetcode.should_skip(on_vimenter)
    if skip then --
        return false
    end
    started_with_cmd = not on_vimenter

    vim.api.nvim_set_current_dir(config.storage.home:absolute())

    leetcode.setup_cmds()

    local utils = require("leetcode.utils")
    utils.exec_hooks("LeetEnter")

    local theme = require("leetcode.theme")
    theme.setup()

    if did_init then
        _Lc_Menu:mount()
    else
        local Menu = require("leetcode-ui.renderer.menu")
        Menu():mount()
    end
    did_init = true

    return true
end

---@class lc.plugins.nonstandalone
local nonstandalone = {}

function nonstandalone.load()
    local function exit()
        if started_with_cmd then
            for _, tab in ipairs(require("leetcode.utils").question_tabs()) do
                vim.cmd.tabclose({ args = { tab.tabpage } })
            end
            if _Lc_Menu:is_open() then _Lc_Menu:close() end
        else
            vim.cmd.quitall()
        end
    end

    local command = require("leetcode.command")

    -- command.exit = exit

    command.commands.exit = { exit }

    command.menu = function() leetcode.start(not started_with_cmd) end

    -- command.commands.menu = { menu }

    local MenuExitButton = require("leetcode-ui.lines.button.menu.exit")

    function MenuExitButton:init()
        MenuExitButton.super.init(self, "Exit", {
            icon = "󰩈",
            sc = "q",
            on_press = exit,
        })
    end
end

return nonstandalone
