--------------------------------------------
--- Alias
--------------------------------------------
---@alias position
---| "left"
---| "center"
---| "right"

---@alias padding lc-ui.Layout.padding

--------------------------------------------
--- Component
--------------------------------------------
---@class lc-ui.Component.config.opts
---@field position?  position
---@field hl? string
---@field on_press? function

---@class lc-ui.Component.config
---@field lines? NuiLine[] | string[]
---@field opts? lc-ui.Component.config.opts

--------------------------------------------
--- Group
--------------------------------------------
---@class lc-ui.Group.config.opts
---@field spacing? integer
---@field padding? padding

---@class lc-ui.Group.config
---@field components? lc-ui.Component[]
---@field opts? lc-ui.Group.config.opts

--------------------------------------------
--- Layout
--------------------------------------------
---@class lc-ui.Layout.padding
---@field top? integer
---@field right? integer | string
---@field bot? integer
---@field left? integer | string

---@class lc-ui.Layout.opts
---@field margin? integer
---@field padding? lc-ui.Layout.padding | integer

---@class lc-ui.Layout.config
---@field opts lc-ui.Layout.opts
---@field contents lc-ui.Component[]
