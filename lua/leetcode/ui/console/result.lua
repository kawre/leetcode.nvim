local log = require("leetcode.logger")
local config = require("leetcode.config")
local Stdout = require("leetcode.ui.console.components.stdout")
local console_popup = require("leetcode.ui.console.popup")

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

---@param hi string
function result:set_popup_border_hi(hi) self.popup.border:set_highlight(hi) end

---@private
---
---@param item lc.runtime
function result:handle_runtime(item) -- status code = 10
    local group = Group:init({ opts = { spacing = 1 } })
    local header = Text:init()
    local is_submission = item.runtime_percentile ~= vim.NIL and item.memory_percentile ~= vim.NIL

    if not is_submission then
        local h = NuiLine()
        h:append(item.lcnvim_title, item.lcnvim_hl)
        h:append(" | ")
        h:append("Runtime: " .. item.status_runtime, "Comment")
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
    else
        local function perc_hi(perc) return perc >= 50 and "LeetCodeOk" or "LeetCodeError" end

        header:append(item.lcnvim_title, item.lcnvim_hl)
        group:append(header)

        local status_runtime = NuiLine()
        local runtime_ms = item.display_runtime or vim.split(item.status_runtime, " ")[1] or "NIL"
        status_runtime:append(runtime_ms)
        status_runtime:append(" ms", "Comment")

        local perc_runtime = NuiLine()
        perc_runtime:append(
            "Beats " .. string.format("%.2f", item.runtime_percentile) .. "% ",
            perc_hi(item.runtime_percentile)
        )
        perc_runtime:append("of users with " .. item.pretty_lang)

        local runtime = Pre:init(NuiText("󰓅 Runtime"), {
            status_runtime,
            perc_runtime,
        })

        local status_memory = NuiLine()
        local s_mem = vim.split(item.status_memory, " ")
        status_memory:append(s_mem[1] .. " ")
        status_memory:append(s_mem[2], "Comment")

        local perc_mem = NuiLine()
        perc_mem:append(
            "Beats " .. string.format("%.2f", item.memory_percentile) .. "% ",
            perc_hi(item.memory_percentile)
        )
        perc_mem:append("of users with " .. item.pretty_lang)

        local memory = Pre:init(NuiText("󰍛 Memory"), {
            status_memory,
            perc_mem,
        })

        group:append(runtime)
        group:append(memory)
    end

    self.layout:append(group)
end

---@private
---
---@param item lc.submission
function result:handle_submission(item) -- status code = 11
    local header = NuiLine()
    header:append(item.lcnvim_title, item.lcnvim_hl)
    header:append(" | ")
    local testcases =
        string.format("%d/%d testcases passed", item.total_correct, item.total_testcases)
    header:append(testcases, "Comment")

    self.layout:append(Text:init({ lines = { header, NuiLine() } }))

    local group = Group:init({ opts = { spacing = 1 } })
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
        last_testcase:append(item.last_testcase:gsub("\n", " "), "LeetCodeIndent")

        local pre_header = NuiLine()
        pre_header:append(" Last Executed Input", "")

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
    local header = NuiLine()
    header:append(item._.title, item._.hl)

    local t = {}
    for line in vim.gsplit(item.full_runtime_error, "\n") do
        table.insert(t, NuiLine():append(line, "LeetCodeError"))
    end

    local pre = Pre:init(header, t)
    self.layout:append(pre)
end

function result:handle_internal_error(item) -- status code = 16
    local header = NuiLine()
    header:append(item.lcnvim_title, item.lcnvim_hl)

    local text = Text:init({ lines = { header } })
    self.layout:append(text)
end

---@private
---
---@param item lc.compile_error
function result:handle_compile_error(item) -- status code = 20
    local header = NuiLine()
    header:append(item._.title, item._.hl)

    local t = {}
    for line in vim.gsplit(item.full_compile_error, "\n") do
        table.insert(t, NuiLine():append(line, "LeetCodeError"))
    end

    self.layout:append(Pre:init(header, t))
end

---@param item lc.interpreter_response
---
---@return lc.interpreter_response
function result:handle_item(item)
    local success = false
    if item.status_code == 10 then
        success = item.compare_result:match("^[1]+$") and true or false
    end
    local submission = not item.submission_id:find("runcode") and true or false
    local hl = success and "LeetCodeOk" or "LeetCodeError"

    item._ = {
        title = item.status_msg,
        hl = hl,
        success = success,
        submission = submission,
    }
    log.info(item)

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
            self:handle_submission(item --[[@as lc.submission]])
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
            readonly = true,
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
