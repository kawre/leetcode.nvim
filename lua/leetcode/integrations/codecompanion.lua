local config = require("leetcode.config")
local lc_utils = require("leetcode.utils")

local M = {}
local active_chats_by_slug = {}
local FENCE = "````"

local function notify(message, level)
    vim.notify(message, level or vim.log.levels.INFO, { title = "leetcode.nvim" })
end

local function current_question()
    local current_tab = vim.api.nvim_get_current_tabpage()
    for _, entry in ipairs(lc_utils.question_tabs()) do
        if entry.tabpage == current_tab then
            return entry.question
        end
    end
end

local function question_slug(question)
    return question and question.q and question.q.title_slug or ""
end

local function is_chat_valid(chat)
    return chat
        and type(chat) == "table"
        and chat.bufnr
        and vim.api.nvim_buf_is_valid(chat.bufnr)
        and vim.api.nvim_buf_is_loaded(chat.bufnr)
end

local function bind_chat(title_slug, chat)
    if title_slug == "" or not is_chat_valid(chat) then
        return
    end
    active_chats_by_slug[title_slug] = chat
end

local function has_code_fence(content)
    return type(content) == "string" and (content:find("```", 1, true) ~= nil)
end

local function is_blank(line)
    return vim.trim(line) == ""
end

local function is_code_like_line(line)
    local trimmed = vim.trim(line)
    if trimmed == "" then
        return false
    end

    if line:match("^%s%s%s%s+") or line:match("^\t+") then
        return true
    end

    if trimmed:match("^#") or trimmed:match('^"""') or trimmed:match("^'''") then
        return true
    end

    if trimmed:match("^class%s+[%w_]+") or trimmed:match("^def%s+[%w_]+") then
        return true
    end

    if trimmed:match("^[%w_%.]+%s*=%s*.+") then
        return true
    end

    if trimmed:match("^[%w_%.]+%b()%s*:?$") then
        return true
    end

    if
        trimmed:match("^(from|import|return|yield|break|continue|pass)%f[%W]")
        or trimmed:match("^(if|elif|else|for|while|with|try|except|finally)%f[%W]")
    then
        return true
    end

    if trimmed:match("->") or trimmed:match("[%[%]{}]") then
        return true
    end

    return false
end

local function find_trailing_code_block(lines)
    local block_end
    for index = #lines, 1, -1 do
        if not is_blank(lines[index]) then
            block_end = index
            break
        end
    end

    if not block_end then
        return nil
    end

    local code_lines = 0
    local nonempty_lines = 0
    local block_start = block_end

    for index = block_end, 1, -1 do
        local line = lines[index]
        if is_blank(line) then
            block_start = index
        elseif is_code_like_line(line) then
            block_start = index
            code_lines = code_lines + 1
            nonempty_lines = nonempty_lines + 1
        else
            break
        end
    end

    if nonempty_lines < 4 or code_lines < 4 then
        return nil
    end

    if code_lines / nonempty_lines < 0.7 then
        return nil
    end

    return block_start, block_end
end

local function auto_fence_code_blocks(content, lang)
    if type(content) ~= "string" or content == "" or has_code_fence(content) then
        return content, false
    end

    local lines = vim.split(content, "\n", { plain = true, trimempty = false })
    local block_start, block_end = find_trailing_code_block(lines)
    if not block_start or not block_end then
        return content, false
    end

    local updated = {}
    for index = 1, block_start - 1 do
        table.insert(updated, lines[index])
    end
    table.insert(updated, ("%s%s"):format(FENCE, lang or "text"))
    for index = block_start, block_end do
        table.insert(updated, lines[index])
    end
    table.insert(updated, FENCE)
    for index = block_end + 1, #lines do
        table.insert(updated, lines[index])
    end

    return table.concat(updated, "\n"), true
end

local function rerender_chat(chat)
    if not (chat and chat.ui) then
        return
    end

    chat.ui:render(chat.buffer_context, vim.deepcopy(chat.messages), {
        stop_context_insertion = true,
    })
    if chat.context then
        chat.context:render()
    end
end

