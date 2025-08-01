local Button = require("leetcode-ui.lines.button")
local Group = require("leetcode-ui.group")
local NuiTree = require("nui.tree")

local problemlist = require("leetcode.cache.problems")
local config = require("leetcode.config")
local utils = require("leetcode.util")
local ui_utils = require("leetcode-ui.utils")

local t = require("leetcode.translator")

---@class lc.ui.SimilarQuestions : lc.ui.Group
local SimilarQuestions = Group:extend("LeetSimilarQuestions")

---@param questions lc.QuestionResponse.similar
---
---@return lc.ui.Lines
function SimilarQuestions:init(questions)
    SimilarQuestions.super.init(self)

    for _, q in ipairs(questions) do
        local ok, p = pcall(problemlist.by_slug, q.title_slug)

        if ok then
            local button = Button({}, {
                on_press = function()
                    local Question = require("leetcode-ui.question")
                    Question(p):mount()
                end,
            })

            local fid = p.frontend_id .. "."
            fid = fid .. (" "):rep(5 - vim.api.nvim_strwidth(fid))

            button:append(config.icons.square .. " ", ui_utils.diff_to_hl(p.difficulty))
            button:append(fid .. " ", "leetcode_normal")
            button:append(utils.translate(p.title, p.title_cn))

            if q.paid_only then
                local txt

                if config.auth.is_premium then
                    txt = " " .. config.icons.unlock
                else
                    txt = (" %s "):format(config.icons.lock) .. t("Premium")
                end

                button:append(txt, "leetcode_medium")
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
