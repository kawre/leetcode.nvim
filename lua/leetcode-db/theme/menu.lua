local log = require("leetcode.logger")
local layout = require("leetcode-ui.layout")
local template = require("leetcode-db.theme.template")
local padding = require("leetcode-ui.component.padding")
local button = require("leetcode-ui.component.button")
local group = require("leetcode-ui.component.group")

local section = template.get()

local problems = button:init({ icon = "", src = "Problems" }, "p", function()
    local bufnr = vim.api.nvim_get_current_buf()
    dashboards[bufnr]:set_layout("problems")
    -- "<cmd>lua require('leetcode.api').cmd.dashboard('problems')<CR>"
end, true)

local statistics = button:init({ icon = "󰄪", src = "Statistics" }, "s", function()
    -- "<cmd>lua require('leetcode.api').cmd.dashboard('stats')<cr>"
end, true)

local cookie = button:init({ src = "Cookie", icon = "󰆘" }, "c", function()
    -- "<cmd>lua require('leetcode.api').cmd.dashboard('cookie')<cr>"
    local bufnr = vim.api.nvim_get_current_buf()
    dashboards[bufnr]:set_layout("cookie")
end, true)

local cache = button:init({ src = "Cache", icon = "" }, "n", function()
    -- "<cmd>lua require('leetcode.api').cmd.dashboard('cache')<cr>"
end, true)

local exit = button:init({ src = "Exit", icon = "󰩈" }, "q", function() end)

local buttons = group:init({
    components = {
        problems,
        statistics,
        cookie,
        cache,
        exit,
    },
    opts = {
        spacing = 1,
    },
})

section.title:append("Menu", "Comment")

section.footer:append("Signed in as: " .. "kawre", "Keyword")

return layout:init({
    contents = {
        padding:init(2),
        section.header,
        padding:init(2),

        -- section.notifications,
        -- padding:init(2),

        section.title,

        padding:init(1),
        buttons,
        padding:init(1),

        section.footer,
    },
    opts = {
        margin = 5,
    },
})
