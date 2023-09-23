local Popup = require("nui.popup")
local Layout = require("leetcode-ui.layout")
local config = require("leetcode.config")
local Testcase = require("leetcode.ui.components.console.testcase")
local Text = require("leetcode-ui.component.text")
local Result = require("leetcode.ui.components.console.result")

local NuiLine = require("nui.line")
local NuiText = require("nui.text")
local NuiLayout = require("nui.layout")

---@class lc.Console
---@field parent lc.Question
---@field layout NuiLayout
---@field testcase lc.Testcase
---@field result lc.Result
local console = {}
console.__index = console

function console:mount()
    self.layout:mount()

    return self
end

function console:open()
    self.layout:show()
    -- fasdf/
end

function console:hide()
    -- fasdf/
    self.layout:hide()
end

---@param parent lc.Question
function console:init(parent)
    local obj = setmetatable({
        parent = parent,
    }, self)

    obj.testcase = Testcase:init(obj)
    obj.result = Result:init(obj)
    obj.layout = NuiLayout(
        {
            relative = "editor",
            position = "50%",
            size = config.user.console.size,
            win_config = {
                zindex = 250,
            },
        },
        NuiLayout.Box({
            NuiLayout.Box(obj.testcase.popup, { size = "50%" }),
            NuiLayout.Box(obj.result.popup, { size = "50%" }),
        }, { dir = config.user.console.dir })
    )

    return obj
end

return console
