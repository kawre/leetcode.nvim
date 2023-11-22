local Header = require("leetcode-menu.components.header")
local Title = require("leetcode-menu.components.title")
local Button = require("leetcode-ui.lines.button")
local Footer = require("leetcode-menu.components.footer")
local Buttons = require("leetcode-menu.components.buttons")
local Page = require("leetcode-menu.page")

local cmd = require("leetcode.command")

local page = Page()

page:insert(Header())

page:insert(Title({ "Menu" }, "Cache"))

local update_btn = Button({ icon = "󱘴", src = "Update" }, "u", function() cmd.cache_update() end)
local back_btn = Button({ icon = "", src = "Back" }, "q", function() cmd.menu_layout("menu") end)
page:insert(Buttons({
    update_btn,
    back_btn,
}))

page:insert(Footer())

return page
