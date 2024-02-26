local config = require("leetcode.config")

---@class lc.LeetCode
local leetcode = {}

---@param on_vimenter boolean
---
---@return boolean
function leetcode.should_skip(on_vimenter)
    if on_vimenter then
        if vim.fn.argc() ~= 1 then return true end

        local usr_arg, arg = config.user.arg, vim.fn.argv()[1]
        if usr_arg ~= arg then return true end

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
                local log = require("leetcode.logger")
                log.warn("Failed to initialize: `neovim` contains listed buffers")
                return true
            end
        end
    end

    return false
end

function leetcode.setup_cmds() require("leetcode.command").setup() end

---@param on_vimenter boolean
function leetcode.start(on_vimenter)
    if leetcode.should_skip(on_vimenter) then return false end

    config.setup()

    vim.api.nvim_set_current_dir(config.storage.home:absolute())

    leetcode.setup_cmds()

    local theme = require("leetcode.theme")
    theme.setup()

    if not on_vimenter then --
        vim.cmd.enew()
    end

    local Menu = require("leetcode-ui.renderer.menu")
    Menu():mount()

    local utils = require("leetcode.utils")
    utils.exec_hooks("enter")

    return true
end

function leetcode.stop() vim.cmd("qa!") end

---@param cfg? lc.UserConfig
function leetcode.setup(cfg)
    config.apply(cfg or {})

    vim.api.nvim_create_user_command("Leet", require("leetcode.command").start_with_cmd, {
        bar = true,
        bang = true,
        desc = "Open leetcode.nvim",
    })

    local group_id = vim.api.nvim_create_augroup("leetcode_start", { clear = true })
    vim.api.nvim_create_autocmd("VimEnter", {
        group = group_id,
        pattern = "*",
        nested = true,
        callback = function() leetcode.start(true) end,
    })
end

return leetcode
