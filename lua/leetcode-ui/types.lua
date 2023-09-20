---@alias position
---| "left"
---| "center"
---| "right"

---@class lc.db.Layout.padding
---@field top
---@field right
---@field bot
---@field left

---@class lc.db.Component.config.opts
---@field position  position
---@field hl string

---@class lc.db.Group.config.opts
---@field spacing integer
--@field position  position

---@class lc.db.Component.config
---@field lines? NuiLine[] | string[]
---@field opts? lc.db.Component.config.opts

---@class lc.db.Group.config
---@field components? lc.db.Component[]
---@field opts? lc.db.Group.config.opts

---@class lc.db.Layout.opts
---@field margin? integer
---@field padding? lc.db.Layout.padding | integer

---@class lc.db.Layout.config
---@field opts lc.db.Layout.opts
---@field contents lc.db.Component[]
