local config = require("leetcode.config")

local Group = require("leetcode-ui.group")
local Padding = require("leetcode-ui.lines.padding")
local Popup = require("leetcode-ui.popup")

local api_question = require("leetcode.api.question")
local log = require("leetcode.logger")
local t = require("leetcode.translator")
local utils = require("leetcode.utils")

---@class lc.ui.Editorial : lc.ui.Popup
---@field question lc.ui.Question
---@field loaded boolean
local Editorial = Popup:extend("LeetEditorial")

function Editorial:mount()
    Editorial.super.mount(self)

    self:populate()

    local ui_utils = require("leetcode-ui.utils")
    local winhighlight = "Normal:NormalSB,FloatBorder:FloatBorder"

    ui_utils.win_set_opts(self.winid, {
        winhighlight = winhighlight,
        wrap = true,
        linebreak = true,
    })
    ui_utils.win_set_opts(self.border.winid, {
        winhighlight = winhighlight,
    })

    self:draw()
    return self
end

---Show the popup, fetching the editorial on first open.
function Editorial:show()
    Editorial.super.show(self)
    if not self.loaded then
        self:load()
    end
end

---Fetch the editorial (curl is sync, so schedule it) and render it. Only the
---guaranteed-to-fail premium case is short-circuited without a request:
---editorials are only *sometimes* gated, so free-problem editorials still load.
function Editorial:load()
    local q = self.question and self.question.q
    if not q or type(q.title_slug) ~= "string" then
        self.loaded = true
        return self:set_status("No problem is open")
    end
    if q.is_paid_only and not config.auth.is_premium then
        self.loaded = true
        return self:set_status("Editorial is for premium users only")
    end

    self:set_status("Loading editorial…")

    vim.schedule(function()
        local ok, article, err = pcall(api_question.editorial, q.title_slug)
        if not self:is_alive() then -- popup closed mid-fetch
            return
        end
        self.loaded = true

        if not ok then
            log.debug("editorial fetch error: " .. tostring(article))
            return self:set_status("Failed to load editorial")
        elseif not article then
            return self:set_status(err and err.msg or "No editorial available for this problem")
        end

        -- Playground fetches + markdown parse: degrade to a message on error.
        local rendered, perr = pcall(function()
            self.content = self:inline_playgrounds(article.content)
            self:populate()
            self:draw()
        end)
        if not rendered then
            log.debug("editorial render error: " .. tostring(perr))
            self.content = nil
            self:set_status("Failed to render editorial")
        end
    end)
end

---@return boolean # true while the popup still has a buffer to render into
function Editorial:is_alive()
    return self.bufnr ~= nil and vim.api.nvim_buf_is_valid(self.bufnr)
end

