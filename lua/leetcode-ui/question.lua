local Description = require("leetcode-ui.split.description")
local Console = require("leetcode-ui.layout.console")
local Info = require("leetcode-ui.popup.info")
local Object = require("nui.object")

local api_question = require("leetcode.api.question")
local utils = require("leetcode.utils")
local config = require("leetcode.config")
local log = require("leetcode.logger")

---@class lc-ui.Question
---@field file Path
---@field q lc.question_res
---@field description lc.ui.Description
---@field bufnr integer
---@field console lc.ui.Console
---@field lang string
---@field cache lc.cache.Question
local Question = Object("LeetQuestion")

function Question:get_snippet()
    local snippets = self.q.code_snippets ~= vim.NIL and self.q.code_snippets or {}
    return vim.tbl_filter(function(snip) return snip.lang_slug == self.lang end, snippets)[1]
end

---@private
function Question:create_file()
    local lang = utils.get_lang(self.lang)
    local fn = ("%s.%s-%s.%s"):format(self.q.frontend_id, self.q.title_slug, lang.slug, lang.ft)

    self.file = config.home:joinpath(fn)
    if not self.file:exists() then self.file:write(self:get_snippet().code, "w") end
end

function Question:unmount()
    vim.schedule(function()
        self.info:unmount()
        self.console:unmount()
        self.description:unmount()

        if vim.api.nvim_buf_is_valid(self.bufnr) then
            vim.api.nvim_buf_delete(self.bufnr, { force = true })
        end
        if vim.api.nvim_win_is_valid(self.winid) then --
            vim.api.nvim_win_close(self.winid, true)
        end

        _Lc_questions = vim.tbl_filter(function(q) return q.bufnr ~= self.bufnr end, _Lc_questions)
    end)
end

function Question:handle_mount()
    self:create_file()

    vim.api.nvim_set_current_dir(config.home:absolute())
    vim.cmd("$tabe " .. self.file:absolute())

    utils.exec_hooks("LeetQuestionNew", {
        lang = self.lang,
    })

    -- https://github.com/kawre/leetcode.nvim/issues/14
    if self.lang == "rust" then pcall(require("rust-tools.standalone").start_standalone_client) end

    self.bufnr = vim.api.nvim_get_current_buf()
    self.winid = vim.api.nvim_get_current_win()
    table.insert(_Lc_questions, self)

    vim.api.nvim_create_autocmd("BufWinLeave", {
        buffer = self.bufnr,
        callback = function() self:unmount() end,
    })

    self.description = Description(self):mount()
    self.console = Console(self)
    self.info = Info(self)

    return self
end

function Question:mount()
    local tabp = utils.detect_duplicate_question(self.cache.title_slug, config.lang)
    if tabp then return pcall(vim.cmd.tabnext, tabp) end

    local q = api_question.by_title_slug(self.cache.title_slug)
    if not q or q.is_paid_only and not config.auth.is_premium then
        return log.warn("Question is for premium users only")
    end
    self.q = q

    if self:get_snippet() then
        self:handle_mount()
    else
        local msg = ("Snippet for `%s` not found. Select a different language"):format(self.lang)
        log.warn(msg)

        require("leetcode.pickers.language").pick_lang(self, function(snippet)
            self.lang = snippet.t.slug
            self:handle_mount()
        end)
    end

    return self
end

---@param problem lc.cache.Question
function Question:init(problem)
    self.cache = problem
    self.lang = config.lang
end

---@type fun(question: lc.cache.Question): lc-ui.Question
local LeetQuestion = Question

return LeetQuestion
