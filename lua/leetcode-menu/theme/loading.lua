local Layout = require("leetcode-ui.layout")
local Text = require("leetcode-ui.component.text")
local NuiText = require("nui.text")

local Header = require("leetcode-menu.components.header")
local Buttons = require("leetcode-menu.components.buttons")
local button = require("leetcode-ui.component.button")

local problems = button:init({ icon = "", src = "Fetching user info" }, "...", function() end)

return Layout:init({
    components = {
        Header:init(),

        Buttons:init({
            components = {
                problems,
            },
        }),
    },
})
