local config = require("leetcode.config")
local utils = require("leetcode.utils")
local Button = require("leetcode-ui.lines.button")
local Line = require("leetcode-ui.line")
local problemlist = require("leetcode.cache.problemlist")
local Group = require("leetcode-ui.group")

local t = require("leetcode.translator")
local log = require("leetcode.logger")

---@class lc.ui.SimilarQuestions : lc.ui.Lines
local SimilarQuestions = Group:extend("LeetSimilarQuestions")

local hl = {
    ["Easy"] = "leetcode_easy",
    ["Medium"] = "leetcode_medium",
    ["Hard"] = "leetcode_hard",
}

---@param questions lc.QuestionResponse.similar
---
---@return lc.ui.Lines
function SimilarQuestions:init(questions)
    SimilarQuestions.super.init(self)

    for _, q in ipairs(questions) do
        local ok, p = pcall(problemlist.get_by_title_slug, q.title_slug)

        if ok then
            -- local button = Button()
            --
            -- line:append("󱓻 ", hl[p.difficulty])
            -- line:append(utils.translate(p.title, p.title_cn))
            --
            -- if not config.auth.is_premium and q.paid_only then
            --     line:append("  " .. t("Premium"), "leetcode_medium")
            -- end
            --
            -- line._.q = q
            -- self:insert(line)
        end
    end
end

---@type fun(questions: lc.QuestionResponse.similar): lc-ui.Padding
local LeetSimilarQuestions = SimilarQuestions

return LeetSimilarQuestions
