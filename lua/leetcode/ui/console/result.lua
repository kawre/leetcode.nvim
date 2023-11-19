local console_popup = require("leetcode.ui.console.popup")
local problemlist = require("leetcode.cache.problemlist")
local t = require("leetcode.translator")

local ResultLayout = require("leetcode.ui.console.components.result-layout")
local NuiPopup = require("nui.popup")

---@class lc.Result : lc.Console.Popup
---@field layout lc.ResultLayout
local result = {}
result.__index = result
setmetatable(result, console_popup)

---@param hi string
function result:set_popup_border_hi(hi) self.popup.border:set_highlight(hi) end

function result:focus()
    if not vim.api.nvim_win_is_valid(self.popup.winid) then return end
    vim.api.nvim_set_current_win(self.popup.winid)
end

---@param item lc.interpreter_response
---
---@return lc.interpreter_response
function result:handle_item(item)
    local success = false
    if item.status_code == 10 then
        success = item.compare_result:match("^[1]+$") and true or false
        item.status_msg = success and "Accepted" or "Wrong Answer"
    end

    local submission = false
    if item.submission_id then
        submission = not item.submission_id:find("runcode") and true or false
    end
    local hl = success and "leetcode_ok" or "leetcode_error"

    if item.status_code == 15 and item.invalid_testcase then
        item.status_msg = "Invalid Testcase"
    end

    item._ = {
        title = " " .. t(item.status_msg),
        hl = hl,
        success = success,
        submission = submission,
    }

    return item
end

---@param item lc.interpreter_response
function result:handle(item)
    self.layout:clear()
    item = self:handle_item(item)
    self:set_popup_border_hi(item._.hl)
    self.layout:handle_res(item)

    if item._.submission then
        local status = item.status_code == 10 and "ac" or "notac"
        problemlist.change_status(self.parent.parent.q.title_slug, status)
    end

    self:draw()
end

function result:clear()
    self.layout:clear()
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
