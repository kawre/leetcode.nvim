local Text = require("leetcode-ui.component.text")

---@class lc-menu.Header : lc-ui.Text
local header = {}
header.__index = header
setmetatable(header, Text)

local header_ascii = {
    [[ /$$                          /$$     /$$$$$$                /$$         ]],
    [[| $$                         | $$    /$$__  $$              | $$         ]],
    [[| $$       /$$$$$$  /$$$$$$ /$$$$$$ | $$  \__/ /$$$$$$  /$$$$$$$ /$$$$$$ ]],
    [[| $$      /$$__  $$/$$__  $|_  $$_/ | $$      /$$__  $$/$$__  $$/$$__  $$]],
    [[| $$     | $$$$$$$| $$$$$$$$ | $$   | $$     | $$  \ $| $$  | $| $$$$$$$$]],
    [[| $$     | $$_____| $$_____/ | $$ /$| $$    $| $$  | $| $$  | $| $$_____/]],
    [[| $$$$$$$|  $$$$$$|  $$$$$$$ |  $$$$|  $$$$$$|  $$$$$$|  $$$$$$|  $$$$$$$]],
    [[|________/\_______/\_______/  \___/  \______/ \______/ \_______/\_______/]],
}

---@param lines? any
---@param opts? any
function header:init(lines, opts)
    opts = vim.tbl_deep_extend("force", {
        position = "center",
        hl = "Keyword",
        padding = {
            top = 4,
            bot = 2,
        },
    }, opts or {})

    local text = Text:init(lines or header_ascii, opts)
    return setmetatable(text, self)
end

return header
