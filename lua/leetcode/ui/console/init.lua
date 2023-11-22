local config = require("leetcode.config")
local Testcase = require("leetcode.ui.console.testcase")
local Result = require("leetcode.ui.console.result")
local Runner = require("leetcode.runner")
local log = require("leetcode.logger")
local NuiLayout = require("nui.layout")
local Popup = require("leetcode.ui.popup")

---@class lc.ui.ConsoleLayout : NuiLayout
---@field parent lc.ui.Question
---@field layout NuiLayout
---@field testcase lc.ui.Console.TestcasePopup
---@field result lc.ui.Console.ResultPopup
local ConsoleLayout = NuiLayout:extend("LeetConsoleLayout")

function ConsoleLayout:unmount()
    ConsoleLayout.super.unmount(self)
    self = nil
end

function ConsoleLayout:run()
    self.result:clear()
    Runner:init(self.parent):run()
end

function ConsoleLayout:submit()
    self.result:clear()
    Runner:init(self.parent):run(true)
end

function ConsoleLayout:show()
    if not self._.mounted then
        self:mount()
    elseif not self.visible then
        ConsoleLayout.super.show(self)
    end

    self.visible = true
end

function ConsoleLayout:hide()
    if not self.visible then return end
    ConsoleLayout.super.hide(self)
    self.visible = false

    pcall(function()
        local winid = vim.api.nvim_get_current_win()
        if winid == self.parent.description.winid then
            vim.api.nvim_set_current_win(self.parent.winid)
        end
    end)
end

function ConsoleLayout:toggle()
    if self.visible then
        self:hide()
    else
        self:show()
    end
end

function ConsoleLayout:use_testcase()
    local last_testcase = self.result.last_testcase
    if last_testcase and last_testcase ~= "" then
        self.testcase:append(last_testcase)
    else
        log.warn("No testcase to use")
    end
end

---@param parent lc.ui.Question
function ConsoleLayout:init(parent)
    ConsoleLayout.super.init(self, {
        relative = "editor",
        position = "50%",
        size = config.user.console.size,
    }, NuiLayout.Box(
        { NuiLayout.Box(Popup(), { size = 0 }) },
        { dir = config.user.console.dir }
    ))

    self.visible = false
    self.parent = parent

    self.testcase = Testcase(self)
    self.result = Result(self)

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

    local keymaps = {
        ["R"] = function() self:run() end,
        ["S"] = function() self:submit() end,
        ["r"] = function() self.testcase:reset() end,
        [{ "q", "<Esc>" }] = function() self:hide() end,
        ["H"] = function() self.testcase:focus() end,
        ["L"] = function() self.result:focus() end,
        ["U"] = function() self:use_testcase() end,
    }

    local popups = { self.testcase, self.result }
    for _, popup in pairs(popups) do
        popup:set_keymaps(keymaps)

        popup:on(
            "BufLeave",
            vim.schedule_wrap(function()
                local curr_bufnr = vim.api.nvim_get_current_buf()
                for _, p in pairs(popups) do
                    if p.bufnr == curr_bufnr then return end
                end
                self:hide()
            end)
        )
    end
end

---@type fun(parent: lc.ui.Question): lc.ui.ConsoleLayout
local LeetConsoleLayout = ConsoleLayout

return LeetConsoleLayout
