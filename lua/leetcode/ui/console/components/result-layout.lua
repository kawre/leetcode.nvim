local config = require("leetcode.config")
local t = require("leetcode.translator")
local log = require("leetcode.logger")
local Cases = require("leetcode.ui.console.components.cases")

local Layout = require("leetcode-ui.layout")
local Pre = require("leetcode.ui.console.components.pre")
local Group = require("leetcode-ui.component.group")
local Text = require("leetcode-ui.component.text")
local Stdout = require("leetcode.ui.console.components.stdout")
local Case = require("leetcode.ui.console.components.case")

local NuiLine = require("nui.line")
local NuiText = require("nui.text")

---@class lc.ResultLayout : lc-ui.Layout
---@field parent lc.Console
---@field group lc-ui.Group
---@field cases lc.Cases
---@field case lc.Result.Case
local ResultLayout = {}
ResultLayout.__index = ResultLayout
setmetatable(ResultLayout, Layout)

local function testcases_passed(item)
    local correct = item.total_correct ~= vim.NIL and item.total_correct or "0"
    local total = item.total_testcases ~= vim.NIL and item.total_testcases or "0"

    return ("%d/%d %s"):format(correct, total, t("testcases passed"))
end

function ResultLayout:handle_accepted(item)
    local function perc_hi(perc) return perc >= 50 and "leetcode_ok" or "leetcode_error" end
    self.group:set_opts({ spacing = 2 })

    local header = Text:init({})
    header:append(item._.title .. " 🎉", item._.hl)
    self.group:append(header)

    -- runtime
    local status_runtime = NuiLine()
    local runtime_ms = item.display_runtime or vim.split(item.status_runtime, " ")[1] or "NIL"
    status_runtime:append(runtime_ms)
    status_runtime:append(" ms", "leetcode_alt")

    local perc_runtime = NuiLine()
    perc_runtime:append(
        ("%s %.2f%% "):format(t("Beats"), item.runtime_percentile),
        perc_hi(item.runtime_percentile)
    )
    if config.is_cn then
        perc_runtime:append("使用 ")
        perc_runtime:append(item.pretty_lang, "Structure")
        perc_runtime:append(" 的用户")
    else
        perc_runtime:append("of users with ")
        perc_runtime:append(item.pretty_lang, "Structure")
    end

    local runtime = Pre:init(NuiText(("󰓅 %s"):format(t("Runtime")), "leetcode_normal"), {
        status_runtime,
        perc_runtime,
    })
    self.group:append(runtime)

    -- memory
    local status_memory = NuiLine()
    -- if item.status_memory == "0B" then item.status_memory = "0 MB" end
    item.status_memory = item.status_memory:gsub("(%d+)%s*(%a+)", "%1 %2")
    local s_mem = vim.split(item.status_memory, " ")
    status_memory:append(s_mem[1] .. " ")
    status_memory:append(s_mem[2], "leetcode_alt")

    local perc_mem = NuiLine()
    perc_mem:append(
        ("%s %.2f%% "):format(t("Beats"), item.memory_percentile),
        perc_hi(item.memory_percentile)
    )
    if config.is_cn then
        perc_mem:append("使用 ")
        perc_mem:append(item.pretty_lang, "Structure")
        perc_mem:append(" 的用户")
    else
        perc_mem:append("of users with ")
        perc_mem:append(item.pretty_lang, "Structure")
    end

    local memory = Pre:init(NuiText(("󰍛 %s"):format(t("Memory")), "leetcode_normal"), {
        status_memory,
        perc_mem,
    })

    self.group:append(memory)
end

---@private
---
---@param item lc.runtime
function ResultLayout:handle_runtime(item) -- status code = 10
    if item._.submission then return self:handle_accepted(item) end

    local h = NuiLine()
    h:append(item._.title, item._.hl)
    h:append(" | ")
    h:append(("%s: %s"):format(t("Runtime"), item.status_runtime), "leetcode_alt")
    self.group:append(Text:init({ h }))

    self.cases = Cases:init(item, self.parent.testcase.testcases, self.parent.result)
    self.group:append(self.cases)
end

---@private
---
---@param item lc.submission
function ResultLayout:handle_submission_error(item) -- status code = 11
    self.group:set_opts({ spacing = 2 })

    local header = NuiLine()
    header:append(item._.title, item._.hl)
    header:append(" | ")
    header:append(testcases_passed(item), "leetcode_alt")
    self.group:append(Text:init({ header }))

    self.case = Case:init({
        input = item.input_formatted,
        raw_input = item.last_testcase,
        output = item.code_output,
        expected = item.expected_output,
        std_output = item.std_output,
    }, false)
    self.group:append(self.case)
