local Split = require("nui.split")
local log = require("leetcode.logger")
local parser = require("leetcode.parser")
local gql = require("leetcode.graphql")
local layout = require("leetcode-ui.layout")
local Text = require("leetcode-ui.component.text")
local padding = require("leetcode-ui.component.padding")
local NuiText = require("nui.text")
local NuiLine = require("nui.line")

---@class lc.Description
---@field split NuiSplit
---@field parent lc.Problem.second
---@field content any
---@field title any
---@field layout lc-ui.Layout
local description = {}
description.__index = description

-- descriptions = {}

function description:mount()
    self:populate()
    self.split:mount()
    self:draw()
end

function description:draw() self.layout:draw(self.split) end

---@private
function description:populate()
    local title = gql.question.title(self.parent.problem.title_slug)
    local content = gql.question.content(self.parent.problem.title_slug).content

    local linkline = NuiLine()
    linkline:append("https://leetcode.com/problems/" .. title.titleSlug .. "/", "Comment")

    local titleline = NuiLine()
    titleline:append(title.questionFrontendId .. ". " .. title.title, "MiniStatuslineModeInsert")

    local titlecomp = Text:init({
        lines = { titleline },
        opts = { position = "center" },
    })
    local linkcomp = Text:init({
        lines = { linkline },
        opts = { position = "center" },
    })

    local contents = parser:init(content, "html"):parse()

    self.layout = layout:init({
        contents = {
            titlecomp,
            padding:init(2),
            contents,
            padding:init(1),
            linkcomp,
        },
        opts = { margin = 5 },
    })
end

---@param parent lc.Problem.second
function description:init(parent)
    local split = Split({
        relative = "win",
        position = "left",
        size = "50%",
        buf_options = {
            modifiable = true,
            readonly = false,
            filetype = "leetcode.nvim",
            swapfile = false,
            buftype = "nofile",
            buflisted = false,
        },
        win_options = {
            foldcolumn = "1",
            wrap = true,
            number = false,
            signcolumn = "no",
        },
        enter = true,
        focusable = true,
    })

    local obj = setmetatable({
        split = split,
        parent = parent,
        layout = {},
        -- content = content,
        -- title = title,
    }, self)

    return obj
end

return description
