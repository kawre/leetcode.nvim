local log = require("leetcode.logger")
local Stdout = require("leetcode.ui.console.components.stdout")
local console_popup = require("leetcode.ui.console.popup")
local problemlist = require("leetcode.cache.problems")

local Case = require("leetcode.ui.console.components.case")
local Group = require("leetcode-ui.component.group")
local Pre = require("leetcode.ui.console.components.pre")
local Layout = require("leetcode-ui.layout")
local Text = require("leetcode-ui.component.text")

local NuiLine = require("nui.line")
local NuiText = require("nui.text")
local NuiPopup = require("nui.popup")

---@class lc.Result: lc.Console.Popup
---@field layout lc-ui.Layout
local result = {}
result.__index = result
setmetatable(result, console_popup)

local function passed_testcases(item)
    local correct = item.total_correct ~= vim.NIL and item.total_correct or "0"
    local total = item.total_testcases ~= vim.NIL and item.total_testcases or "0"

    return string.format("%d/%d testcases passed", correct, total)
end

---@param hi string
function result:set_popup_border_hi(hi) self.popup.border:set_highlight(hi) end

function result:handle_accepted(item)
    problemlist.change_status(self.parent.parent.q.title_slug, "ac")

    local function perc_hi(perc) return perc >= 50 and "leetcode_ok" or "leetcode_error" end
    local group = Group:init({ opts = { spacing = 2 } })

    local header = Text:init()
    header:append(item._.title .. " 🎉", item._.hl)
    group:append(header)

    -- runtime
    local status_runtime = NuiLine()
    local runtime_ms = item.display_runtime or vim.split(item.status_runtime, " ")[1] or "NIL"
    status_runtime:append(runtime_ms)
    status_runtime:append(" ms", "leetcode_alt")

    local perc_runtime = NuiLine()
    perc_runtime:append(
        "Beats " .. string.format("%.2f", item.runtime_percentile) .. "% ",
        perc_hi(item.runtime_percentile)
    )
    perc_runtime:append("of users with " .. item.pretty_lang)

    local runtime = Pre:init(NuiText("󰓅 Runtime", "leetcode_normal"), {
        status_runtime,
        perc_runtime,
    })
    group:append(runtime)

    -- memory
    local status_memory = NuiLine()
    if item.status_memory == "0B" then item.status_memory = "0 MB" end
    local s_mem = vim.split(item.status_memory, " ")
    status_memory:append(s_mem[1] .. " ")
    status_memory:append(s_mem[2], "leetcode_alt")

    local perc_mem = NuiLine()
    perc_mem:append(
        "Beats " .. string.format("%.2f", item.memory_percentile) .. "% ",
        perc_hi(item.memory_percentile)
    )
    perc_mem:append("of users with " .. item.pretty_lang)

    local memory = Pre:init(NuiText("󰍛 Memory", "leetcode_normal"), {
        status_memory,
        perc_mem,
    })
    group:append(memory)

    self.layout:append(group)
end

---@private
---
---@param item lc.runtime
function result:handle_runtime(item) -- status code = 10
    if item._.submission then return self:handle_accepted(item) end

    local group = Group:init({ opts = { spacing = 1 } })
    local header = Text:init()

    local h = NuiLine()
    h:append(item._.title, item._.hl)
    h:append(" | ")
    h:append("Runtime: " .. item.status_runtime, "leetcode_alt")
    header:append(h)
    group:append(header)

    for i, answer in ipairs(item.code_answer) do
        local passed = item.compare_result:sub(i, i) == "1"

        local text = Case:init(
            i,
            self.parent.testcase.testcases[i],
            answer,
            item.expected_code_answer[i],
            passed
        )
        group:append(text)

        local stdout = Stdout:init(item.std_output_list[i])
        if stdout then group:append(stdout) end
    end

    self.layout:append(group)
end

---@private
---
---@param item lc.submission
function result:handle_submission_error(item) -- status code = 11
    problemlist.change_status(self.parent.parent.q.title_slug, "notac")

    local group = Group:init({ opts = { spacing = 1 } })

    local header = NuiLine()
    header:append(item._.title, item._.hl)
    header:append(" | ")
    header:append(passed_testcases(item), "leetcode_alt")
    group:append(Text:init({ lines = { header } }))

    local text = Case:init(
        item.total_correct + 1,
        item.input_formatted,
        item.code_output,
        item.expected_output
    )
    group:append(text)

    if item.std_output then
        local stdout = Stdout:init(item.std_output)
        if stdout then group:append(stdout) end
    end

    self.layout:append(group)
end

