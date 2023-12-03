local Button = require("leetcode-ui.lines.button")
local Group = require("leetcode-ui.group")
local NuiTree = require("nui.tree")

local problemlist = require("leetcode.cache.problemlist")
local config = require("leetcode.config")
local utils = require("leetcode.utils")
local ui_utils = require("leetcode-ui.utils")

local t = require("leetcode.translator")

---@class lc.ui.SimilarQuestions : lc.ui.Lines
local SimilarQuestions = Group:extend("LeetSimilarQuestions")

---@param questions lc.QuestionResponse.similar
---
---@return lc.ui.Lines
function SimilarQuestions:init(questions)
    SimilarQuestions.super.init(self)

    for _, q in ipairs(questions) do
        local ok, p = pcall(problemlist.get_by_title_slug, q.title_slug)

        if ok then
            local button = Button({}, {
                on_press = function()
                    local Question = require("leetcode-ui.question")
                    Question(p):mount()
                end,
            })

            local fid = p.frontend_id .. "."
            fid = fid .. (" "):rep(5 - vim.api.nvim_strwidth(fid))

            button:append("󱓻 ", ui_utils.diff_to_hl(p.difficulty))
            button:append(fid .. " ", "leetcode_normal")
            button:append(utils.translate(p.title, p.title_cn))

            if not config.auth.is_premium and q.paid_only then
                button:append("  " .. t("Premium"), "leetcode_medium")
            end

            self:insert(button)
        end
    end
end

---@type fun(questions: lc.QuestionResponse.similar): lc.ui.Padding
local LeetSimilarQuestions = SimilarQuestions

function SimilarQuestions.static:to_nodes(questions) --
    local sim = LeetSimilarQuestions(questions)

    local tbl = {}
    for _, btn in ipairs(sim:contents()) do
        table.insert(tbl, NuiTree.Node({ text = btn }))
    end

    return tbl
end

return LeetSimilarQuestions
