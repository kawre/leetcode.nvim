local template = require("leetcode.config.template")

---@class lc.Settings
local config = {
    name = "leetcode.nvim",
    debug = true,
    notify = false,
    lang = "cpp",
    domain = "https://leetcode.com",
}

---Default configurations.
---
---@type lc.Config
config.default = template

---User configurations.
---
---@type lc.Config
config.user = config.default

---@type lc.UserStatus|nil
config.auth = nil

---Merge configurations into default configurations and set it as user configurations.
---
---@param cfg lc.Config Configurations to be merged.
function config.apply(cfg)
    config.user = vim.tbl_deep_extend("force", template, cfg)

    local ok, notify = pcall(require, "notify")
    if ok then
        vim.notify = notify
        config.notify = true
    end

    config.domain = "https://leetcode." .. config.user.domain
    config.lang = config.user.lang

    vim.api.nvim_set_hl(0, "LeetCodePTag", { link = "Comment" })
    vim.api.nvim_set_hl(0, "LeetCodeEmTag", { italic = true })
    vim.api.nvim_set_hl(0, "LeetCodeStrongTag", { bold = true })
    vim.api.nvim_set_hl(0, "LeetCodeCodeTag", { link = "DiagnosticHint" })
    vim.api.nvim_set_hl(0, "LeetCodeSupTag", { link = "MatchParen" })
    vim.api.nvim_set_hl(0, "LeetCodePreTag", { link = "@text" })
end

---Merge configurations into default configurations and set it as user configurations.
---
---@param status lc.UserStatus | nil
function config.authenticate(status) config.auth = status end

return config
