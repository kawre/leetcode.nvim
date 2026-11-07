local m = require("markup")
local Result = require("leetcode.ui.problem.result")
local Judging = require("leetcode.ui.problem.result.judging")

---@class leet.problem.console.result
---@overload fun(): leet.problem.console.result
local M = Markup.object()

---@param console leet.problem.console
function M:new(console)
    self.console = console
    self.win = Markup.window({
        box = "horizontal",
        title = "Results",
        border = "rounded",
        show = false,
        relative = "win",
        win = console.problem.win,
        anchor = "SE",
    })
    self.view = Markup.view(self.win, { click = "double" })
end

function M:clear()
    self.state = nil
    self.view:render(nil)
end

--- Shows the progress of the judge, until a result replaces it.
---@param submit boolean
function M:judging(submit)
    self.state = m.signal("PENDING")
    self.view:render(Judging({ state = self.state, submit = submit }))
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
    self.view:render(Result({ item = item, console = self.console }))

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
