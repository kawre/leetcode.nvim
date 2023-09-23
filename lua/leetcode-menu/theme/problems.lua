local log = require("leetcode.logger")
local group = require("leetcode-ui.component.group")
local padding = require("leetcode-ui.component.padding")
local button = require("leetcode-ui.component.button")
local layout = require("leetcode-ui.layout")
local api = require("leetcode.api")

local template = require("leetcode-menu.theme.template")
local section = template.get()

section.title:append("Problems")

local list_btn = button:init({ src = "List", icon = "" }, "p", function() api.cmd.problems() end)

local random_btn = button:init(
    { src = "Random", icon = "" },
    "r",
    function() api.cmd.random_question() end
)

local qot_btn = button:init(
    { src = "Question of Today", icon = "󰃭" },
    "t",
    function() api.cmd.qot() end
)

local back_btn = button:init({ src = "Back", icon = "…" }, "q", function()
    local bufnr = vim.api.nvim_get_current_buf()
    db[bufnr]:set_layout("menu")
end)

local buttons = group:init({
    components = {
        list_btn,
        random_btn,
        qot_btn,
        back_btn,

        -- button:init("t", "Question of Today", " "),
        -- button:init("t", "Random", " "),
        -- button:init("r", "Recent", " "),
        -- button:init("q", "Back", "… "),
    },
    opts = { spacing = 1 },
})

section.footer:append("Signed in as: ")

return layout:init({
    contents = {
        -- header
        padding:init(2),
        section.header,
        padding:init(2),

        -- notifications
        section.notifications,

        -- title
        section.title,

        -- buttons
        buttons,

        --footer
        section.footer,
    },
    opts = {},
})
