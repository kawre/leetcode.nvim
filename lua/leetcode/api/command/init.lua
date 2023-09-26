local cache = require("leetcode.cache")
local gql = require("leetcode.api.graphql")
local problems = require("leetcode.cache.problems")
local log = require("leetcode.logger")
local config = require("leetcode.config")
local api = require("leetcode.api")
local pick = require("leetcode.ui.pickers")

local ui = require("leetcode.ui")
local question = require("leetcode.ui.components.question")
local utils = require("leetcode.ui.utils")

local async = require("plenary.async")

local menu = require("leetcode-menu")

local Input = require("nui.input")

---@class lc.Commands
local cmd = {}

function cmd.cache_update() cache.update() end

function cmd.problems()
    local _, res = pcall(problems.get)

    pick.question(res)

    -- ui.pick_one(
    --     res,
    --     "Select a Problem",
    --     utils.question_formatter,
    --
    --     ---@param item lc.Problem
    --     function(item)
    --         if not item then return end
    --         question:init(item)
    --     end
    -- )
end

function cmd.cookie_prompt()
    local cookie = require("leetcode.cache.cookie")

    local popup_options = {
        relative = "editor",
        position = {
            row = "50%",
            col = "50%",
        },
        size = 100,
        border = {
            style = "rounded",
            text = {
                top = " Enter cookie ",
                top_align = "left",
            },
        },
        win_options = {
            winhighlight = "Normal:Normal",
        },
    }

    local input = Input(popup_options, {
        prompt = " 󰆘 ",
        on_close = function() log.info("Cookie prompt closed") end,
        on_submit = function(value) cookie.update(value) end,
    })

    input:map("n", { "<Esc>", "q" }, function() input:unmount() end)

    input:mount()

    -- popup:mount()

    -- ui.input(
    --     "Enter cookie",
    --     ---@param cookie_str string
    --     function(cookie_str)
    --         if not cookie_str then return end
    --
    --         cookie.new(cookie_str)
    --         -- cmd.dashboard("menu")
    --     end
    -- )
end

---Merge configurations into default configurations and set it as user configurations.
---
---@return lc.UserAuth | nil
function cmd.authenticate() gql.auth.user() end

---Merge configurations into default configurations and set it as user configurations.
---
--@param theme lc-db.Theme
function cmd.qot() ui.open_qot() end

function cmd.random_question()
    local title_slug = gql.question.random().title_slug
    local item = problems.get_by_title_slug(title_slug) or {}
    question:init(item)
end

function cmd.console()
    local q = Questions[Curr_question]

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

    -- async.run(function()
    api.setup()
    gql.auth.user()
    cache.setup()
    menu:init()
end

function cmd.menu() vim.api.nvim_set_current_tabpage(config.user.menu_tabpage) end

---@param layout layouts
function cmd.menu_layout(layout) _LC_MENU:set_layout(layout) end

function cmd.questions() vim.api.nvim_set_current_tabpage(config.user.questions_tabpage) end

return cmd
