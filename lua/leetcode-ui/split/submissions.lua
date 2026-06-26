local config = require("leetcode.config")

local Group = require("leetcode-ui.group")
local Line = require("leetcode-ui.line")
local Padding = require("leetcode-ui.lines.padding")
local Split = require("leetcode-ui.split")
local ui_utils = require("leetcode-ui.utils")
local active_panels_by_slug = {}

---@class lc.ui.Submissions : lc-ui.Split
---@field question lc.ui.Question
---@field active_tab "submissions"|"memory"|"similar"
---@field submissions_state "loading"|"ready"|"empty"|"error"
---@field memory_state "loading"|"ready"|"empty"|"error"
---@field similar_state "loading"|"ready"|"empty"|"error"
---@field submissions table[]
---@field message? string
---@field memory_summary? table
---@field memory_message? string
---@field similar_message? string
local Submissions = Split:extend("LeetSubmissions")

local function debug_log(msg)
    vim.schedule(function()
        vim.fn.histadd("message", "[submissions_panel] " .. msg)
    end)
end

local function status_hl(status)
    if status == "Accepted" then
        return "leetcode_easy"
    end

    if status == "Wrong Answer" or status == "Runtime Error" or status == "Time Limit Exceeded" then
        return "leetcode_hard"
    end

    return "leetcode_normal"
end

local function status_icon(status)
    if status == "Accepted" then
        return config.icons.status.ac, "leetcode_easy"
    end

    return config.icons.status.notac, "leetcode_hard"
end

local function trim_timestamp(timestamp)
    if not timestamp or timestamp == "" then
        return "unknown"
    end

    return timestamp:gsub(" %u+$", "")
end

local function panel_content_width(self)
    local win_width = ui_utils.win_width(self)
    local usable_width = math.max(20, win_width - 6)
    return math.min(usable_width, 88)
end

local function wrap_text(text, max_width)
    local chunks = {}
    local current = ""
    local current_width = 0
    local source = tostring(text or ""):gsub("\r\n", "\n")

    for raw_line in source:gmatch("([^\n]*)\n?") do
        if raw_line == "" then
            if current ~= "" then
                table.insert(chunks, current)
                current = ""
                current_width = 0
            end
            if #chunks == 0 or chunks[#chunks] ~= "" then
                table.insert(chunks, "")
            end
        else
            local index = 0
            while true do
                local char = vim.fn.strcharpart(raw_line, index, 1)
                if char == nil or char == "" then
                    break
                end

                local char_width = vim.api.nvim_strwidth(char)
                if current_width > 0 and current_width + char_width > max_width then
                    table.insert(chunks, current)
                    current = char
                    current_width = char_width
                else
                    current = current .. char
                    current_width = current_width + char_width
                end

                index = index + 1
            end

            if current ~= "" then
                table.insert(chunks, current)
                current = ""
                current_width = 0
            end
        end
    end

    while #chunks > 0 and chunks[#chunks] == "" do
        table.remove(chunks)
    end

    return vim.tbl_isempty(chunks) and { "" } or chunks
end

local function insert_wrapped_value(layout, label, content, max_width, value_hl)
    local label_width = vim.api.nvim_strwidth(label)
    local wrapped = wrap_text(content, math.max(10, max_width - label_width))

    for index, segment in ipairs(wrapped) do
        local line = Line()
        if index == 1 then
            line:append(label, "leetcode_list")
        else
            line:append((" "):rep(label_width), "leetcode_list")
        end
        line:append(segment, value_hl or "leetcode_normal")
        layout:insert(line)
    end
end

local function compact_string_list(values, limit)
    if type(values) ~= "table" then
        return {}
    end

    local result = {}
    local seen = {}

    for _, value in ipairs(values) do
        if value and value ~= vim.NIL and value ~= "" then
            local text = tostring(value)
            if not seen[text] then
                table.insert(result, text)
                seen[text] = true
            end
        end

        if limit and #result >= limit then
            break
        end
    end

    return result
end

local function session_failure_summaries(session)
    local summaries = compact_string_list(session.failureSummaries, 5)

    if #summaries == 0 and session.failureSummary and session.failureSummary ~= vim.NIL and session.failureSummary ~= "" then
        table.insert(summaries, tostring(session.failureSummary))
    end

    return summaries
end

