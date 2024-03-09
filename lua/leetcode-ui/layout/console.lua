local Testcase = require("leetcode-ui.popup.console.testcase")
local Result = require("leetcode-ui.popup.console.result")
local NuiLayout = require("nui.layout")
local Layout = require("leetcode-ui.layout")
local Popup = require("leetcode-ui.popup")

local config = require("leetcode.config")
local keys = config.user.keys
local Runner = require("leetcode.runner")
local log = require("leetcode.logger")

---@class lc.ui.Console : lc.ui.Layout
---@field question lc.ui.Question
---@field testcase lc.ui.Console.TestcasePopup
---@field result lc.ui.Console.ResultPopup
---@field popups lc.ui.Console.Popup[]
local ConsoleLayout = Layout:extend("LeetConsoleLayout")

function ConsoleLayout:unmount() --
    ConsoleLayout.super.unmount(self)

    self.testcase = Testcase(self)
    self.result = Result(self)
    self.popups = { self.testcase, self.result }
end

function ConsoleLayout:hide()
    ConsoleLayout.super.hide(self)

    pcall(function()
        local winid = vim.api.nvim_get_current_win()
        if winid == self.question.description.winid then
            vim.api.nvim_set_current_win(self.question.winid)
        end
    end)
end

function ConsoleLayout:mount()
    self:update(NuiLayout.Box({
        NuiLayout.Box(self.testcase, { size = config.user.console.testcase.size }),
        NuiLayout.Box(self.result, { size = config.user.console.result.size }),
    }, { dir = config.user.console.dir }))

    ConsoleLayout.super.mount(self)

    self:set_keymaps({
        [keys.reset_testcases] = function()
            self.testcase:reset()
        end,
        [keys.use_testcase] = function()
            self:use_testcase()
        end,
        [keys.focus_testcases] = function()
            self.testcase:focus()
        end,
        [keys.focus_result] = function()
            self.result:focus()
        end,
    })
end

function ConsoleLayout:run(submit)
    if config.user.console.open_on_runcode then
        self:show()
    end

    self.result:focus()

    Runner:init(self.question):run(submit)
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

---@param parent lc.ui.Question
function ConsoleLayout:init(parent)
    self.question = parent
    self.testcase = Testcase(self)
    self.result = Result(self)
    self.popups = { self.testcase, self.result }

    ConsoleLayout.super.init(
        self,
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
end

---@type fun(parent: lc.ui.Question): lc.ui.Console
local LeetConsoleLayout = ConsoleLayout

return LeetConsoleLayout
