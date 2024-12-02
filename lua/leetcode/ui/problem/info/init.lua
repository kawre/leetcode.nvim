local markup = require("markup")
local u = require("leetcode.utils")
local log = require("leetcode.logger")
local t = require("leetcode.translator")
local problemlist = require("leetcode.cache.problemlist")
local config = require("leetcode.config")
local icons = config.icons

---@class leet.ui.Problem.Info : markup.Renderer
---@field protected super markup.Renderer
---@field problem leet.ui.Problem
local ProblemInfo = markup.Renderer:extend("markup.problem.info") ---@diagnostic disable-line: undefined-field

---@param problem leet.ui.Problem
function ProblemInfo:init(problem)
    ProblemInfo.super.init(self, {
        position = "float",
        config = {
            width = 0.5,
            height = 0.5,
            border = "rounded",
            title = " Problem Info ",
            title_pos = "center",
        },
        win_opts = {
            wrap = true,
        },
        show = false,
        enter = true,
    })
    self.problem = problem
end

function ProblemInfo:build_hints()
    local hints = self.problem.q.hints

    local children = {}
    local total = #hints

    for i, hint in ipairs(hints) do
        local tree = markup.Tree({
            title = ("%d/%d"):format(i, total),
            children = { markup.Block(hint) },
        })
        table.insert(children, tree)
    end

    return markup.Tree({
        title = t("Hints"),
        children = children,
    })
end

function ProblemInfo:build_tags()
    local tags = self.problem.q.topic_tags

    local children = {}

    for _, topic in ipairs(tags) do
        table.insert(children, markup.Block(topic.name, "leetcode_tag"))
    end

    return markup.Tree({
        title = t("Topics"),
        children = children,
    })
end

function ProblemInfo:build_similar_questions()
    local similar = self.problem.q.similar

    local children = {}

    for _, problem in ipairs(similar) do
        local ok, cache = pcall(problemlist.get_by_title_slug, problem.title_slug)

        if ok then
            local elem = markup.HFlex({
                spacing = 1,
                on_submit = function()
                    local Problem = require("leetcode.ui.problem")
                    Problem(cache):mount()
                end,
                children = {
                    markup.Inline(icons.square, u.diff_to_hl(cache.difficulty)),
                    markup.Inline(u.translate(cache.title, cache.title_cn)),
                    markup.If(
                        cache.paid_only,
                        markup.Inline({
                            config.auth.is_premium and { icons.unlock }
                                or { icons.lock, " ", t("Premium") },
                        }, "leetcode_medium")
                    ),
                },
            })

            table.insert(children, elem)
        end
    end

    return markup.Tree({
        title = t("Similar Questions"),
        children = children,
    })
end

function ProblemInfo:render()
    ProblemInfo.super.render(
        self,
        markup.Flex({
            spacing = 2,
            children = {
                self:build_hints(),
                self:build_tags(),
                self:build_similar_questions(),
            },
        })
    )
end

return ProblemInfo
