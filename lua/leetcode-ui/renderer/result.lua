local Cases = require("leetcode-ui.group.cases")
local Header = require("leetcode-ui.lines.header")
local utils = require("leetcode.utils")
local SimilarQuestions = require("leetcode-ui.group.similar-questions")

local Renderer = require("leetcode-ui.renderer")
local Pre = require("leetcode-ui.group.pre")
local Input = require("leetcode-ui.group.pre.input")
local Stdout = require("leetcode-ui.group.pre.stdout")
local Case = require("leetcode-ui.group.case")

local Line = require("leetcode-ui.line")
local Lines = require("leetcode-ui.lines")

local config = require("leetcode.config")
local t = require("leetcode.translator")
local log = require("leetcode.logger")

---@class lc.ui.Result : lc.ui.Renderer
---@field parent lc.ui.Console
---@field group lc.ui.Group
---@field cases lc.ui.Cases
---@field case lc.ui.Case
local ResultLayout = Renderer:extend("LeetResultLayout")

function ResultLayout:handle_accepted(item)
    self:set_opts({ spacing = 2 })

    local function perc_hi(perc) --
        if perc >= 50 then
            return "leetcode_ok"
        elseif perc >= 10 then
            return nil
        elseif perc >= 0 then
            return "leetcode_error"
        end
    end

    local header = Header(item)
    self:insert(header)

    --------------------------------------------
    --- Runtime
    --------------------------------------------
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
    if lang then
        lang_text = { lang.icon .. " " .. lang.lang, lang.hl or "Structure" }
    end

    if config.translator then
        runtime
            :append("使用 ", "leetcode_normal")
            :append(unpack(lang_text))
            :append(" 的用户", "leetcode_normal")
    else
        runtime:append("of users with ", "leetcode_normal"):append(unpack(lang_text))
    end

    local runtime_title = Line():append("󰓅 " .. t("Runtime"))
    self:insert(Pre(runtime_title, runtime))

    --------------------------------------------
    --- Memory
    --------------------------------------------
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
    self:insert(Pre(memory_title, memory))

    --------------------------------------------
    --- More challenges
    --------------------------------------------
    if not vim.tbl_isempty(self.parent.question.q.similar or {}) then
        local title_txt = (" %s"):format(t("More challenges"))
        local more_title = Line():append(title_txt, "leetcode_normal")
        local similar = SimilarQuestions(self.parent.question.q.similar)
        self:insert(Pre(more_title, similar))
    end
end

---@private
---
---@param item lc.runtime
function ResultLayout:handle_runtime(item) -- status code = 10
    if item._.submission then
        return self:handle_accepted(item)
    end

    local header = Header(item)
    self:insert(header)

    local cases = Cases(item, self.parent)
    self:insert(cases)
end

---@private
---
---@param item lc.submission
function ResultLayout:handle_submission_error(item) -- status code = 11
    local header = Header(item)
    self:insert(header)

    self:insert(Case({ ---@diagnostic disable-line
        input = vim.split(item.input, "\n"),
        raw_input = item.last_testcase,
        output = item.code_output,
        expected = item.expected_output,
        std_output = item.std_output,
    }, false, self.parent.question))
end

---@private
---
---@param item lc.limit_exceeded_error
function ResultLayout:handle_limit_exceeded(item) -- status code = 12,13,14
    local header = Header(item)
    self:insert(header)

    if item._.submission then
        local input = Input(
            (" %s"):format(t("Last Executed Input")),
            vim.split(item.last_testcase, "\n"),
            self.parent.question.q.meta_data.params
        )
        self:insert(input)

        local stdout = Stdout(item.std_output or "")
        self:insert(stdout)
    elseif item.std_output_list then
        local stdout = Stdout(item.std_output_list[#item.std_output_list])
        self:insert(stdout)
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
    self:insert(Pre(header, lines))

    if item._.submission then
        local pre_header = Line()
        pre_header:append((" %s"):format(t("Last Executed Input")), "leetcode_normal")

        local last_testcase = Line()
        last_testcase:append(item.last_testcase:gsub("\n", " "), "leetcode_indent")

        local last_exec = Pre(pre_header, last_testcase)
        self:insert(last_exec)

        local stdout = Stdout(item.std_output or "")
        self:insert(stdout)
    elseif item.std_output_list then
        local stdout = Stdout(item.std_output_list[#item.std_output_list])
        self:insert(stdout)
    end
end

function ResultLayout:handle_internal_error(item) -- status code = 16
    local header = Header(item)
    self:insert(header)
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

    local pre = Pre(header, lines)
    self:insert(pre)
end

---@param item lc.interpreter_response
function ResultLayout:handle_res(item)
    self:clear()
    self:set_opts({ spacing = 1 })

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
        ["unknown"] = function()
            log.error("unknown runner status code: " .. item.status_code)
        end,
    }

    local handler = handlers[item.status_code]
    if handler then
        handler()
    else
        handlers["unknown"]()
    end
end

---@param parent lc.ui.Console
function ResultLayout:init(parent)
    ResultLayout.super.init(self, {}, { spacing = 1 })

    self.parent = parent
end

---@type fun(parent: lc.ui.Console): lc.ui.Result
local LeetResultLayout = ResultLayout

return LeetResultLayout
