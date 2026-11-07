local m = require("markup")
local Result = require("leetcode.ui.problem.result")
local Judging = require("leetcode.ui.problem.result.judging")
local Status = require("leetcode.ui.problem.result.status")

--- What the result tab of the console shows: nothing yet, the judge at work, or
--- what it decided. The console draws it.
---@class leet.problem.console.result
---@field console leet.problem.console
---@field win markup.window the console's
---@field view markup.view the console's
---@overload fun(): leet.problem.console.result
local M = Markup.object()

---@param console leet.problem.console
function M:new(console)
    self.console = console
    self.win = console.win
    self.view = console.view
    --- `{ render = fun(): element, status = fun(): element }`, the body and the
    --- line for the header, or nil before the first run. A table, as a signal
    --- given a function would call it to update its value.
    self.content = m.signal(nil)
end

function M:clear()
    self.state = nil
    self.content(nil)
end

--- Shows the progress of the judge, until a result replaces it.
---@param submit boolean
function M:judging(submit)
    local state = m.signal("PENDING")
    self.state = state
    self.content({
        render = function()
            return Judging({ state = state, submit = submit })
        end,
        status = function()
            return Status.Pending(submit)
        end,
    })
end

---@param state string
function M:set_state(state)
    if self.state then
        self.state(state)
    end
end

---@param item lc.interpreter_response
function M:handle(item)
    self.state = nil
    item._.params = self.console.problem.problem.meta_data.params
    self.content({
        render = function()
            return Result({ item = item, console = self.console })
        end,
        status = function()
            return Status.Status(item)
        end,
    })

    if item._.submission then
        local accepted = item.status_code == 10
        local slug = self.console.problem.problem.title_slug
        require("leetcode.cache.problems").change_status(slug, accepted and "ac" or "notac")

        if accepted then
            require("leetcode.ui.menu").refresh()

            if Leet.config.user.ui.confetti then
                require("leetcode.ui.confetti").burst()
            end
        end
    end
end

return M
