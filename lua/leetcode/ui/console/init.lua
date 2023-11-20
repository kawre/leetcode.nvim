local config = require("leetcode.config")
local Testcase = require("leetcode.ui.console.testcase")
local Result = require("leetcode.ui.console.result")
local Runner = require("leetcode.runner")
local log = require("leetcode.logger")
local NuiLayout = require("nui.layout")

---@class lc.Console
---@field parent lc.Question
---@field layout NuiLayout
---@field testcase lc.Testcase
---@field result lc.Result
---@field opened boolean
local console = {}
console.__index = console

function console:unmount()
    self.layout:unmount()
    self = nil
end

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
    elseif not self.opened then
        self.layout:show()
    end

    self.opened = true
end

function console:handle_buf_leave()
    log.info(self.result.popup.winid)
    log.info(self.testcase.popup.winid)
    log.info("-")

    local winid = vim.api.nvim_get_current_win()
    --
    log.info(winid)
end

function console:hide()
    if not self.opened then return end

    self.layout:hide()
    self.opened = false
end

function console:use_testcase()
    local last_testcase = self.result.last_testcase
    if last_testcase then
        self.testcase:append(last_testcase)
    else
        log.warn("No testcase to use")
    end
end

---@param parent lc.Question
function console:init(parent)
    self = setmetatable({
        parent = parent,
        opened = false,
    }, self)

    self.testcase = Testcase:init(self)
    self.result = Result:init(self)

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

    local popups = { self.testcase.popup, self.result.popup } ---@type NuiPopup[]

    local keymaps = {
        ["R"] = function() self:run() end,
        ["S"] = function() self:submit() end,
        ["r"] = function() self.testcase:reset() end,
        [{ "q", "<Esc>" }] = function() self:hide() end,
        ["H"] = function() self.testcase:focus() end,
        ["L"] = function() self.result:focus() end,
        ["U"] = function() self:use_testcase() end,
    }

    -- apply keymaps to all popups
    for key, fn in pairs(keymaps) do
        for _, popup in pairs(popups) do
            popup:map("n", key, fn, { nowait = true })
        end
    end

    -- hide layout on layout leave
    for _, popup in pairs(popups) do
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

    return self
end

return console
