local text = require("leetcode-ui.component.text")
local group = require("leetcode-ui.component.group")

---@alias section table<string, lc-ui.Component>

---@class template
---@field section section
local template = {}

---@return section
function template.get()
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

    return {
        header = header,
        notifications = notifications,
        title = title,
        footer = footer,
    }
end

return template
