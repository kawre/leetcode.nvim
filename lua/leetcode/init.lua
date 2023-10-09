local config = require("leetcode.config")

---@class lc
local leetcode = {}

local function should_start()
    if vim.fn.argc() ~= 1 then return false end

    local user_arg, arg = config.user.arg, vim.fn.argv()[1]
    if user_arg ~= arg then return false end

    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    if #lines > 1 or (#lines == 1 and lines[1]:len() > 0) then return false end

    return true
end

local function setup_highlights()
    vim.api.nvim_set_hl(0, "LeetCodeEasy", { fg = "#46c6c2" })
    vim.api.nvim_set_hl(0, "LeetCodeMedium", { fg = "#fac31d" })
    vim.api.nvim_set_hl(0, "LeetCodeHard", { fg = "#f8615c" })

    vim.api.nvim_set_hl(0, "LeetCodeInfo", { link = "DiagnosticInfo" })
    vim.api.nvim_set_hl(0, "LeetCodeHint", { link = "DiagnosticHint" })
    vim.api.nvim_set_hl(0, "LeetCodeError", { link = "DiagnosticError" })
    vim.api.nvim_set_hl(0, "LeetCodeOk", { link = "DiagnosticOk" })

    local normal = vim.api.nvim_get_hl(0, { name = "FloatTitle" })
    vim.api.nvim_set_hl(0, "LeetCodeNormal", normal)
    vim.api.nvim_set_hl(0, "LeetCodeItalic", vim.tbl_extend("force", normal, { italic = true }))
    vim.api.nvim_set_hl(0, "LeetCodeBold", { bold = true })

    vim.api.nvim_set_hl(0, "LeetCodeCode", { link = "Type" })
    vim.api.nvim_set_hl(0, "LeetCodeExample", { link = "LeetCodeHint" })
    vim.api.nvim_set_hl(0, "LeetCodeConstraints", { link = "LeetCodeInfo" })
    vim.api.nvim_set_hl(0, "LeetCodeIndent", { link = "Comment" })
    vim.api.nvim_set_hl(0, "LeetCodeList", { link = "Tag" })
    vim.api.nvim_set_hl(0, "LeetCodeLink", { link = "Function" })
end

local function setup_cmds()
    local cmd = require("leetcode.command")

    vim.api.nvim_create_user_command("LcConsole", function() cmd.console() end, {})
    vim.api.nvim_create_user_command("LcMenu", function() cmd.menu() end, {})
    vim.api.nvim_create_user_command("LcQuestionTabs", function() cmd.list_questions() end, {})
    vim.api.nvim_create_user_command("LcLanguage", function() cmd.change_lang() end, {})
    vim.api.nvim_create_user_command("LcDescriptionToggle", function() cmd.desc_toggle() end, {})
end

local function start()
    setup_highlights()
    setup_cmds()

    require("leetcode-menu"):init()
end

---@param cfg? lc.UserConfig
function leetcode.setup(cfg)
    config.apply(cfg or {})
    if should_start() then start() end
end

return leetcode
