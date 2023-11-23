local Testcase = require("leetcode-ui.popup.console.testcase")
local Result = require("leetcode-ui.popup.console.result")
local NuiLayout = require("nui.layout")
local Layout = require("leetcode-ui.layout")
local Popup = require("leetcode-ui.popup")

local config = require("leetcode.config")
local Runner = require("leetcode.runner")
local log = require("leetcode.logger")

---@class lc.ui.Console : NuiLayout
---@field parent lc-ui.Question
---@field testcase lc.ui.Console.TestcasePopup
---@field result lc.ui.Console.ResultPopup
---@field popups lc.ui.Console.Popup[]
local ConsoleLayout = Layout:extend("LeetConsoleLayout")

function ConsoleLayout:unmount() --
    ConsoleLayout.super.unmount(self)
    self.popups = {}
end

function ConsoleLayout:hide()
    ConsoleLayout.super.hide(self)

    pcall(function()
        local winid = vim.api.nvim_get_current_win()
        if winid == self.parent.description.winid then
            vim.api.nvim_set_current_win(self.parent.winid)
        end
    end)
end

function ConsoleLayout:mount()
    self.testcase = Testcase(self)
    self.result = Result(self)
    self.popups = { self.testcase, self.result }

    self:update(
        {
            relative = "editor",
            position = "50%",
            size = config.user.console.size,
        },
        NuiLayout.Box({
            NuiLayout.Box(self.testcase, { size = config.user.console.testcase.size }),
            NuiLayout.Box(self.result, { size = config.user.console.result.size }),
        }, { dir = config.user.console.dir })
    )

    ConsoleLayout.super.mount(self)

    self:set_keymaps({
        ["R"] = function() self:run() end,
        ["S"] = function() self:run(true) end,
        ["r"] = function() self.testcase:reset() end,
        ["H"] = function() self.testcase:focus() end,
        ["L"] = function() self.result:focus() end,
        ["U"] = function() self:use_testcase() end,
    })
end

function ConsoleLayout:run(submit)
    if config.user.console.open_on_runcode then self:show() end
    self.result:clear()
    Runner:init(self.parent):run(submit)
end

function ConsoleLayout:use_testcase()
    local last_testcase = self.result.last_testcase
    if last_testcase and last_testcase ~= "" then
        self.testcase:append(last_testcase)
    else
        log.warn("No testcase to use")
    end
end

function ConsoleLayout:set_keymaps(keymaps)
    for _, popup in pairs(self.popups) do
        for key, fn in pairs(keymaps) do
            popup:map("n", key, fn)
        end
    end
end

---@param parent lc-ui.Question
function ConsoleLayout:init(parent)
    self.parent = parent

    ConsoleLayout.super.init(self, {
        relative = "editor",
        position = "50%",
        size = config.user.console.size,
    }, NuiLayout.Box(
        { NuiLayout.Box(Popup(), { size = 0 }) },
        { dir = config.user.console.dir }
    ))
end

---@type fun(parent: lc-ui.Question): lc.ui.Console
local LeetConsoleLayout = ConsoleLayout

return LeetConsoleLayout
