local config = require("leetcode.config")

---@class lc.LeetCode
local leetcode = {}

function leetcode.should_skip()
    if vim.fn.argc() ~= 1 then return true end

    local usr_arg, arg = config.user.arg, vim.fn.argv()[1]
    if usr_arg ~= arg then return true end

    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
    if #lines > 1 or (#lines == 1 and lines[1]:len() > 0) then return true end

    return false
end

function leetcode.setup_cmds()
    local cmd = require("leetcode.command")
    cmd.setup()
end

function leetcode.validate()
    local utils = require("leetcode.utils")

    assert(vim.fn.has("nvim-0.9.0") == 1, "Neovim >= 0.9.0 required")
    assert(utils.get_lang(config.lang), "Unsupported Language: " .. config.lang)
end

function leetcode.start()
    if leetcode.should_skip() then return end

    leetcode.validate()

    local path = require("plenary.path")
    config.home = path:new(config.user.directory) ---@diagnostic disable-line
    config.home:mkdir()

    vim.api.nvim_set_current_dir(config.home:absolute())

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
    config.apply(cfg or {})

    local group_id = vim.api.nvim_create_augroup("leetcode_start", { clear = true })
    vim.api.nvim_create_autocmd("VimEnter", {
        group = group_id,
        pattern = "*",
        nested = true,
        callback = leetcode.start,
    })
end

return leetcode
