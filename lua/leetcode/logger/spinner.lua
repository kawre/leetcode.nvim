-- local log = require("leetcode.logger")
local config = require("leetcode.config")

---@class lc.Logger.Spinner
---@field spinner integer | nil
---@field noti any
---@field msg string
local spinner = {}
spinner.__index = spinner

local spinner_frames = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" }

---@private
function spinner:spin()
    if self.spinner then
        local new_spinner = (self.spinner + 1) % #spinner_frames
        self.spinner = new_spinner

        self:set_noti(nil, {
            hide_from_history = true,
            icon = spinner_frames[new_spinner],
            replace = self.noti,
            title = config.name,
        })

        vim.defer_fn(function() self:spin() end, 100)
    end
end

---@private
function spinner:set_noti(lvl, opts)
    opts = vim.tbl_deep_extend("force", {
        hide_from_history = true,
        replace = self.noti,
        title = config.name,
        timeout = 500,
    }, opts)

    self.noti = vim.notify(self.msg, lvl, opts)
end

---@param msg msg
function spinner:update(msg) self.msg = tostring(msg) end

function spinner:start()
    self:spin()
    return self
end

function spinner:done()
    self:stop()
    self:set_noti(nil, { icon = "" })
end

function spinner:stop() self.spinner = nil end

---@param msg string | nil
function spinner:init(msg)
    local obj = setmetatable({
        msg = msg or "",
        spinner = 1,
        noti = {},
    }, self)

    return obj
end

return spinner