end

---@private
---
---@param item lc.limit_exceeded_error
function ResultLayout:handle_limit_exceeded(item) -- status code = 12,13,14
    local header = NuiLine()
    header:append(item._.title, item._.hl)
    if item._.submission then
        header:append(" | ")
        header:append(testcases_passed(item), "leetcode_alt")
    end
    self.group:append(Text:init({ header }))

    if item._.submission then
        local last_testcase = NuiLine()
        last_testcase:append(item.last_testcase:gsub("\n", " "), "leetcode_indent")

        local pre_header = NuiLine()
        pre_header:append((" %s"):format(t("Last Executed Input")), "leetcode_normal")

        local last_exec = Pre:init(pre_header, { last_testcase })
        self.group:append(last_exec)

        local stdout = Stdout:init(item.std_output or "")
        if stdout then self.group:append(stdout) end
    elseif item.std_output_list then
        local stdout = Stdout:init(item.std_output_list[#item.std_output_list])
        if stdout then self.group:append(stdout) end
    end
end

---@private
---
---@param item lc.runtime_error
function ResultLayout:handle_runtime_error(item) -- status code = 15
    local header = NuiLine()
    header:append(item._.title, item._.hl)

    if item._.submission then
        header:append(" | ")
        header:append(testcases_passed(item), "leetcode_alt")
    end

    local tbl = {}
    for line in vim.gsplit(item.full_runtime_error, "\n") do
        table.insert(tbl, NuiLine():append(line, "leetcode_error"))
    end
    self.group:append(Pre:init(header, tbl))

    if item._.submission then
        local pre_header = NuiLine()
        pre_header:append((" %s"):format(t("Last Executed Input")), "leetcode_normal")

        local last_testcase = NuiLine()
        last_testcase:append(item.last_testcase:gsub("\n", " "), "leetcode_indent")

        local last_exec = Pre:init(pre_header, { last_testcase })
        self.group:append(last_exec)

        local stdout = Stdout:init(item.std_output or "")
        if stdout then self.group:append(stdout) end
    elseif item.std_output_list then
        local stdout = Stdout:init(item.std_output_list[#item.std_output_list])
        if stdout then self.group:append(stdout) end
    end
end

function ResultLayout:handle_internal_error(item) -- status code = 16
    local header = NuiLine()
    header:append(item._.title, item._.hl)
    local text = Text:init({ header })
    self.group:append(text)
end

---@private
---
---@param item lc.compile_error
function ResultLayout:handle_compile_error(item) -- status code = 20
    local header = NuiLine()
    header:append(item._.title, item._.hl)
    if item._.submission then
        header:append(" | ")
        header:append(testcases_passed(item), "leetcode_alt")
    end

    local tbl = {}
    for line in vim.gsplit(item.full_compile_error, "\n") do
        table.insert(tbl, NuiLine():append(line, "leetcode_error"))
    end

    self.group:append(Pre:init(header, tbl))
end

---@param idx integer
function ResultLayout:change_case(idx)
    if vim.tbl_isempty(self.cases) then return end
    if not self.cases[idx] then return end

    if self.case then
        self.case.components = { self.cases[idx] }
        self.parent.result:draw()
    end
end

---@param item lc.interpreter_response
function ResultLayout:handle_res(item)
    self.group = Group:init({}, { spacing = 1 })

    local handlers = {
        -- runtime
        [10] = function()
            self:handle_runtime(item --[[@as lc.runtime]])
        end,
        [11] = function()
            self:handle_submission_error(item --[[@as lc.submission]])
        end,

        -- memory limit
        [12] = function()
            self:handle_limit_exceeded(item --[[@as lc.limit_exceeded_error]])
        end,
        -- time limit
        [13] = function()
            self:handle_limit_exceeded(item --[[@as lc.limit_exceeded_error]])
        end,
        -- output limit
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
    self:append(self.group)
end

function ResultLayout:clear()
    if self.cases then self.cases:clear() end
    self.case = nil
    Layout.clear(self)
end

---@param parent lc.Console
---@param opts? lc-ui.Layout.opts
function ResultLayout:init(parent, opts)
    local layout = Layout:init({}, opts)
    self = setmetatable(layout, self)

    self.parent = parent

    return self
end

return ResultLayout
