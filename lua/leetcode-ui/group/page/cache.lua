local Header = require("leetcode-ui.lines.menu-header")
local Title = require("leetcode-ui.lines.title")
local Button = require("leetcode-ui.lines.button")
local Footer = require("leetcode-ui.lines.footer")
local Buttons = require("leetcode-ui.group.buttons")
local Page = require("leetcode-ui.group.page")

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
