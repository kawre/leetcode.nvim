local config = require("leetcode.config")

---@class lc.LeetCode
local leetcode = {}

---@param arg string
function leetcode.should_skip(arg)
    if vim.fn.argc() ~= 1 then return true end

    local usr_arg = vim.fn.argv()[1]
    if usr_arg ~= arg then return true end

    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
    if #lines > 1 or (#lines == 1 and lines[1]:len() > 0) then
        local log = require("leetcode.logger")
        log.warn(("Failed to initialize: `%s` is not an empty buffer"):format(usr_arg))
        return true
    end

    return false
end

function leetcode.setup_cmds() require("leetcode.command").setup() end

---@param cfg lc.UserConfig
function leetcode.start(cfg)
    if leetcode.should_skip(cfg.arg or config.default.arg) then return end

    config.apply(cfg or {})

    vim.api.nvim_set_current_dir(config.storage.home:absolute())

    leetcode.setup_cmds()
    config.load_plugins()

    local utils = require("leetcode.utils")
    utils.exec_hooks("LeetEnter")

    local theme = require("leetcode.theme")
    theme.setup()

    local Menu = require("leetcode-ui.renderer.menu")
    Menu():mount()
end

---@param cfg? lc.UserConfig
function leetcode.setup(cfg)
    local group_id = vim.api.nvim_create_augroup("leetcode_start", { clear = true })
    vim.api.nvim_create_autocmd("VimEnter", {
        group = group_id,
        pattern = "*",
        nested = true,
        callback = function() leetcode.start(cfg or {}) end,
    })
end

return leetcode
