local config = require("leetcode.config")
local t = require("leetcode.translator")
local lvls = vim.log.levels

---@class lc.Spinner
---@field spinner lc.spinner
---@field stype lc.spinner_types
---@field index integer
---@field notif any
---@field timer uv.uv_timer_t
---@field msg string
local Spinner = {}
Spinner.__index = Spinner

---@class lc.spinner
---@field frames string[]
---@field fps integer

---@alias lc.spinner_types
---| "hamburger"
---| "snake"
---| "dot"
---| "points"

---@type lc.spinner[]
local spinners = {
    hamburger = {
        frames = { "☱", "☲", "☴", "☲" },
        fps = 15,
    },
    snake = {
        frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
        fps = 10,
    },
    dot = {
        frames = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" },
        fps = 8,
    },
    points = {
        frames = { "∙∙∙", "●∙∙", "∙●∙", "∙∙●" },
        fps = 4,
    },
}

---@param msg? string
---@param opts? table
function Spinner:error(msg, opts)
    self:set_icon("󰅘")
    self:stop(msg, opts)
end

---@param msg? string
---@param opts? table
function Spinner:success(msg, opts)
    self:set_icon("")
    self:stop(msg, opts)
end

---@private
---@param msg? string
---@param opts? table
function Spinner:stop(msg, opts)
    self:set_message(msg)
    self.opts.timeout = 2500
    self:extend(opts)

    if self.timer:is_active() then
        self.timer:stop()
    end

    if not self._closed then
        self._closed = true
        self.timer:close(function()
            self:replace()
        end)
    end
end

---@private
function Spinner:set_icon(icon)
    self:extend({ icon = icon })
end

---@private
function Spinner:set_lvl(lvl)
    if lvl then
        self.lvl = lvl
    end
end

---@private
function Spinner:set_message(msg)
    if msg then
        self.msg = msg
    end
end

function Spinner:soft_update(msg, lvl, opts)
    self:set_message(msg)
    self:set_lvl(lvl)
    self:extend(opts)
end

function Spinner:update(msg, lvl, opts)
    self:soft_update(msg, lvl, opts)
    self:reset_loop()
end

---@private
---@param opts? table
function Spinner:extend(opts)
    if opts then
        self.opts = vim.tbl_deep_extend("force", self.opts, opts)
    end
end

---@private
function Spinner:replace()
    if self.notif then
        local replace_id = type(self.notif) == "table" and self.notif.id or self.notif
        assert(replace_id, "Unknown notification format, please open an issue.")
        self:extend({ replace = replace_id, id = replace_id })
    end

    local msg = self.msg
    if self.timer:is_active() then
        msg = msg .. "…"
    end

    self.notif = vim.notify(msg, self.lvl, self.opts)
end

---@private
function Spinner:reset_loop()
    if self.timer:is_active() then
        self.timer:stop()
    end
    self:loop()
end

---@param spinner_type lc.spinner_types
function Spinner:use(spinner_type)
    if self.stype == spinner_type then
        return
    end
    assert(spinners[spinner_type], "Unknown spinner type: " .. spinner_type)

    self.index = 0
    self.stype = spinner_type
    self:reset_loop()
end

---@private
function Spinner:loop()
    local fps = math.floor(1000 / spinners[self.stype].fps)

    local function update_spinner()
        self.index = (self.index + 1) % #spinners[self.stype].frames
        self:set_icon(spinners[self.stype].frames[self.index + 1])
        self:replace()
    end

    self.timer:start(0, fps, vim.schedule_wrap(update_spinner))
end

---@param msg? string
---@param spinner_type? lc.spinner_types
function Spinner:start(msg, spinner_type)
    local opts = {
        hide_from_history = true,
        history = false,
        title = config.name,
        timeout = false,
    }

    self = setmetatable({
        index = 0,
        timer = vim.loop.new_timer(),
        msg = msg,
        stype = spinner_type or "dot",
        lvl = lvls.INFO,
        opts = opts,
    }, self)

    self:loop()
    return self
end

return Spinner
