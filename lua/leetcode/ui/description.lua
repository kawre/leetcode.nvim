local log = require("leetcode.logger")

local config = require("leetcode.config")
local parser = require("leetcode.parser")

local Layout = require("leetcode-ui.layout")
local Text = require("leetcode-ui.component.text")
local padding = require("leetcode-ui.component.padding")

local NuiText = require("nui.text")
local NuiLine = require("nui.line")
local Split = require("nui.split")

---@class lc.Description
---@field split NuiSplit
---@field parent lc.Question
---@field content any
---@field title any
---@field layout lc-ui.Layout
local description = {}
description.__index = description

function description:autocmds()
    local group_id = vim.api.nvim_create_augroup("leetcode_description", { clear = true })

    vim.api.nvim_create_autocmd("WinResized", {
        group = group_id,
        buffer = self.split.bufnr,
        callback = function() self:draw() end,
    })
end

function description:mount()
    self:autocmds()

    self:populate()
    self.split:mount()
    self:draw()

    return self
end

function description:draw()
    local c = vim.api.nvim_win_get_cursor(self.split.winid)
    self.layout:draw(self.split)
    vim.api.nvim_win_set_cursor(self.split.winid, c)
end

-- function description:redraw()
--     local c = vim.api.nvim_win_get_cursor(self.split.winid)
--     self.layout:draw()
--     vim.api.nvim_win_set_cursor(self.split.winid, c)
-- end

---@private
function description:populate()
    local q = self.parent.q

    local linkline = NuiLine()
    linkline:append("https://leetcode.com/problems/" .. q.title_slug .. "/", "Comment")

    local titleline = NuiLine()
    titleline:append(" " .. q.frontend_id .. ". " .. q.title .. " ", "")

    local statsline = NuiLine()
    statsline:append(
        q.difficulty,
        ({
            ["Easy"] = "LeetCodeEasy",
            ["Medium"] = "LeetCodeMedium",
            ["Hard"] = "LeetCodeHard",
        })[q.difficulty]
    )
    statsline:append(" | ")

    statsline:append(q.likes .. "  ", "Comment")
    statsline:append(q.dislikes .. " ", "Comment")
    statsline:append(" | ")

    statsline:append(string.format("%s of %s", q.stats.acRate, q.stats.totalSubmission), "Comment")

    local titlecomp = Text:init({
        lines = { titleline },
        opts = { position = "center" },
    })
    local statscomp = Text:init({
        lines = { statsline },
        opts = { position = "center" },
    })
    local linkcomp = Text:init({
        lines = { linkline },
        opts = { position = "center" },
    })

    local contents = parser:init(q.content, "html"):parse()

    self.layout = Layout:init({
        components = {
            linkcomp,
            padding:init(1),
            titlecomp,
            statscomp,
            padding:init(3),
            contents,
            padding:init(1),
        },
        opts = { margin = 5 },
    })
end

---@param parent lc.Question
function description:init(parent)
    local split = Split({
        relative = "editor",
        position = "left",
        size = config.user.description.width,
        buf_options = {
            modifiable = true,
            readonly = false,
            filetype = "leetcode.nvim",
            swapfile = false,
            buftype = "nofile",
            buflisted = true,
        },
        win_options = {
            foldcolumn = "1",
            wrap = true,
            number = false,
            signcolumn = "no",
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
        },
        enter = true,
        focusable = true,
    })

    local obj = setmetatable({
        split = split,
        parent = parent,
        layout = {},
    }, self)

    vim.api.nvim_buf_set_name(obj.split.bufnr, "Description")

    return obj:mount()
end

return description
