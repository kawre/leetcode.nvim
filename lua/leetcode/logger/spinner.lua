local log = require("leetcode.logger")

local config = require("leetcode.config")

---@class lc.Logger.Spinner
---@field spinner spinner | nil
---@field index integer
---@field noti any
---@field msg string
local spinner = {}
spinner.__index = spinner

---@class spinner
---@field frames string[]
---@field fps integer

---@alias spinner_type
---| "dot"
---| "points"

---@type spinner[]
local spinners = {
    dot = {
        frames = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" },
        -- frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
        -- frames = { "☱", "☲", "☴", "☲" },
        fps = 15,
    },
    points = {
        frames = { "∙∙∙", "●∙∙", "∙●∙", "∙∙●" },
        fps = 7,
    },
}

---@private
function spinner:spin()
    local stype = self.spinner

    if stype then
        self:set(nil, nil, {
            icon = stype.frames[self.index + 1],
        })

        self.index = (self.index + 1) % #stype.frames

        local fps = 1000 / #stype.frames
        vim.defer_fn(function() self:spin() end, fps)
    end
end

---@private
---
---@param msg? string
---@param lvl? integer
---@param opts? table
function spinner:set(msg, lvl, opts)
    if msg then self:update(msg) end
    lvl = lvl or vim.log.levels.INFO
    opts = vim.tbl_deep_extend("force", {
        hide_from_history = true,
        replace = self.noti,
        title = config.name,
        timeout = false,
    }, opts or {})

    self.noti = vim.notify(self.msg, lvl, opts)
end

---@param spinner_type spinner_type
function spinner:change(spinner_type) self.spinner = spinners[spinner_type] end

---@param msg msg
function spinner:update(msg) self.msg = tostring(msg) end

function spinner:start()
    self:spin()
    return self
end

---@param msg? string
---@param success? boolean
---@param opts? table
function spinner:stop(msg, success, opts)
    success = success or true
    opts = vim.tbl_deep_extend("force", {
        icon = success and "" or "󰅘",
        timeout = 2000,
    }, opts or {})

    self.spinner = nil
    self:set(msg, success and vim.log.levels.INFO or vim.log.levels.ERROR, opts)
end

---@param msg? string
---@param spinner_type? spinner_type
function spinner:init(msg, spinner_type)
    local obj = setmetatable({
        msg = msg or "",
        index = 0,
        spinner = spinners[spinner_type or "dot"],
        noti = {},
    }, self)

    return obj:start()
end

return spinner