local function memory_status_hl(status)
    if status == "Accepted" then
        return "leetcode_easy"
    end

    if status == "Wrong Answer" or status == "Runtime Error" or status == "Time Limit Exceeded" then
        return "leetcode_hard"
    end

    return "leetcode_alt"
end

function Submissions:populate()
    local max_width = panel_content_width(self)
    local layout = Group({}, {
        padding = {
            left = 1,
            right = 1,
            top = 1,
        },
    })

    local tabs = Line()
    tabs:append("[1] 历史提交", self.active_tab == "submissions" and "leetcode_medium" or "leetcode_alt")
    tabs:append("  |  ", "leetcode_alt")
    tabs:append("[2] 历史记忆", self.active_tab == "memory" and "leetcode_medium" or "leetcode_alt")
    tabs:append("  |  ", "leetcode_alt")
    tabs:append("[3] 类似题", self.active_tab == "similar" and "leetcode_medium" or "leetcode_alt")
    layout:insert(tabs)
    layout:insert(Padding(1))

    if self.active_tab == "submissions" and self.submissions_state == "loading" then
        local line = Line()
        line:append("正在加载历史提交...", "leetcode_alt")
        layout:insert(line)
    elseif self.active_tab == "submissions" and self.submissions_state == "error" then
        local line = Line()
        line:append(self.message or "提交服务暂不可用", "leetcode_hard")
        layout:insert(line)
    elseif self.active_tab == "submissions" and self.submissions_state == "empty" then
        local line = Line()
        line:append("还没有历史提交", "leetcode_alt")
        layout:insert(line)
    elseif self.active_tab == "submissions" then
        for index, submission in ipairs(self.submissions) do
            local title = Line()
            title:append(("%d. "):format(index), "leetcode_list")
            title:append(trim_timestamp(submission.submitted_at_pst), "leetcode_alt")
            layout:insert(title)

            local details = Line()
            local icon, icon_hl = status_icon(submission.submit_result)
            details:append(icon, icon_hl)
            details:append("  用时=", "leetcode_list")

            local time_spent = submission.time_spent_minutes
            if time_spent == nil or time_spent == vim.NIL then
                details:append("未知", "leetcode_alt")
            else
                details:append(("%sm"):format(time_spent), "leetcode_normal")
            end

            details:append("  测试=", "leetcode_list")
            details:append(submission.is_test and "是" or "否", submission.is_test and "leetcode_medium" or "leetcode_normal")
            details:append("  ", "leetcode_list")
            details:append(submission.submit_result or "Unknown", status_hl(submission.submit_result))
            layout:insert(details)

            if index < #self.submissions then
                layout:insert(Padding(1))
            end
        end
    elseif self.active_tab == "memory" and self.memory_state == "loading" then
        local line = Line()
        line:append("正在加载历史记忆...", "leetcode_alt")
        layout:insert(line)
    elseif self.active_tab == "memory" and self.memory_state == "error" then
        local line = Line()
        line:append(self.memory_message or "历史记忆暂不可用", "leetcode_hard")
        layout:insert(line)
    elseif self.active_tab == "memory" and self.memory_state == "empty" then
        local line = Line()
        line:append("这道题还没有可回忆的历史记录", "leetcode_alt")
        layout:insert(line)
    elseif self.active_tab == "memory" then
        local summary = self.memory_summary or {}
        local count_line = Line()
        count_line:append("历史记录数：", "leetcode_list")
        count_line:append(tostring(summary.record_count or 0), "leetcode_normal")
        layout:insert(count_line)

        local sessions = summary.sessions or {}
        for index, session in ipairs(sessions) do
            layout:insert(Padding(1))

            local header = Line()
            header:append(("%d. "):format(index), "leetcode_list")
            header:append(session.endReason or "unknown", "leetcode_medium")
            if session.latestFailureStatus and session.latestFailureStatus ~= vim.NIL then
                header:append("  ", "leetcode_alt")
                header:append(session.latestFailureStatus, memory_status_hl(session.latestFailureStatus))
            end
            layout:insert(header)

            if session.distinctMistakeCount and session.distinctMistakeCount ~= vim.NIL then
                insert_wrapped_value(layout, "mistakes: ", tostring(session.distinctMistakeCount), max_width)
            end

            local failure_summaries = session_failure_summaries(session)
            if #failure_summaries > 0 then
                insert_wrapped_value(layout, "failure: ", table.concat(failure_summaries, " | "), max_width)
            end

            if type(session.stuckPoints) == "table" and #session.stuckPoints > 0 then
                insert_wrapped_value(layout, "stuck: ", table.concat(session.stuckPoints, " | "), max_width)
            end

            if type(session.thoughtProcess) == "table" and #session.thoughtProcess > 0 then
                insert_wrapped_value(layout, "thought: ", table.concat(session.thoughtProcess, " | "), max_width)
            end
        end
    elseif self.similar_state == "loading" then
        local line = Line()
        line:append("正在加载类似题...", "leetcode_alt")
        layout:insert(line)
    elseif self.similar_state == "error" then
        local line = Line()
        line:append(self.similar_message or "类似题暂不可用", "leetcode_hard")
        layout:insert(line)
    elseif self.similar_state == "empty" then
        local line = Line()
        line:append("这道题还没有可回忆的类似题", "leetcode_alt")
        layout:insert(line)
    else
        local summary = self.memory_summary or {}
        local similar_matches = summary.similar_matches or {}
        local similar_title = Line()
        similar_title:append("类似题：", "leetcode_list")
        similar_title:append(tostring(summary.similar_match_count or #similar_matches), "leetcode_normal")
        layout:insert(similar_title)

        for index, match in ipairs(similar_matches) do
            layout:insert(Padding(1))

            local header = Line()
            header:append(("%d. "):format(index), "leetcode_list")
            header:append(match.titleSlug or "unknown", "leetcode_medium")
            if match.difficulty and match.difficulty ~= vim.NIL then
                header:append("  ", "leetcode_alt")
                header:append(match.difficulty, "leetcode_alt")
            end
            if match.score and match.score ~= vim.NIL then
                header:append("  score=", "leetcode_list")
                header:append(tostring(match.score), "leetcode_normal")
            end
            layout:insert(header)

            if match.profile and match.profile.problemSummary and match.profile.problemSummary ~= "" then
                insert_wrapped_value(layout, "why: ", match.profile.problemSummary, max_width)
            end

            local failure_summaries = compact_string_list(match.failureSummaries, 5)
            if #failure_summaries > 0 then
                insert_wrapped_value(layout, "failure: ", table.concat(failure_summaries, " | "), max_width)
            end

            if type(match.stuckPoints) == "table" and #match.stuckPoints > 0 then
                insert_wrapped_value(layout, "stuck: ", table.concat(match.stuckPoints, " | "), max_width)
            end

            if type(match.thoughtProcess) == "table" and #match.thoughtProcess > 0 then
                insert_wrapped_value(layout, "thought: ", table.concat(match.thoughtProcess, " | "), max_width)
            end
        end
    end

    self.renderer:replace({ layout })
end

function Submissions:draw()
    self:populate()
    Submissions.super.draw(self)
end

function Submissions:set_loading()
    debug_log("set_loading")
    self.submissions_state = "loading"
    self.message = nil
    self.submissions = {}
    self:draw()
end

---@param msg string
function Submissions:set_error(msg)
    debug_log("set_error " .. tostring(msg))
    self.submissions_state = "error"
    self.message = msg
    self.submissions = {}
    self:draw()
end

---@param submissions table[]
function Submissions:update_submissions(submissions)
    debug_log("update_submissions count=" .. tostring(submissions and #submissions or 0))
    self.submissions = submissions or {}
    self.message = nil
    self.submissions_state = vim.tbl_isempty(self.submissions) and "empty" or "ready"
    self:draw()
end

function Submissions:set_memory_loading()
    self.memory_state = "loading"
    self.similar_state = "loading"
    self.memory_message = nil
    self.similar_message = nil
    self.memory_summary = nil
    self:draw()
end

---@param msg string
function Submissions:set_memory_error(msg)
    self.memory_state = "error"
    self.similar_state = "error"
    self.memory_message = msg
    self.similar_message = msg
    self.memory_summary = nil
    self:draw()
end

---@param summary table
function Submissions:update_memory(summary)
    self.memory_summary = summary or {}
    self.memory_message = nil
    self.similar_message = nil
    local has_memory = summary and summary.has_history
    local has_similar = summary and (
        ((summary.similar_match_count or 0) > 0)
        or (type(summary.similar_matches) == "table" and #summary.similar_matches > 0)
    )
    self.memory_state = has_memory and "ready" or "empty"
    self.similar_state = has_similar and "ready" or "empty"
    self.question.mem0_recall_summary = self.memory_summary
    self:draw()
end

function Submissions:refresh_memory()
    local ok, saver = pcall(require, "submission_db_saver")
    if not ok then
        self:set_memory_error("submission_db_saver.lua not found")
        return
    end

    self:set_memory_loading()
    saver.get_mem0_recall_summary(self.question, function(response)
        vim.schedule(function()
            if not self._.mounted then
                debug_log("refresh_memory callback ignored because panel unmounted")
                return
            end

            debug_log("refresh_memory response=" .. vim.inspect(response))
            if response.error then
                self:set_memory_error(response.error)
                return
            end

            self:update_memory(response)
        end)
    end)
end

---@param tab "submissions"|"memory"|"similar"
function Submissions:switch_tab(tab)
    if self.active_tab == tab then
        return
    end

    self.active_tab = tab
    self:draw()
end

function Submissions:fetch()
    debug_log("fetch begin for " .. self.question.q.title_slug)
    self:set_loading()
    self:set_memory_loading()

    local ok, saver = pcall(require, "submission_db_saver")
    if not ok then
        self:set_error("submission_db_saver.lua not found")
        self:set_memory_error("submission_db_saver.lua not found")
        return
    end

    saver.get_past_submissions(self.question, function(response)
        vim.schedule(function()
            if not self._.mounted then
                debug_log("callback ignored because panel unmounted")
                return
            end

            debug_log("callback response=" .. vim.inspect(response))
            if response.error then
                self:set_error(response.error)
                return
            end

            local submissions = response.submissions or {}
            self.question.past_submissions = submissions
            self:update_submissions(submissions)
        end)
    end, config.user.description.submissions.limit)

    saver.get_mem0_recall_summary(self.question, function(response)
        vim.schedule(function()
            if not self._.mounted then
                debug_log("mem0 callback ignored because panel unmounted")
                return
            end

            debug_log("mem0 callback response=" .. vim.inspect(response))
            if response.error then
                self:set_memory_error(response.error)
                return
            end

            self:update_memory(response)
        end)
    end)
end

function Submissions:mount()
    Submissions.super.mount(self)
    active_panels_by_slug[self.question.q.title_slug] = self
    self:fetch()
    self:map("n", { "1", "<leader>1" }, function()
        self:switch_tab("submissions")
    end)
    self:map("n", { "2", "<leader>2" }, function()
        self:switch_tab("memory")
    end)
    self:map("n", { "3", "<leader>3" }, function()
        self:switch_tab("similar")
    end)

    local ui_utils = require("leetcode-ui.utils")
    ui_utils.buf_set_opts(self.bufnr, {
        modifiable = false,
        buflisted = false,
        swapfile = false,
        buftype = "nofile",
        filetype = config.name,
    })
    ui_utils.win_set_opts(self.winid, {
        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
        wrap = false,
        colorcolumn = "",
        foldcolumn = "0",
        cursorcolumn = false,
        cursorline = false,
        number = false,
        relativenumber = false,
        list = false,
        spell = false,
        signcolumn = "no",
        linebreak = false,
    })
    ui_utils.win_set_winfixbuf(self.winid)

    self:draw()
    return self
end

function Submissions:unmount()
    if active_panels_by_slug[self.question.q.title_slug] == self then
        active_panels_by_slug[self.question.q.title_slug] = nil
    end
    return Submissions.super.unmount(self)
end

---@param parent lc.ui.Question
function Submissions:init(parent)
    Submissions.super.init(self, {
        relative = {
            type = "win",
            winid = parent.description.winid,
        },
        position = "bottom",
        size = config.user.description.submissions.height,
        enter = false,
        focusable = true,
    })

    self.question = parent
    self.active_tab = "submissions"
    self.submissions_state = "loading"
    self.memory_state = "loading"
    self.similar_state = "loading"
    self.submissions = parent.past_submissions or {}
    self.memory_summary = parent.mem0_recall_summary
end

---@type fun(parent: lc.ui.Question): lc.ui.Submissions
local LeetSubmissions = Submissions

function LeetSubmissions.refresh_memory_for_slug(title_slug)
    local panel = active_panels_by_slug[title_slug]
    if not panel or not panel._.mounted then
        return false
    end

    panel:refresh_memory()
    return true
end

return LeetSubmissions