local function normalize_latest_llm_message(chat, lang)
    if not is_chat_valid(chat) then
        return
    end

    for index = #chat.messages, 1, -1 do
        local message = chat.messages[index]
        if message.role == config.constants.LLM_ROLE and type(message.content) == "string" and message.content ~= "" then
            message._meta = message._meta or {}
            if message._meta.leetcode_auto_fenced then
                return
            end

            local normalized, changed = auto_fence_code_blocks(message.content, lang)
            if not changed then
                return
            end

            message.content = normalized
            message._meta.leetcode_auto_fenced = true
            rerender_chat(chat)
            return
        end
    end
end

local function unbind_chat(title_slug, chat)
    if title_slug == "" then
        return
    end

    if active_chats_by_slug[title_slug] == chat then
        active_chats_by_slug[title_slug] = nil
    end
end

local function current_chat_for_slug(title_slug)
    local chat = active_chats_by_slug[title_slug]
    if not is_chat_valid(chat) then
        active_chats_by_slug[title_slug] = nil
        return nil
    end
    return chat
end

local function chat_has_context_id(chat, context_id)
    local items = chat and chat.context_items or {}
    for _, item in ipairs(items) do
        if item.id == context_id then
            return true
        end
    end
    return false
end

local function require_question()
    local question = current_question()
    if not question then
        notify("CodeCompanionChat requires an active leetcode question", vim.log.levels.WARN)
        return nil
    end
    return question
end

local function current_code(question)
    if not (question and question.bufnr and vim.api.nvim_buf_is_valid(question.bufnr)) then
        return question and question:snippet(true) or ""
    end

    local range = question:editor_section_range("code")
    if range.complete then
        return table.concat(range.lines, "\n", range.start_i, range.end_i)
    end

    return question:snippet(true) or ""
end

local function question_description(question)
    local q = question.q or {}
    local content = type(q.content) == "string" and q.content or ""
    local translated = type(q.translated_content) == "string" and q.translated_content or ""
    return lc_utils.translate(content, translated)
end

local function question_tags(question)
    local tags = {}
    local topic_tags = type(question.q.topic_tags) == "table" and question.q.topic_tags or {}
    for _, tag in ipairs(topic_tags) do
        table.insert(tags, tag.name or tag.slug or "")
    end
    return vim.tbl_filter(function(tag)
        return tag ~= ""
    end, tags)
end

local function question_hints(question)
    local hints = type(question.q.hints) == "table" and question.q.hints or {}
    return vim.tbl_map(function(hint)
        return tostring(hint)
    end, hints)
end

function M.build_context(question)
    return {
        title = question.q.title or "",
        title_slug = question.q.title_slug or "",
        difficulty = question.q.difficulty or "",
        lang = question.lang or config.lang,
        description = question_description(question),
        tags = question_tags(question),
        hints = question_hints(question),
        code = current_code(question),
        testcase = question.console and question.console.testcase and question.console.testcase:content() or "",
    }
end

function M.render_context(context)
    local parts = {
        "# LeetCode Problem Context",
        "",
        ("- Title: %s"):format(context.title),
        ("- Title Slug: %s"):format(context.title_slug),
        ("- Difficulty: %s"):format(context.difficulty),
        ("- Language: %s"):format(context.lang),
    }

    if not vim.tbl_isempty(context.tags) then
        table.insert(parts, ("- Tags: %s"):format(table.concat(context.tags, ", ")))
    end

    table.insert(parts, "")
    table.insert(parts, "## Problem Description")
    table.insert(parts, context.description ~= "" and context.description or "(empty)")

    if not vim.tbl_isempty(context.hints) then
        table.insert(parts, "")
        table.insert(parts, "## Hints")
        for index, hint in ipairs(context.hints) do
            table.insert(parts, ("%d. %s"):format(index, hint))
        end
    end

    if context.testcase ~= "" then
        table.insert(parts, "")
        table.insert(parts, "## Active Testcase")
        table.insert(parts, "```text")
        table.insert(parts, context.testcase)
        table.insert(parts, "```")
    end

    table.insert(parts, "")
    table.insert(parts, "## Current Code")
    table.insert(parts, ("```%s"):format(context.lang))
    table.insert(parts, context.code ~= "" and context.code or "")
    table.insert(parts, "```")

    return table.concat(parts, "\n")
end

