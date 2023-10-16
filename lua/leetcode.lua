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
    local utils = require("leetcode.utils")

    -- commands
    utils.create_usr_cmd("LcConsole", cmd.console, {})
    utils.create_usr_cmd("LcHints", cmd.hints, {})
    utils.create_usr_cmd("LcMenu", cmd.menu, {})
    utils.create_usr_cmd("LcTabs", cmd.question_tabs, {})
    utils.create_usr_cmd("LcLanguage", cmd.change_lang, {})
    utils.create_usr_cmd("LcDescriptionToggle", cmd.desc_toggle, {})
    utils.create_usr_cmd("LcRun", cmd.q_run, {})
    utils.create_usr_cmd("LcSubmit", cmd.q_submit, {})
    utils.create_usr_cmd("LcFix", cmd.fix, {})

    -- deprecate
    utils.deprecate_usr_cmd("LcQuestionTabs", "LcTabs")
end

function leetcode.validate()
    local utils = require("leetcode.utils")

    assert(vim.fn.has("nvim-0.9.0") == 1, "Neovim >= 0.9.0 required")
    assert(utils.get_lang(config.lang), "Unsupported Language: " .. config.lang)
    assert(utils.get_lang(config.sql), "Unsupported SQL dialect: " .. config.sql)
end

function leetcode.start()
    if leetcode.should_skip() then return end

    leetcode.validate()

    local path = require("plenary.path")
    config.home = path:new(config.user.directory) ---@diagnostic disable-line
    config.home:mkdir()

    leetcode.setup_cmds()

    local theme = require("leetcode.theme")
    theme.setup()

    local menu = require("leetcode-menu")
    menu:init()
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
