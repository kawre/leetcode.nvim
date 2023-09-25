local Text = require("leetcode-ui.component.text")

---@class lc-menu.Header
---@field text lc-ui.Text
local header = {}
header.__index = header

function header:content() return self.text end

---@param lines? any
---@param opts? any
function header:init(lines, opts)
    opts = vim.tbl_deep_extend("force", {
        position = "center",
        hl = "Keyword",
        padding = {
            bot = 2,
        },
    }, opts or {})

    local text = Text:init({
        lines = lines
            or {
                [[ /$$                          /$$     /$$$$$$                /$$         ]],
                [[| $$                         | $$    /$$__  $$              | $$         ]],
                [[| $$       /$$$$$$  /$$$$$$ /$$$$$$ | $$  \__/ /$$$$$$  /$$$$$$$ /$$$$$$ ]],
                [[| $$      /$$__  $$/$$__  $|_  $$_/ | $$      /$$__  $$/$$__  $$/$$__  $$]],
                [[| $$     | $$$$$$$| $$$$$$$$ | $$   | $$     | $$  \ $| $$  | $| $$$$$$$$]],
                [[| $$     | $$_____| $$_____/ | $$ /$| $$    $| $$  | $| $$  | $| $$_____/]],
                [[| $$$$$$$|  $$$$$$|  $$$$$$$ |  $$$$|  $$$$$$|  $$$$$$|  $$$$$$|  $$$$$$$]],
                [[|________/\_______/\_______/  \___/  \______/ \______/ \_______/\_______/]],
            },
        opts = opts,
    })

    local obj = setmetatable({
        text = text,
    }, self)

    return obj
end

return header
