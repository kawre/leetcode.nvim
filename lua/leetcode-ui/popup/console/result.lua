local ConsolePopup = require("leetcode-ui.popup.console")
local ResultLayout = require("leetcode-ui.renderer.result")
local t = require("leetcode.translator")

local problemlist = require("leetcode.cache.problemlist")
local log = require("leetcode.logger")
local config = require("leetcode.config")

---@class lc.ui.Console.ResultPopup : lc.ui.Console.Popup
---@field renderer lc.ui.Result
---@field last_testcase string
local ResultPopup = ConsolePopup:extend("LeetResultPopup")

---@param item lc.interpreter_response
function ResultPopup:handle(item)
    self.border:set_highlight(item._.hl)
    self.renderer:handle_res(item)

    if item.last_testcase then
        self.last_testcase = item.last_testcase
    end

    if item._.submission then
        local status = item.status_code == 10 and "ac" or "notac"
        problemlist.change_status(self.console.question.q.title_slug, status)
        if status == "ac" then
            config.stats.update_streak()
        end
    end

    self:draw()
end

function ResultPopup:clear()
    ResultPopup.super.clear(self)

    self.last_testcase = nil
    self.border:set_highlight("FloatBorder")
end

---@param parent lc.ui.Console
function ResultPopup:init(parent)
    local keys = require("leetcode.config").user.keys

    ResultPopup.super.init(self, parent, {
        border = {
            text = {
                top = (" (%s) %s "):format(keys.focus_result, t("Result")),
                top_align = "center",
                bottom = (" (%s) %s "):format(keys.use_testcase, t("Use Testcase")),
                bottom_align = "center",
            },
        },
        buf_options = {
            modifiable = false,
            readonly = false,
        },
        win_options = {
            winhighlight = "Normal:NormalSB,FloatBorder:FloatBorder",
            wrap = true,
            linebreak = true,
        },
    })

    self.renderer = ResultLayout(parent)
end

---@type fun(parent: lc.ui.Console): lc.ui.Console.ResultPopup
local LeetResultPopup = ResultPopup

return LeetResultPopup
