local Lines = require("leetcode-ui.component.text")

---@class lc-menu.Header : lc-ui.Text
local Header = Lines:extend("LeetMenuHeader")

local ascii = {
    [[ /$$                          /$$     /$$$$$$                /$$         ]],
    [[| $$                         | $$    /$$__  $$              | $$         ]],
    [[| $$       /$$$$$$  /$$$$$$ /$$$$$$ | $$  \__/ /$$$$$$  /$$$$$$$ /$$$$$$ ]],
    [[| $$      /$$__  $$/$$__  $|_  $$_/ | $$      /$$__  $$/$$__  $$/$$__  $$]],
    [[| $$     | $$$$$$$| $$$$$$$$ | $$   | $$     | $$  \ $| $$  | $| $$$$$$$$]],
    [[| $$     | $$_____| $$_____/ | $$ /$| $$    $| $$  | $| $$  | $| $$_____/]],
    [[| $$$$$$$|  $$$$$$|  $$$$$$$ |  $$$$|  $$$$$$|  $$$$$$|  $$$$$$|  $$$$$$$]],
    [[|________/\_______/\_______/  \___/  \______/ \______/ \_______/\_______/]],
}

function Header:init()
    Header.super.init(self, {
        position = "center",
        hl = "Keyword",
        padding = {
            top = 4,
            bot = 2,
        },
    })

    self:from(ascii)
end

---@type fun(): lc-menu.Header
local LeetMenuHeader = Header

return LeetMenuHeader
