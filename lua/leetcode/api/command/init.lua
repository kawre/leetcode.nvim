local cache = require("leetcode.cache")
local log = require("leetcode.logger")
local config = require("leetcode.config")
local question = require("leetcode.ui.components.question")

local ui = require("leetcode.ui")
-- local dashboard = require("leetcode.ui.dashboard")
local gql = require("leetcode.graphql")

local path = require("plenary.path")

---@class lc.Commands
local M = {}

function M.problems()
    local _, res = assert(pcall(cache.problems.read))

    ui.pick_one(
        res,
        "Select a Problem",
        cache.problems.formatter,

        ---@param item lc.Problem
        function(item)
            if not item then return end

            question:init(item):mount()
        end
    )
end

function M.leetcode()
    M.authenticate()
    -- M.dashboard(config.auth.is_signed_in and "menu" or "default")

    local ok, _ = pcall(vim.cmd, "Alpha | bd#")
    if not ok then log.error("Failed to launch Alpha") end
end

function M.cookie_prompt()
    local cookie = require("leetcode.cache.cookie")

    ui.input(
        "Enter cookie",
        ---@param cookie_str string
        function(cookie_str)
            if not cookie_str then return end

            cookie.new(cookie_str)
            M.dashboard("menu")
        end
    )
end

---Merge configurations into default configurations and set it as user configurations.
---
---@return lc.UserStatus | nil
function M.authenticate() gql.auth.user_status() end

---Merge configurations into default configurations and set it as user configurations.
---
---@param theme lc-db.Theme
function M.dashboard(theme) dashboard.apply(theme) end

---Merge configurations into default configurations and set it as user configurations.
---
--@param theme lc-db.Theme
function M.qot() ui.open_qot() end

function M.random_question()
    local title_slug = gql.question.random().title_slug
    local item = cache.problems.get_by_title_slug(title_slug) or {}
    question:init(item):mount()
end

function M.testcase() ui.testcase() end

return M
