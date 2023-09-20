local text = require("leetcode-ui.component.text")
local group = require("leetcode-ui.component.group")

local header = text:init({
    lines = {
        [[ /$$                          /$$     /$$$$$$                /$$         ]],
        [[| $$                         | $$    /$$__  $$              | $$         ]],
        [[| $$       /$$$$$$  /$$$$$$ /$$$$$$ | $$  \__/ /$$$$$$  /$$$$$$$ /$$$$$$ ]],
        [[| $$      /$$__  $$/$$__  $|_  $$_/ | $$      /$$__  $$/$$__  $$/$$__  $$]],
        [[| $$     | $$$$$$$| $$$$$$$$ | $$   | $$     | $$  \ $| $$  | $| $$$$$$$$]],
        [[| $$     | $$_____| $$_____/ | $$ /$| $$    $| $$  | $| $$  | $| $$_____/]],
        [[| $$$$$$$|  $$$$$$|  $$$$$$$ |  $$$$|  $$$$$$|  $$$$$$|  $$$$$$|  $$$$$$$]],
        [[|________/\_______/\_______/  \___/  \______/ \______/ \_______/\_______/]],
    },
    opts = {
        position = "center",
        hl = "Keyword",
        padding = {
            bot = 2,
        },
    },
})

local notifications = text:init({
    opts = {
        position = "center",
        hl = "DiagnosticInfo",
    },
})

local title = text:init({
    opts = {
        position = "center",
        hl = "Comment",
    },
})

local footer = text:init({
    opts = {
        position = "center",
        hl = "Keyword",
    },
})

---@alias section table<string, lc.db.Component>

---@type section
local section = {
    header = header,
    notifications = notifications,
    title = title,
    footer = footer,
}

---@class lc.db.Template
---@field section section
---@field button function
return {
    section = section,
    button = require("alpha.themes.dashboard").button,
}
