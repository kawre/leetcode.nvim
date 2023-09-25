-- local log = require("leetcode.logger")
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
        self:set_noti(nil, {
            icon = stype.frames[self.index + 1],
        })

        self.index = (self.index + 1) % #stype.frames

        -- 1 % 3
        -- 2 % 3
        -- 3 % 3

        local fps = 1000 / #stype.frames
        vim.defer_fn(function() self:spin() end, fps)
    end
end

---@private
function spinner:set_noti(lvl, opts)
    opts = vim.tbl_deep_extend("force", {
        hide_from_history = true,
        replace = self.noti,
        title = config.name,
        timeout = false,
    }, opts)

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

function spinner:stop() self.spinner = nil end

---@param msg? string
function spinner:done(msg)
    if msg then self:update(msg) end

    self:stop()
    self:set_noti(nil, { icon = "", timeout = 500 })
end

---@param msg string
function spinner:failed(msg)
    self:update(msg)
    self:set_noti("error", { icon = "󰅘", timeout = 2000 })
    self:stop()
end

---@param msg string | nil
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
