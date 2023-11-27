local Cases = require("leetcode-ui.group.cases")
local Header = require("leetcode-ui.lines.header")
local utils = require("leetcode.utils")

local Renderer = require("leetcode-ui.renderer")
local Pre = require("leetcode-ui.lines.pre")
local Group = require("leetcode-ui.group")
local Stdout = require("leetcode-ui.lines.pre.stdout")
local Case = require("leetcode-ui.group.case")

local Line = require("leetcode-ui.line")
local Lines = require("leetcode-ui.lines")
local NuiText = require("nui.text")

local config = require("leetcode.config")
local t = require("leetcode.translator")
local log = require("leetcode.logger")

---@class lc.ResultLayout : lc-ui.Renderer
---@field parent lc.ui.Console
---@field group lc-ui.Group
---@field cases lc.Cases
---@field case lc.Result.Case
local ResultLayout = Renderer:extend("LeetResultLayout")

function ResultLayout:handle_accepted(item)
    local function perc_hi(perc) return perc >= 50 and "leetcode_ok" or "leetcode_error" end
    self.group:set_opts({ spacing = 2 })

    local header = Header(item)
    self.group:insert(header)

    local runtime = Lines()
    local runtime_ms = item.display_runtime or vim.split(item.status_runtime, " ")[1] or "NIL"
    runtime:append(runtime_ms):append(" ms", "leetcode_alt")
    runtime:endl()

    runtime:append(
        ("%s %.2f%% "):format(t("Beats"), item.runtime_percentile),
        perc_hi(item.runtime_percentile)
    )

    local lang = utils.get_lang_by_name(item.pretty_lang)
    local lang_text = { item.pretty_lang, "Structure" }
    if lang then lang_text = { lang.icon .. " " .. lang.lang, lang.hl or "Structure" } end

    if config.translator then
        runtime
            :append("使用 ", "leetcode_normal")
            :append(unpack(lang_text))
            :append(" 的用户", "leetcode_normal")
    else
        runtime:append("of users with ", "leetcode_normal"):append(unpack(lang_text))
    end

    local runtime_title = Line():append("󰓅 " .. t("Runtime"))
    self.group:insert(Pre(runtime_title, runtime))

    -- memory
    local memory = Lines()
    item.status_memory = item.status_memory:gsub("(%d+)%s*(%a+)", "%1 %2")
    local s_mem = vim.split(item.status_memory, " ")
    memory:append(s_mem[1] .. " "):append(s_mem[2], "leetcode_alt")
    memory:endl()

    memory:append(
        ("%s %.2f%% "):format(t("Beats"), item.memory_percentile),
        perc_hi(item.memory_percentile)
    )
    if config.translator then
        memory
            :append("使用 ", "leetcode_normal")
            :append(unpack(lang_text))
            :append(" 的用户", "leetcode_normal")
    else
        memory:append("of users with ", "leetcode_normal"):append(unpack(lang_text))
    end

    local memory_title = Line():append("󰍛 " .. t("Memory"))
    self.group:insert(Pre(memory_title, memory))
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

        local last_exec = Pre(pre_header, last_testcase)

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

    local lines = Lines()
    for line in vim.gsplit(item.full_runtime_error, "\n") do
        lines:append(line, "leetcode_error"):endl()
    end
    self.group:insert(Pre(header._.lines[1], lines))

    if item._.submission then
        local pre_header = Line()
        pre_header:append((" %s"):format(t("Last Executed Input")), "leetcode_normal")

        local last_testcase = Line()
        last_testcase:append(item.last_testcase:gsub("\n", " "), "leetcode_indent")

        local last_exec = Pre(pre_header, last_testcase)
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

    local lines = Lines()
    for line in vim.gsplit(item.full_compile_error, "\n") do
        lines:append(line, "leetcode_error"):endl()
    end

    local pre = Pre(header._.lines[1], lines)
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
