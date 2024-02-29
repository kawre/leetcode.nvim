local Popup = require("leetcode-ui.popup")
local NuiText = require("nui.text")
local t = require("leetcode.translator")
local Line = require("leetcode-ui.line")
local NuiTree = require("nui.tree")
local SimilarQuestions = require("leetcode-ui.group.similar-questions")
local Parser = require("leetcode.parser")

local config = require("leetcode.config")
local keys = config.user.keys
local utils = require("leetcode.utils")
local log = require("leetcode.logger")

---@class lc.ui.InfoPopup : lc.ui.Popup
---@field popup NuiPopup
---@field question lc.ui.Question
---@field hints table[]
local Info = Popup:extend("LeetInfoPopup")

function Info:similar_questions_node()
    local nodes = SimilarQuestions:to_nodes(self.question.q.similar)

    if not vim.tbl_isempty(nodes) then
        return NuiTree.Node(
            { text = NuiText(t("Similar Questions") .. " ", "leetcode_ref") },
            nodes
        )
    else
        return NuiTree.Node({
            text = NuiText(" " .. t("No similar questions available"), "leetcode_error"),
        })
    end
end

function Info:hints_node()
    local hints = {}
    for i, hint_txt in ipairs(self.hints) do
        local line = Line()

        line:append(tostring(i), "leetcode_list")
        line:append("/" .. #self.hints, "leetcode_alt")

        local hint = NuiTree.Node({ text = line }, { NuiTree.Node({ text = hint_txt }) })
        table.insert(hints, hint)
    end

    if not vim.tbl_isempty(hints) then
        return NuiTree.Node({ text = NuiText(t("Hints") .. " 󰛨", "leetcode_hint") }, hints)
    else
        return NuiTree.Node({ text = NuiText(" " .. t("No hints available"), "leetcode_error") })
    end
end

function Info:topics_node()
    local topics = {}
    for _, topic in ipairs(self.question.q.topic_tags) do
        local line = Line()

        line:append("* ", "leetcode_list")
        line:append(topic.name)

        table.insert(topics, NuiTree.Node({ text = line }))
    end

    if not vim.tbl_isempty(topics) then
        return NuiTree.Node({ text = NuiText(t("Topics") .. " ", "Number") }, topics)
    else
        return NuiTree.Node({ text = NuiText(" " .. t("No topics available"), "leetcode_error") })
    end
end

function Info:populate()
    local nodes = {
        self:hints_node(),
        NuiTree.Node({ text = "" }),
        self:topics_node(),
        NuiTree.Node({ text = " " }),
        self:similar_questions_node(),
    }

    local tree = NuiTree({
        bufnr = self.bufnr,
        nodes = nodes,
        prepare_node = function(node)
            local line = Line()
            line:append(string.rep("  ", node:get_depth() - 1))

            if node:has_children() then
                line:append(node:is_expanded() and " " or " ", "leetcode_list")
                line:append(node.text)
            else
                if type(node.text) == "string" then
                    line:append("  ")
                    local txt = Parser:parse(node.text)
                    if txt:lines()[1] then
                        line:append(txt:lines()[1])
                    end
                else
                    line:append(node.text)
                end
            end

            return line
        end,
    })

    tree:render()

    self:map("n", keys.confirm, function()
        local node = tree:get_node()
        if not node then
            return
        end

        if node.text and node.text.press then
            node.text:press()
        end

        if not node:is_expanded() then
            node:expand()
        else
            node:collapse()
        end

        tree:render()
    end, { noremap = true, nowait = true })
end

function Info:mount()
    Info.super.mount(self)

    self:populate()

    local ui_utils = require("leetcode-ui.utils")
    local winhighlight = "Normal:NormalSB,FloatBorder:FloatBorder"

    ui_utils.set_win_opts(self.winid, {
        winhighlight = winhighlight,
        wrap = true,
    })

    ui_utils.set_win_opts(self.border.winid, {
        winhighlight = winhighlight,
    })

    return self
end

---@param parent lc.ui.Question
function Info:init(parent)
    Info.super.init(self, {
        position = "50%",
        size = {
            width = "50%",
            height = "50%",
        },
        enter = true,
        focusable = true,
        relative = "editor",
        border = {
            padding = {
                top = 2,
                bottom = 2,
                left = 3,
                right = 3,
            },
            style = "rounded",
            text = {
                top = (" %s "):format(t("Question Info")),
            },
        },
        buf_options = {
            modifiable = false,
            readonly = false,
        },
    })

    self.hints = parent.q.hints
    self.question = parent
end

---@type fun(parent: lc.ui.Question): lc.ui.InfoPopup
local LeetInfoPopup = Info

return LeetInfoPopup
