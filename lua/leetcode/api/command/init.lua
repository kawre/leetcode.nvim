local cache = require("leetcode.cache")
local log = require("leetcode.logger")
local question = require("leetcode.ui.components.question")
local config = require("leetcode.config")
local menu = require("leetcode-menu")

local ui = require("leetcode.ui")
local gql = require("leetcode.api.graphql")

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
            question:init(item)
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
            -- cmd.dashboard("menu")
        end
    )
end

---Merge configurations into default configurations and set it as user configurations.
---
---@return lc.UserStatus | nil
function cmd.authenticate() gql.auth.user_status() end

---Merge configurations into default configurations and set it as user configurations.
---
--@param theme lc-db.Theme
function cmd.qot() ui.open_qot() end

function cmd.random_question()
    local title_slug = gql.question.random().title_slug
    local item = cache.problems.get_by_title_slug(title_slug) or {}
    question:init(item)
end

function cmd.console()
    local q = problems[curr_question]

    if q then
        q.console:toggle()
    else
        log.error("No current question found")
    end
end

function cmd.start()
    if vim.fn.argc() ~= 1 then return end

    local invoke, arg = config.user.invoke_name, vim.fn.argv()[1]
    if arg ~= invoke then return end

    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    if #lines > 1 or (#lines == 1 and lines[1]:len() > 0) then return true end

    menu:init()
end

function cmd.menu() vim.api.nvim_set_current_tabpage(config.user.menu_tabpage) end

function cmd.questions() vim.api.nvim_set_current_tabpage(config.user.questions_tabpage) end

return cmd
