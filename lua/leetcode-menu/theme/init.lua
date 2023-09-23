local utils = require("leetcode.utils")
local gql = require("leetcode.api.graphql")
local config = require("leetcode.config")
local log = require("leetcode.logger")

local M = {}

---@alias lc-db.Theme
---| "cache"
---| "cookie"
---| "default"
---| "menu"
---| "problems"
---| "stats"

---@param theme lc-db.Theme
function M.apply(theme)
    local alpha = require("alpha")
    utils.alpha_move_cursor_top()

    local ok, cfg = pcall(require, "leetcode.ui.dashboard." .. theme)
    if not ok then log.error("Failed to load dashboard theme: " .. theme) end
    alpha.setup(cfg)

    pcall(vim.cmd, [[AlphaRedraw]])
end

-- function M.update() M.apply() end

return M