function M.render_failure_event_context(event)
    local parts = {
        "# LeetCode Failure Event",
        "",
        ("- Title Slug: %s"):format(event.title_slug),
        ("- Event ID: %s"):format(event.event_id),
        "- Source: submission-service",
        "- This failure event is already stored in the active submission-service session memory.",
    }

    if event.summary ~= "" then
        table.insert(parts, "")
        table.insert(parts, "## Latest Failure Summary")
        table.insert(parts, event.summary)
    end

    if type(event.annotation_count) == "number" and event.annotation_count > 0 then
        table.insert(parts, "")
        table.insert(parts, ("- Annotation Count: %d"):format(event.annotation_count))
    end

    return table.concat(parts, "\n")
end

function M.render_failure_event(question, event)
    local title_slug = question_slug(question)
    local event_id = type(event) == "table" and event.event_id or ""
    if title_slug == "" or type(event_id) ~= "string" or event_id == "" then
        return false
    end

    local chat = current_chat_for_slug(title_slug)
    if not chat then
        return false
    end

    local context_id = ("<leetcode_failure:%s>"):format(event_id)
    if chat_has_context_id(chat, context_id) then
        return true
    end

    chat:add_context(
        {
            role = "user",
            content = M.render_failure_event_context({
                title_slug = title_slug,
                event_id = event_id,
                summary = type(event.summary) == "string" and event.summary or "",
                annotation_count = tonumber(event.count) or 0,
            }),
        },
        "leetcode",
        context_id,
        {
            visible = false,
            tag = "leetcode_failure_event",
        }
    )

    if chat.refresh_context then
        chat:refresh_context()
    end

    chat:add_buf_message({
        role = "user",
        content = ("Attached failure event `%s` to this session."):format(event_id),
    })

    return true
end

function M.open(opts)
    opts = opts or {}

    local question = require_question()
    if not question then
        return
    end

    local ok, codecompanion = pcall(require, "codecompanion")
    if not ok then
        notify("CodeCompanion is not available", vim.log.levels.ERROR)
        return
    end

    local cc = config.user.companion or {}
    local prompt = opts.prompt or cc.default_prompt or ""
    local auto_submit = cc.auto_submit ~= false
    local auto_fence = cc.auto_fence_code ~= false
    local params = {
        adapter = cc.adapter,
    }

    if cc.model and cc.model ~= "" then
        params.model = cc.model
    end

    local context = M.build_context(question)
    local title_slug = question_slug(question)
    return codecompanion.chat({
        auto_submit = auto_submit,
        ignore_system_prompt = true,
        params = params,
        title = ("LeetCode: %s"):format(context.title ~= "" and context.title or context.title_slug),
        user_prompt = prompt,
        window_opts = cc.window,
        callbacks = {
            on_created = function(chat)
                bind_chat(title_slug, chat)
                chat:add_context(
                    {
                        role = "user",
                        content = M.render_context(context),
                    },
                    "leetcode",
                    ("<leetcode:%s>"):format(context.title_slug ~= "" and context.title_slug or chat.id),
                    {
                        visible = false,
                        tag = "leetcode_context",
                    }
                )
            end,
            on_completed = function(chat)
                if auto_fence and auto_submit then
                    normalize_latest_llm_message(chat, context.lang)
                end
            end,
            on_closed = function(chat)
                unbind_chat(title_slug, chat)
            end,
        },
    })
end

function M.toggle_or_open()
    return M.prompt_and_open()
end

function M.prompt_and_open()
    local cc = config.user.companion or {}
    local default_prompt = cc.default_prompt or ""

    if cc.prompt_user == false then
        return M.open({ prompt = default_prompt })
    end

    vim.ui.input({
        prompt = "What do you want help with? ",
        default = default_prompt,
    }, function(input)
        if input == nil then
            return
        end

        local prompt = vim.trim(input)
        if prompt == "" then
            prompt = default_prompt
        end

        M.open({ prompt = prompt })
    end)
end

function M.command(opts)
    opts = opts or {}
    local fargs = opts.fargs or {}

    if #fargs == 0 then
        return M.prompt_and_open()
    end

    return M.open({ prompt = table.concat(fargs, " ") })
end

function M.clear(question)
    unbind_chat(question_slug(question), current_chat_for_slug(question_slug(question)))
end

return M
