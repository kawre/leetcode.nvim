local Header = require("leetcode-ui.lines.menu-header")
local Title = require("leetcode-ui.lines.title")
local Footer = require("leetcode-ui.lines.footer")
local Buttons = require("leetcode-ui.group.buttons.menu")
local Page = require("leetcode-ui.group.page")
local stats = require("leetcode-ui.lines.stats")

local Button = require("leetcode-ui.lines.button.menu")
local BackButton = require("leetcode-ui.lines.button.menu.back")

local cmd = require("leetcode.command")

local page = Page()

page:insert(Header())

page:insert(Title({ "Menu" }, "Cache"))

local update_btn = Button("Update", {
    icon = "󱘴",
    sc = "u",
    on_press = function() cmd.cache_update() end,
})

local back_btn = BackButton("menu")

page:insert(Buttons({
    update_btn,
    back_btn,
}))

page:insert(Footer())

page:insert(stats)

return page
