local log = require("leetcode.logger")

---@class lc.Commands
local cmd = {}

function cmd.cache_update() require("leetcode.cache").update() end

function cmd.problems()
    local async = require("plenary.async")
    local problems = require("leetcode.cache.problems")

    async.run(function()
        local res = problems.get()
        return res
    end, function(res) require("leetcode.pickers.question").pick(res) end)
end

---@param cb? function
function cmd.cookie_prompt(cb)
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

    local Input = require("nui.input")
    local input = Input(popup_options, {
        prompt = " 󰆘 ",
        on_submit = function(value)
            if cookie.update(value) then
                cmd.menu_layout("menu")
                log.info("Sign-in successful")
                if cb then cb() end
            end
        end,
    })

    input:map("n", { "<Esc>", "q" }, function() input:unmount() end)
    input:mount()
end

---Sign out
function cmd.delete_cookie()
    log.warn("You're now signed out")
    local cookie = require("leetcode.cache.cookie")
    pcall(cookie.delete)

    cmd.menu_layout("signin")
end

---Merge configurations into default configurations and set it as user configurations.
---
---@return lc.UserAuth | nil
function cmd.authenticate() require("leetcode.api.auth").user() end

---Merge configurations into default configurations and set it as user configurations.
---
--@param theme lc-db.Theme
function cmd.qot()
    local problems = require("leetcode.api.problems")
    local Question = require("leetcode.ui.question")

    problems.question_of_today(function(qot) Question:init(qot) end)
end

function cmd.random_question()
    local problems = require("leetcode.cache.problems")
    local question = require("leetcode.api.question")

    local q = question.random()
    if q then
        local item = problems.get_by_title_slug(q.title_slug) or {}
        require("leetcode.ui.question"):init(item)
    end
end

function cmd.menu() vim.api.nvim_set_current_tabpage(_Lc_MenuTabPage) end

---@param layout layouts
function cmd.menu_layout(layout) _Lc_Menu:set_layout(layout) end

function cmd.question_tabs() require("leetcode.pickers.question-tabs").pick() end

function cmd.change_lang() require("leetcode.pickers.language").pick() end

function cmd.desc_toggle() _Lc_questions[_Lc_curr_question].description:toggle() end

function cmd.console()
    local utils = require("leetcode.utils")
    local q = utils.curr_question()
    if not q then return log.error("No current question found") end
    q.console:toggle()
end

function cmd.q_run()
    local utils = require("leetcode.utils")
    local q = utils.curr_question()
    if not q then return log.warn("No current question found") end
    q.console:run()
end

function cmd.q_submit()
    local utils = require("leetcode.utils")
    local q = utils.curr_question()
    if not q then return log.warn("No current question found") end
    q.console:submit()
end

return cmd
