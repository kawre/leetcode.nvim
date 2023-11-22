local Lines = require("leetcode-ui.lines")

---@class lc-menu.Header : lc-ui.Lines
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

    for _, line in ipairs(ascii) do
        self:append(line):endl()
    end
end

---@type fun(): lc-menu.Header
local LeetMenuHeader = Header

return LeetMenuHeader
