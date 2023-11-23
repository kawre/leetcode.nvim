local ConsolePopup = require("leetcode-ui.popup.console")
local ResultLayout = require("leetcode-ui.renderer.result")
local t = require("leetcode.translator")

local problemlist = require("leetcode.cache.problemlist")
local log = require("leetcode.logger")

---@class lc.ui.Console.ResultPopup : lc.ui.Console.Popup
---@field renderer lc.ResultLayout
---@field last_testcase string
local ResultPopup = ConsolePopup:extend("LeetResultPopup")

---@param item lc.interpreter_response
function ResultPopup:handle(item)
    self.border:set_highlight(item._.hl)
    self.renderer:handle_res(item)

    if item.last_testcase then self.last_testcase = item.last_testcase end

    if item._.submission then
        local status = item.status_code == 10 and "ac" or "notac"
        problemlist.change_status(self.console.parent.q.title_slug, status)
    end

    self:draw()
end

function ResultPopup:clear()
    ResultPopup.super.clear(self)

    self.last_testcase = nil
    self.border:set_highlight("FloatBorder")
end

function ResultPopup:draw() self.renderer:draw(self) end

---@param parent lc.ui.Console
---
---@return lc.ui.Console.ResultPopup
function ResultPopup:init(parent)
    self.renderer = ResultLayout(parent)

    ResultPopup.super.init(self, parent, {
        border = {
            text = {
                top = (" (L) %s "):format(t("Result")),
                top_align = "center",
                bottom = (" (R) %s | (S) %s "):format(t("Run"), t("Submit")),
                bottom_align = "center",
            },
        },
        buf_options = {
            modifiable = false,
            readonly = false,
        },
        win_options = {
            winhighlight = "Normal:NormalSB,FloatBorder:FloatBorder",
        },
    })
end

---@type fun(parent: lc.ui.Console): lc.ui.Console.ResultPopup
local LeetResultPopup = ResultPopup

return LeetResultPopup
