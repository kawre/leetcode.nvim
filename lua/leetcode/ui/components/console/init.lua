local Popup = require("nui.popup")
local Layout = require("leetcode-ui.layout")
local config = require("leetcode.config")
local Testcase = require("leetcode.ui.components.console.testcase")
local Text = require("leetcode-ui.component.text")
local Result = require("leetcode.ui.components.console.result")
local Runner = require("leetcode.runner")

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
    self.opened = true

    return self
end

function console:run()
    self.result:clear()
    local runner = Runner:init(self.parent)
    local res = runner:run()
    -- fasdf//
end

function console:submit()
    -- asdf
end

function console:keymaps()
    local keymaps = {
        ["R"] = function() self:run() end,
        ["S"] = function() self:submit() end,
        [{ "q", "<Esc>" }] = function() self:hide() end,
    }

    for _, p in ipairs({ self.result, self.testcase }) do
        for key, fn in pairs(keymaps) do
            p.popup:map("n", key, fn)
        end
    end
end

function console:toggle()
    if self.opened then
        self:hide()
    else
        self:show()
    end
end

function console:show()
    self.opened = true
    self.layout:show()
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

    obj:keymaps()

    return obj
end

return console