---@private
---
---@param item lc.limit_exceeded_error
function result:handle_limit_exceeded(item) -- status code = 14
    local group = Group:init({ opts = { spacing = 1 } })

    local header = NuiLine()
    header:append(item._.title, item._.hl)
    group:append(Text:init({ lines = { header } }))

    if item._.submission then
        local last_testcase = NuiLine()
        last_testcase:append(item.last_testcase:gsub("\n", " "), "leetcode_indent")

        local pre_header = NuiLine()
        pre_header:append(" Last Executed Input", "leetcode_normal")

        local last_exec = Pre:init(pre_header, { last_testcase })
        group:append(last_exec)

        if item.std_output ~= "" then
            local stdout = Stdout:init(item.std_output)
            if stdout then group:append(stdout) end
        end
    elseif item.std_output_list[1] ~= "" then
        local stdout = Stdout:init(item.std_output_list[1])
        if stdout then group:append(stdout) end
    end

    self.layout:append(group)
end

---@private
---
---@param item lc.runtime_error
function result:handle_runtime_error(item) -- status code = 15
    local group = Group:init({ opts = { spacing = 1 } })

    local header = NuiLine()
    header:append(item._.title, item._.hl)

    if item._.submission then
        header:append(" | ")
        header:append(passed_testcases(item), "leetcode_alt")
    end

    local t = {}
    for line in vim.gsplit(item.full_runtime_error, "\n") do
        table.insert(t, NuiLine():append(line, "leetcode_error"))
    end
    group:append(Pre:init(header, t))

    if item._.submission then
        local pre_header = NuiLine()
        pre_header:append(" Last Executed Input", "leetcode_normal")

        local last_testcase = NuiLine()
        last_testcase:append(item.last_testcase:gsub("\n", " "), "leetcode_indent")

        local last_exec = Pre:init(pre_header, { last_testcase })
        group:append(last_exec)
    end

    self.layout:append(group)
end

function result:handle_internal_error(item) -- status code = 16
    local group = Group:init({ opts = { spacing = 1 } })

    local header = NuiLine()
    header:append(item._.title, item._.hl)
    local text = Text:init({ lines = { header } })
    group:append(text)

    self.layout:append(group)
end

---@private
---
---@param item lc.compile_error
function result:handle_compile_error(item) -- status code = 20
    local group = Group:init({ opts = { spacing = 1 } })

    local header = NuiLine()
    header:append(item._.title, item._.hl)
    if item._.submission then
        header:append(" | ")
        header:append(passed_testcases(item), "leetcode_alt")
    end

    local t = {}
    for line in vim.gsplit(item.full_compile_error, "\n") do
        table.insert(t, NuiLine():append(line, "leetcode_error"))
    end

    group:append(Pre:init(header, t))
    self.layout:append(group)
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

    item._ = {
        title = " " .. item.status_msg,
        hl = hl,
        success = success,
        submission = submission,
    }

    return item
end

---@param item lc.interpreter_response
function result:handle(item)
    log.debug(item)

    self.layout:clear()
    item = self:handle_item(item)
    self:set_popup_border_hi(item._.hl)

    local handlers = {
        -- runtime
        [10] = function()
            self:handle_runtime(item --[[@as lc.runtime]])
        end,
        [11] = function()
            self:handle_submission_error(item --[[@as lc.submission]])
        end,

        -- time limit
        [13] = function()
            self:handle_limit_exceeded(item --[[@as lc.limit_exceeded_error]])
        end,
        [14] = function()
            self:handle_limit_exceeded(item --[[@as lc.limit_exceeded_error]])
        end,

        -- runtime error
        [15] = function()
            self:handle_runtime_error(item --[[@as lc.runtime_error]])
        end,

        -- internal error
        [16] = function()
            self:handle_internal_error(item --[[@as lc.internal_error]])
        end,

        -- compiler
        [20] = function()
            self:handle_compile_error(item --[[@as lc.compile_error]])
        end,

        -- unknown
        ["unknown"] = function() log.error("unknown runner status code: " .. item.status_code) end,
    };

    (handlers[item.status_code] or handlers["unknown"])()

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
    local t = {}
    for _, case in ipairs(parent.parent.q.testcase_list) do
        for s in vim.gsplit(case, "\n", { trimempty = true }) do
            table.insert(t, s)
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
                top = " Result ",
                top_align = "center",
                bottom = " (R) Run | (S) Submit ",
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

    local obj = setmetatable({
        popup = popup,
        layout = Layout:init({
            winid = popup.winid,
            bufnr = popup.bufnr,
        }),
        parent = parent,
    }, self)

    return obj
end

return result
