local Cases = require("leetcode.ui.console.components.cases")
local Header = require("leetcode.ui.console.components.header")

local Layout = require("leetcode-ui.layout")
local Pre = require("leetcode.ui.console.components.pre")
local Group = require("leetcode-ui.group")
local Stdout = require("leetcode.ui.console.components.stdout")
local Case = require("leetcode.ui.console.components.case")

local Line = require("leetcode-ui.line")
local NuiText = require("nui.text")

local config = require("leetcode.config")
local t = require("leetcode.translator")
local log = require("leetcode.logger")

---@class lc.ResultLayout : lc-ui.Layout
---@field parent lc.ui.Console
---@field group lc-ui.Group
---@field cases lc.Cases
---@field case lc.Result.Case
local ResultLayout = Layout:extend("LeetResultLayout")

function ResultLayout:handle_accepted(item)
    local function perc_hi(perc) return perc >= 50 and "leetcode_ok" or "leetcode_error" end
    self.group:set_opts({ spacing = 2 })

    local header = Header(item)
    self.group:insert(header)

    -- runtime
    local status_runtime = Line()
    local runtime_ms = item.display_runtime or vim.split(item.status_runtime, " ")[1] or "NIL"
    status_runtime:append(runtime_ms)
    status_runtime:append(" ms", "leetcode_alt")

    local perc_runtime = Line()
    perc_runtime:append(
        ("%s %.2f%% "):format(t("Beats"), item.runtime_percentile),
        perc_hi(item.runtime_percentile)
    )
    if config.translator then
        perc_runtime:append("使用 ")
        perc_runtime:append(item.pretty_lang, "Structure")
        perc_runtime:append(" 的用户")
    else
        perc_runtime:append("of users with ")
        perc_runtime:append(item.pretty_lang, "Structure")
    end

    local runtime = Pre(NuiText(("󰓅 %s"):format(t("Runtime")), "leetcode_normal"), {
        status_runtime,
        perc_runtime,
    })
    self.group:insert(runtime)

    -- memory
    local status_memory = Line()
    -- if item.status_memory == "0B" then item.status_memory = "0 MB" end
    item.status_memory = item.status_memory:gsub("(%d+)%s*(%a+)", "%1 %2")
    local s_mem = vim.split(item.status_memory, " ")
    status_memory:append(s_mem[1] .. " ")
    status_memory:append(s_mem[2], "leetcode_alt")

    local perc_mem = Line()
    perc_mem:append(
        ("%s %.2f%% "):format(t("Beats"), item.memory_percentile),
        perc_hi(item.memory_percentile)
    )
    if config.translator then
        perc_mem:append("使用 ")
        perc_mem:append(item.pretty_lang, "Structure")
        perc_mem:append(" 的用户")
    else
        perc_mem:append("of users with ")
        perc_mem:append(item.pretty_lang, "Structure")
    end

    local memory = Pre(NuiText(("󰍛 %s"):format(t("Memory")), "leetcode_normal"), {
        status_memory,
        perc_mem,
    })
    self.group:insert(memory)
end

---@private
---
---@param item lc.runtime
function ResultLayout:handle_runtime(item) -- status code = 10
    if item._.submission then return self:handle_accepted(item) end

    local header = Header(item)
    self.group:insert(header)

    self.cases = Cases(item, self.parent.testcase.testcases, self.parent.result)
    self.group:insert(self.cases)
end

---@private
---
---@param item lc.submission
function ResultLayout:handle_submission_error(item) -- status code = 11
    local header = Header(item)
    self.group:insert(header)

    self.group:insert(Case({ ---@diagnostic disable-line
        input = item.input_formatted,
        raw_input = item.last_testcase,
        output = item.code_output,
        expected = item.expected_output,
        std_output = item.std_output,
    }, false))
end

---@private
---
---@param item lc.limit_exceeded_error
function ResultLayout:handle_limit_exceeded(item) -- status code = 12,13,14
    local header = Header(item)
    self.group:insert(header)

    if item._.submission then
        local last_testcase = Line()
        last_testcase:append(item.last_testcase:gsub("\n", " "), "leetcode_indent")

        local pre_header = Line()
        pre_header:append((" %s"):format(t("Last Executed Input")), "leetcode_normal")

        local last_exec = Pre(pre_header, { last_testcase })

        self.group:insert(last_exec)

        local stdout = Stdout(item.std_output or "")
        self.group:insert(stdout)
    elseif item.std_output_list then
        local stdout = Stdout(item.std_output_list[#item.std_output_list])
        self.group:insert(stdout)
    end
end

---@private
---
---@param item lc.runtime_error
function ResultLayout:handle_runtime_error(item) -- status code = 15
    local header = Header(item)

    local tbl = {}
    for line in vim.gsplit(item.full_runtime_error, "\n") do
        table.insert(tbl, Line():append(line, "leetcode_error"))
    end
    self.group:insert(Pre(header._.lines[1], tbl))

    if item._.submission then
        local pre_header = Line()
        pre_header:append((" %s"):format(t("Last Executed Input")), "leetcode_normal")

        local last_testcase = Line()
        last_testcase:append(item.last_testcase:gsub("\n", " "), "leetcode_indent")

        local last_exec = Pre(pre_header, { last_testcase })
        self.group:insert(last_exec)

        local stdout = Stdout(item.std_output or "")
        self.group:insert(stdout)
    elseif item.std_output_list then
        local stdout = Stdout(item.std_output_list[#item.std_output_list])
        self.group:insert(stdout)
    end
end

function ResultLayout:handle_internal_error(item) -- status code = 16
    local header = Header(item)
    self.group:insert(header)
end

---@private
---
---@param item lc.compile_error
function ResultLayout:handle_compile_error(item) -- status code = 20
    local header = Header(item)

    local tbl = {}
    for line in vim.gsplit(item.full_compile_error, "\n") do
        table.insert(tbl, Line():append(line, "leetcode_error"))
    end

    local pre = Pre(header._.lines[1], tbl)
    self.group:insert(pre)
end

---@param item lc.interpreter_response
function ResultLayout:handle_res(item)
    self.group:set_opts({ spacing = 1 })
    self:clear()

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
    }

    local handler = handlers[item.status_code]
    if handlers then
        handler()
    else
        handlers["unknown"]()
    end

    self:replace({ self.group })
end

function ResultLayout:clear()
    if self.cases then self.cases:clear() end
    self.group:clear()
    ResultLayout.super.clear(self)
end

---@param parent lc.ui.Console
---@param opts? lc-ui.Layout.opts
function ResultLayout:init(parent, opts)
    ResultLayout.super.init(self, {}, opts or {})

    self.parent = parent
    self.group = Group({ spacing = 1 })
end

---@type fun(parent: lc.ui.Console, opts?: lc-ui.Layout.opts): lc.ResultLayout
local LeetResultLayout = ResultLayout

return LeetResultLayout
