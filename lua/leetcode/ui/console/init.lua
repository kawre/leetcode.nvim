local config = require("leetcode.config")
local Testcase = require("leetcode.ui.console.testcase")
local Result = require("leetcode.ui.console.result")
local Runner = require("leetcode.runner")
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
    if self.opened then return end

    if not self.layout._.mounted then
        self.layout:mount()
    else
        self.layout:show()
    end

    self.opened = true
end

function console:hide()
    if not self.opened then return end

    self.layout:hide()
    self.opened = false
end

---@param parent lc.Question
function console:init(parent)
    self = setmetatable({
        parent = parent,
        opened = false,
    }, self)

    local keymap = {
        ["R"] = function() self:run() end,
        ["S"] = function() self:submit() end,
        ["r"] = function() self.testcase:reset() end,
        [{ "q", "<Esc>" }] = function() self:hide() end,
    }

    self.testcase = Testcase:init(self):keymaps(keymap) ---@diagnostic disable-line
    self.result = Result:init(self):keymaps(keymap) ---@diagnostic disable-line

    self.layout = NuiLayout(
        {
            relative = "editor",
            position = "50%",
            size = config.user.console.size,
        },
        NuiLayout.Box({
            NuiLayout.Box(self.testcase.popup, { size = config.user.console.testcase.size }),
            NuiLayout.Box(self.result.popup, { size = config.user.console.result.size }),
        }, { dir = config.user.console.dir })
    )

    return self
end

return console
