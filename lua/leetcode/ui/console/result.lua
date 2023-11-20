local console_popup = require("leetcode.ui.console.popup")
local problemlist = require("leetcode.cache.problemlist")
local t = require("leetcode.translator")

local ResultLayout = require("leetcode.ui.console.components.result-layout")
local NuiPopup = require("nui.popup")
local event = require("nui.utils.autocmd").event

---@class lc.Result : lc.Console.Popup
---@field layout lc.ResultLayout
---@field last_testcase string
local result = {}
result.__index = result
setmetatable(result, console_popup)

---@param hi string
function result:set_popup_border_hi(hi) self.popup.border:set_highlight(hi) end

---@param item lc.interpreter_response
function result:handle(item)
    self.layout:clear()
    self:set_popup_border_hi(item._.hl)
    self.layout:handle_res(item)

    if item.last_testcase then self.last_testcase = item.last_testcase end

    if item._.submission then
        local status = item.status_code == 10 and "ac" or "notac"
        problemlist.change_status(self.parent.parent.q.title_slug, status)
    end

    self:draw()
end

function result:clear()
    self.layout:clear()
    self.last_testcase = nil
    self.popup.border:set_highlight("FloatBorder")
end

function result:draw() self.layout:draw(self.popup) end

---@param parent lc.Console
---
---@return lc.Result
function result:init(parent)
    local tbl = {}
    for _, case in ipairs(parent.parent.q.testcase_list) do
        for s in vim.gsplit(case, "\n", { trimempty = true }) do
            table.insert(tbl, s)
        end
    end

    local popup = NuiPopup({
        focusable = true,
        border = {
            padding = {
                top = 1,
                bottom = 1,
                left = 3,
                right = 3,
            },
            style = "rounded",
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

    self = setmetatable({
        popup = popup,
        layout = ResultLayout:init(parent, {
            winid = popup.winid,
            bufnr = popup.bufnr,
        }),
        parent = parent,
    }, self)

    return self
end

return result
