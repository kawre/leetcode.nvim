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
local console = {}
console.__index = console

function console:mount()
    -- self.popup:mount()
    -- fsadf/
    -- self.testcase.layout:draw(self.popup)
    -- self.layout:append(self.testcase)
    self.layout:mount()

    return self
end

function console:open()
    -- fasdf/
end

function console:hide()
    -- fasdf/
end

---@private
function console.navbar()
    local testcase_text = NuiText(" (t) testcase ", "MasonHeader")
    local result_text = NuiText(" (r) result ", "MasonHeader")
    local run_text = NuiText(" (R) run ", "MasonHeader")
    local submit_text = NuiText(" (S) submit ", "MasonHeader")

    local nui_line = NuiLine({
        -- testcase_text,
        -- NuiText("\t"),
        -- result_text,
        -- NuiText("\t"),
    })

    return Text:init({
        lines = { nui_line },
        opts = { position = "center" },
    })
end

---@param parent lc.Question
function console:init(parent)
    local obj = setmetatable({
        parent = parent,
    }, self)

    obj.layout = NuiLayout(
        {
            relative = "editor",
            position = "50%",
            size = config.user.console.size,
        },
        NuiLayout.Box({
            NuiLayout.Box(Testcase:init(obj).popup, { size = "50%" }),
            NuiLayout.Box(Result:init(obj).popup, { size = "50%" }),
        }, { dir = config.user.console.dir })
    )

    return obj
end

return console
