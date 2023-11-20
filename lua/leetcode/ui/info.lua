local Popup = require("leetcode.ui.popup")
local NuiText = require("nui.text")
local NuiLine = require("nui.line")
local config = require("leetcode.config")
local utils = require("leetcode.utils")

local t = require("leetcode.translator")
local log = require("leetcode.logger")

---@class lc.ui.InfoPopup : lc.ui.Popup
---@field popup NuiPopup
---@field parent lc.Question
---@field hints table[]
local InfoPopup = Popup:extend("LeetInfoPopup")

function InfoPopup:unmount()
    InfoPopup.super.unmount(self)
    self = nil
end

function InfoPopup:toggle()
    --
    InfoPopup.super.toggle(self)
end

function InfoPopup:mount()
    local NuiTree = require("nui.tree")
    local nodes = {}

    local hints = {}
    for i, hint_txt in ipairs(self.hints) do
        local line = NuiLine()

        line:append(tostring(i), "leetcode_list")
        line:append("/" .. #self.hints, "leetcode_alt")

        local hint = NuiTree.Node({ text = line }, { NuiTree.Node({ text = hint_txt }) })
        table.insert(hints, hint)
    end

    if not vim.tbl_isempty(hints) then
        table.insert(
            nodes,
            NuiTree.Node({ text = NuiText(t("Hints") .. " 󰛨", "leetcode_hint") }, hints)
        )
    else
        table.insert(
            nodes,
            NuiTree.Node({ text = NuiText(" " .. t("No hints available"), "leetcode_error") })
        )
    end
    table.insert(nodes, NuiTree.Node({ text = "" }))

    local topics = {}
    for _, topic in ipairs(self.parent.q.topic_tags) do
        local line = NuiLine()

        line:append("* ", "leetcode_list")
        line:append(topic.name)

        table.insert(topics, NuiTree.Node({ text = line }))
    end

    if not vim.tbl_isempty(topics) then
        table.insert(
            nodes,
            NuiTree.Node({ text = NuiText(t("Topics") .. " ", "Number") }, topics)
        )
    else
        table.insert(
            nodes,
            NuiTree.Node({ text = NuiText(" " .. t("No topics available"), "leetcode_error") })
        )
    end
    table.insert(nodes, NuiTree.Node({ text = " " }))

    local sim_questions = {}
    for _, q in ipairs(self.parent.q.similar) do
        local line = NuiLine()

        local hl = {
            ["Easy"] = "leetcode_easy",
            ["Medium"] = "leetcode_medium",
            ["Hard"] = "leetcode_hard",
        }
        line:append("󱓻 ", hl[q.difficulty])
        line:append(utils.translate(q.title, q.translated_title))

        local lock = not config.auth.is_premium and q.paid_only and "  " .. t("Premium") or ""
        line:append(lock, "leetcode_medium")

        table.insert(sim_questions, NuiTree.Node({ text = line, question = q }))
    end
    if not vim.tbl_isempty(sim_questions) then
        table.insert(
            nodes,
            NuiTree.Node(
                { text = NuiText(t("Similar Questions") .. " ", "leetcode_ref") },
                sim_questions
            )
        )
    else
        table.insert(
            nodes,
            NuiTree.Node({
                text = NuiText(" " .. t("No similar questions available"), "leetcode_error"),
            })
        )
    end

    local tree = NuiTree({
        bufnr = self.bufnr,
        nodes = nodes,
        prepare_node = function(node)
            local line = NuiLine()
            line:append(string.rep("  ", node:get_depth() - 1))

            if node:has_children() then
                line:append(node:is_expanded() and " " or " ", "leetcode_list")
                line:append(node.text)
            else
                if type(node.text) == "string" then
                    line:append("  ")
                    local parser = require("leetcode.parser")
                    local txt = parser:parse(node.text)
                    if txt.lines[1] then line:append(txt.lines[1]) end
                else
                    line:append(node.text)
                end
            end

            return line
        end,
    })

    local opts = { noremap = true, nowait = true }

    self:map("n", { "<Tab>", "<CR>" }, function()
        local node = tree:get_node()
        if not node then return end

        if node.question then
            local problemlist = require("leetcode.cache.problemlist")
            local problem = problemlist.get_by_title_slug(node.question.title_slug)
            if problem then require("leetcode.ui.question"):init(problem) end
        end

        if not node:is_expanded() then
            node:expand()
        else
            node:collapse()
        end

        tree:render()
    end, opts)

    InfoPopup.super.mount(self)
    local utils = require("leetcode-menu.utils")
    local winhighlight = "Normal:NormalSB,FloatBorder:FloatBorder"
    utils.set_win_opts(self.winid, {
        winhighlight = winhighlight,
        wrap = true,
    })
    utils.set_win_opts(self.border.winid, {
        winhighlight = winhighlight,
    })
    tree:render()

    return self
end

---@param parent lc.Question
function InfoPopup:init(parent)
    InfoPopup.super.init(self, {
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
    self.parent = parent
end

---@type fun(parent: lc.Question): lc.ui.InfoPopup
local LeetInfoPopup = InfoPopup

return LeetInfoPopup
