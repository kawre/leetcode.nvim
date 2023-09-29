local Popup = require("nui.popup")
local Layout = require("leetcode-ui.layout")
local config = require("leetcode.config")
local Testcase = require("leetcode.ui.console.testcase")
local Text = require("leetcode-ui.component.text")
local Result = require("leetcode.ui.console.result")
local Runner = require("leetcode.runner")
local log = require("leetcode.logger")

local NuiLine = require("nui.line")
local NuiText = require("nui.text")
local NuiLayout = require("nui.layout")

---@class lc.Console
---@field parent lc.Question
---@field layout NuiLayout
---@field testcase lc.Testcase
---@field result lc.Result
---@field opened boolean
local console = {}
console.__index = console

function console:mount()
    self.layout:mount()
    return self
end

function console:run()
    self.result:clear()
    Runner:init(self.parent):run()
end

function console:submit()
    self.result:clear()
    Runner:init(self.parent):run(true)
end

function console:toggle()
    if self.opened then
        self:hide()
    else
        self:show()
    end
end

function console:show()
    if not self.layout._.mounted then
        self.layout:mount()
    else
        self.layout:show()
    end

    self.opened = true
end

function console:hide()
    self.opened = false
    self.layout:hide()
end

---@param parent lc.Question
function console:init(parent)
    local obj = setmetatable({
        parent = parent,
        opened = false,
    }, self)

    local keymap = {
        ["R"] = function() obj:run() end,
        ["S"] = function() obj:submit() end,
        [{ "q", "<Esc>" }] = function() obj:hide() end,
    }

    obj.testcase = Testcase:init(obj):keymaps(keymap)
    obj.result = Result:init(obj):keymaps(keymap)

    obj.layout = NuiLayout(
        {
            relative = "editor",
            position = "50%",
            size = config.user.console.size,
        },
        NuiLayout.Box({
            NuiLayout.Box(obj.testcase.popup, { size = "50%" }),
            NuiLayout.Box(obj.result.popup, { size = "50%" }),
        }, { dir = config.user.console.dir })
    )

    -- obj:keymaps()

    return obj
end

return console
