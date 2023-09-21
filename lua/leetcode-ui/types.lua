---@alias position
---| "left"
---| "center"
---| "right"

---@class lc-ui.Layout.padding
---@field top
---@field right
---@field bot
---@field left

---@class lc-ui.Component.config.opts
---@field position?  position
---@field hl? string
---@field on_press? function

---@class lc-ui.Group.config.opts
---@field spacing integer
--@field position  position

---@class lc-ui.Component.config
---@field lines? NuiLine[] | string[]
---@field opts? lc-ui.Component.config.opts

---@class lc-ui.Group.config

---@class lc-ui.Layout.opts
---@field margin? integer
---@field padding? lc-ui.Layout.padding | integer

---@class lc-ui.Layout.config
---@field opts lc-ui.Layout.opts
---@field contents lc-ui.Component[]
