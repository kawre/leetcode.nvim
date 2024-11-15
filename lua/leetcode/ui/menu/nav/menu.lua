local markup = require("markup")
local Header = require("leetcode.ui.menu.header")
local Buttons = require("leetcode.ui.menu.buttons")

return function()
    return markup.Flex({
        Buttons(),
    })
end
