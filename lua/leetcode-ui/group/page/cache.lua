local cmd = require("leetcode.command")

local Title = require("leetcode-ui.lines.title")
local Buttons = require("leetcode-ui.group.buttons.menu")
local Page = require("leetcode-ui.group.page")
local Button = require("leetcode-ui.lines.button.menu")
local BackButton = require("leetcode-ui.lines.button.menu.back")

local header = require("leetcode-ui.lines.menu-header")
local footer = require("leetcode-ui.lines.footer")

local page = Page()

page:insert(header)

page:insert(Title({ "Menu" }, "Cache"))

local update_btn = Button("Update", {
    icon = "󱘴",
    sc = "u",
    on_press = function()
        cmd.cache_update()
    end,
})

local back_btn = BackButton("menu")

page:insert(Buttons({
    update_btn,
    back_btn,
}))

page:insert(footer)

return page