---Replace each editorial `<iframe .../playground/<uuid>/shared>` with a fenced
---code block holding that playground's code. Results are cached per uuid.
---
---@param content string
---@return string
function Editorial:inline_playgrounds(content)
    if type(content) ~= "string" then
        return ""
    end
    self._playground_cache = self._playground_cache or {}

    return (content:gsub("<iframe[^>]-/playground/([%w%-_]+)/shared[^>]->%s*</iframe>", function(uuid)
        local codes = self._playground_cache[uuid]
        if not codes then
            codes = api_question.playground(uuid)
            self._playground_cache[uuid] = codes
        end
        if vim.tbl_isempty(codes) then
            return ("[playground: https://leetcode.%s/playground/%s/shared]"):format(config.domain, uuid)
        end

        local blocks = {}
        for _, c in ipairs(codes) do
            blocks[#blocks + 1] = ("```%s\n%s\n```"):format(c.lang_slug or "", c.code or "")
        end
        return "\n" .. table.concat(blocks, "\n\n") .. "\n"
    end))
end

---Render a single status/message line (used before content loads or on error).
---
---@param msg string
function Editorial:set_status(msg)
    self.status = msg
    if not self:is_alive() then
        return
    end
    self:populate()
    self:draw()
end

local RULE = "────"

-- LaTeX macros → Unicode (the ones that actually show up in editorials).
local MATH_MACROS = {
    cdot = "·", times = "×", div = "÷", pm = "±", ["approx"] = "≈",
    leq = "≤", geq = "≥", neq = "≠", ll = "≪", gg = "≫",
    infty = "∞", rightarrow = "→", leftarrow = "←", Rightarrow = "⇒",
    ldots = "…", dots = "…", cdots = "…", log = "log", min = "min", max = "max",
    sum = "∑", prod = "∏", in_ = "∈", forall = "∀", exists = "∃",
}
-- Unicode sub/superscript glyphs; missing chars fall back to `_x` / `^x`.
local SUP = { ["0"]="⁰",["1"]="¹",["2"]="²",["3"]="³",["4"]="⁴",["5"]="⁵",["6"]="⁶",["7"]="⁷",["8"]="⁸",["9"]="⁹",["n"]="ⁿ",["i"]="ⁱ",["+"]="⁺",["-"]="⁻" }
local SUB = { ["0"]="₀",["1"]="₁",["2"]="₂",["3"]="₃",["4"]="₄",["5"]="₅",["6"]="₆",["7"]="₇",["8"]="₈",["9"]="₉",["+"]="₊",["-"]="₋",["a"]="ₐ",["e"]="ₑ",["i"]="ᵢ",["j"]="ⱼ",["n"]="ₙ",["x"]="ₓ" }

---Convert a single sub/superscript argument to Unicode, or fall back to `pre..s`.
---@param s string
---@param map table<string,string>
---@param pre string
---@return string
local function to_script(s, map, pre)
    local out, ok = {}, true
    for ch in s:gmatch(".") do
        if map[ch] then
            out[#out + 1] = map[ch]
        else
            ok = false
            break
        end
    end
    return ok and table.concat(out) or (pre .. s)
end

---Turn LeetCode's inline/display LaTeX (`$...$`, `$$...$$`) into readable plain
---text: unwrap `\text{}`/`\mathcal{}`/`\large{}` etc., map known macros to
---Unicode, convert simple `_x`/`^2` scripts, and drop the `$` delimiters. Not a
---full LaTeX engine — just the lightweight notation editorials actually use.
---@param line string
---@return string
local function normalize_math(line)
    if not line:find("%$") then
        return line
    end

    local function render(math)
        -- Unwrap sizing/font wrappers, keeping their inner content.
        for _ = 1, 4 do -- nested a few levels deep in practice
            math = math:gsub("\\%a+{([^{}]*)}", "%1")
        end
        math = math:gsub("\\left", ""):gsub("\\right", "")
        -- Macros → Unicode (\cdot, \leq, …). Longest names first via word bound.
        math = math:gsub("\\(%a+)", function(m)
            return MATH_MACROS[m] or MATH_MACROS[m .. "_"] or m
        end)
        -- Sub/superscripts: `^{...}` / `_{...}` and single-char `^2` / `_i`.
        math = math:gsub("%^{([^{}]*)}", function(s) return to_script(s, SUP, "^") end)
        math = math:gsub("_{([^{}]*)}", function(s) return to_script(s, SUB, "_") end)
        math = math:gsub("%^(%w)", function(s) return to_script(s, SUP, "^") end)
        math = math:gsub("_(%w)", function(s) return to_script(s, SUB, "_") end)
        return (math:gsub("[{}]", ""):gsub("\\", ""))
    end

    -- Display math first (`$$...$$`), then inline (`$...$`).
    line = line:gsub("%$%$(.-)%$%$", render)
    line = line:gsub("%$([^%$]+)%$", render)
    return line
end

---@private
---Convert markdown into a Group of styled lines: headings, fenced code blocks,
---bullet/numbered lists, blockquotes, horizontal rules, and inline
---`code`/**bold**/*italic*. Unrecognized lines become plain prose.
---
---@param md string
---@return lc.ui.Group
function Editorial:parse_markdown(md)
    local group = Group()
    if type(md) ~= "string" then
        return group
    end

    local in_code = false
    for _, raw in ipairs(vim.split((md:gsub("\r\n", "\n")), "\n", { plain = true })) do
        if raw:match("^%s*```") then
            in_code = not in_code
            group:append(RULE, "leetcode_indent"):endgrp()
        elseif in_code then
            group:append(raw ~= "" and raw or " ", "leetcode_code"):endgrp()
        else
            self:parse_prose_line(group, raw)
        end
    end

    return group
end

---@private
---@param group lc.ui.Group
---@param raw string
function Editorial:parse_prose_line(group, raw)
    if raw:match("^%s*%[TOC%]%s*$") then -- LeetCode injects this marker; drop it.
        return
    elseif raw:match("^%s*$") then
        return group:insert(Padding(1))
    elseif raw:match("^%s*%-%-%-+%s*$") or raw:match("^%s*%*%*%*+%s*$") then
        return group:append(RULE, "leetcode_indent"):endgrp()
    end

    raw = normalize_math(raw)

    local hashes, htext = raw:match("^(#+)%s+(.*)$")
    if hashes then
        group:insert(Padding(1))
        self:append_inline(group, htext, #hashes <= 2 and "leetcode_normal" or "leetcode_hint")
        return group:endgrp()
    end

    -- Prefixed lines: bullet, numbered, blockquote. Each gets a styled marker
    -- then inline-styled text; anything else is plain prose.
    local bullet = raw:match("^%s*[%*%-%+]%s+(.*)$")
    local num, ntext = raw:match("^%s*(%d+)%.%s+(.*)$")
    local quote = raw:match("^%s*>%s?(.*)$")
    if bullet then
        group:append("  • ", "leetcode_hint")
        self:append_inline(group, bullet)
    elseif num then
        group:append(("  %s. "):format(num), "leetcode_hint")
        self:append_inline(group, ntext)
    elseif quote then
        group:append("  │ ", "leetcode_ref")
        self:append_inline(group, quote, "leetcode_ref")
    else
        self:append_inline(group, raw)
    end
    group:endgrp()
end

-- Inline emphasis spans, ordered so `**bold**` is tried before `*italic*`.
local SPANS = {
    { pat = "`([^`]+)`", hl = "leetcode_code" },
    { pat = "%*%*([^%*]+)%*%*", hl = "leetcode_normal" },
    { pat = "%*([^%*]+)%*", hl = "leetcode_hint" },
}

---@private
---Append `text` to the current line, styling inline `code`, **bold** and
---*italic* spans. `default_hl` colors the surrounding prose.
---
---@param group lc.ui.Group
---@param text string
---@param default_hl? string
function Editorial:append_inline(group, text, default_hl)
    default_hl = default_hl or "leetcode_alt"

    -- Flatten `[label](url)` links to "label (url)" (bare URL if unlabeled).
    text = text:gsub("!?%[([^%]]*)%]%(([^%)]*)%)", function(label, url)
        return (label == "" and "(" .. url .. ")") or (label .. " (" .. url .. ")")
    end)

    local i = 1
    while i <= #text do
        local best_s, best_e, best_body, best_hl
        for _, span in ipairs(SPANS) do
            local s, e, body = text:find(span.pat, i)
            if s and (not best_s or s < best_s) then
                best_s, best_e, best_body, best_hl = s, e, body, span.hl
            end
        end

        if not best_s then
            group:append(text:sub(i), default_hl)
            break
        end
        if best_s > i then
            group:append(text:sub(i, best_s - 1), default_hl)
        end
        group:append(best_body, best_hl)
        i = best_e + 1
    end
end

---@private
function Editorial:populate()
    local q = self.question and self.question.q or {}
    local cache = self.question and self.question.cache or {}

    local header = Group({}, { position = "center" })

    header:append(cache.link or "", "leetcode_alt")
    header:endgrp()

    header:insert(Padding(1))

    header:append((q.frontend_id and (q.frontend_id .. ". ") or ""), "leetcode_normal")
    header:append(utils.translate(q.title or "", q.translated_title))
    header:endgrp()

    header:append(t("Editorial") .. " ", "leetcode_hint")
    header:endgrp()

    local body
    if self.content then
        body = self:parse_markdown(self.content)
    else
        body = Group()
        body:append(self.status or "Loading editorial…", "leetcode_alt"):endgrp()
    end

    self.renderer:replace({
        header,
        Padding(3),
        body,
    })
end

---@param parent lc.ui.Question
function Editorial:init(parent)
    Editorial.super.init(self, {
        position = "50%",
        size = {
            width = "80%",
            height = "85%",
        },
        enter = true,
        focusable = true,
        relative = "editor",
        border = {
            padding = {
                top = 1,
                bottom = 1,
                left = 3,
                right = 3,
            },
            style = "rounded",
            text = {
                top = (" %s "):format(t("Editorial")),
            },
        },
        buf_options = {
            modifiable = false,
            readonly = false,
        },
    })

    self.question = parent
    self.loaded = false
    self.content = nil
    self.status = nil
end

---@type fun(parent: lc.ui.Question): lc.ui.Editorial
local LeetEditorial = Editorial

return LeetEditorial
