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

    -- vim.api.nvim_create_user_command("LcList", function() cmd.problems() end, {})
    vim.api.nvim_create_user_command("LcConsole", function() cmd.console() end, {})
    vim.api.nvim_create_user_command("LcHints", function() cmd.hints() end, {})
    vim.api.nvim_create_user_command("LcMenu", function() cmd.menu() end, {})

    vim.api.nvim_create_user_command("LcQuestionTabs", function()
        local log = require("leetcode.logger")
        log.warn("LcQuestionTabs is deprecated, use LcTabs instead.")
        cmd.question_tabs()
    end, {})

    vim.api.nvim_create_user_command("LcTabs", function() cmd.question_tabs() end, {})

    vim.api.nvim_create_user_command("LcLanguage", function() cmd.change_lang() end, {})
    vim.api.nvim_create_user_command("LcDescriptionToggle", function() cmd.desc_toggle() end, {})
    vim.api.nvim_create_user_command("LcRun", function() cmd.q_run() end, {})
    vim.api.nvim_create_user_command("LcSubmit", function() cmd.q_submit() end, {})
    vim.api.nvim_create_user_command("LcFix", function() cmd.fix() end, {})
end

function leetcode.validate()
    local utils = require("leetcode.utils")

    assert(utils.get_lang(config.lang), "Unknown language: " .. config.lang)
    assert(utils.get_lang(config.sql), "Unknown SQL dialect: " .. config.sql)
end

function leetcode.start()
    if leetcode.should_skip() then return end

    leetcode.validate()

    local path = require("plenary.path")
    config.home = path:new(config.user.directory) ---@diagnostic disable-line
    config.home:mkdir()

    local theme = require("leetcode.theme")
    theme.setup()

    leetcode.setup_cmds()

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
        callback = function() leetcode.start() end,
    })
end

return leetcode
