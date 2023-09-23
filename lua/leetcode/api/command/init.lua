local cache = require("leetcode.cache")
local log = require("leetcode.logger")
local config = require("leetcode.config")
local question = require("leetcode.ui.components.question")
local Runner = require("leetcode.runner")
local Console = require("leetcode.ui.components.console")

local ui = require("leetcode.ui")
-- local dashboard = require("leetcode.ui.dashboard")
local gql = require("leetcode.api.graphql")

local path = require("plenary.path")

---@class lc.Commands
local cmd = {}

function cmd.problems()
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

function cmd.leetcode()
    cmd.authenticate()
    -- M.dashboard(config.auth.is_signed_in and "menu" or "default")

    local ok, _ = pcall(vim.cmd, "Alpha | bd#")
    if not ok then log.error("Failed to launch Alpha") end
end

function cmd.cookie_prompt()
    local cookie = require("leetcode.cache.cookie")

    ui.input(
        "Enter cookie",
        ---@param cookie_str string
        function(cookie_str)
            if not cookie_str then return end

            cookie.new(cookie_str)
            cmd.dashboard("menu")
        end
    )
end

---Merge configurations into default configurations and set it as user configurations.
---
---@return lc.UserStatus | nil
function cmd.authenticate() gql.auth.user_status() end

---Merge configurations into default configurations and set it as user configurations.
---
---@param theme lc-db.Theme
function cmd.dashboard(theme) dashboard.apply(theme) end

---Merge configurations into default configurations and set it as user configurations.
---
--@param theme lc-db.Theme
function cmd.qot() ui.open_qot() end

function cmd.random_question()
    local title_slug = gql.question.random().title_slug
    local item = cache.problems.get_by_title_slug(title_slug) or {}
    question:init(item):mount()
end

function cmd.testcase() ui.testcase() end

function cmd.run()
    local runner = Runner:init()
    runner:run()
end

function cmd.console()
    local q = problems[curr_question]
    if q then
        q.console:open()
    else
        log.error("No current question found")
    end
end

return cmd
