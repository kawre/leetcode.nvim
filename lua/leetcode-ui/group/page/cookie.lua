local Header = require("leetcode-ui.lines.menu-header")
local Title = require("leetcode-ui.lines.title")
local Button = require("leetcode-ui.lines.button")
local Footer = require("leetcode-ui.lines.footer")
local Buttons = require("leetcode-ui.group.buttons")
local Page = require("leetcode-ui.group.page")

local cmd = require("leetcode.command")

local page = Page()

page:insert(Header())

page:insert(Title({ "Menu" }, "Cookie"))

local update_btn = Button({ icon = "󱛬", src = "Update" }, "u", cmd.cookie_prompt)
local delete_btn = Button({ icon = "󱛪", src = "Delete / Sign out" }, "d", cmd.sign_out)
local back_btn = Button({ icon = "", src = "Back" }, "q", function() cmd.menu_layout("menu") end)

page:insert(Buttons({
    update_btn,
    delete_btn,
    back_btn,
}))

page:insert(Footer())

return page
