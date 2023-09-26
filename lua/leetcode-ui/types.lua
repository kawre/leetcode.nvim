--------------------------------------------
--- Alias
--------------------------------------------
---@alias position
---| "left"
---| "center"
---| "right"

---@alias padding component.padding

--------------------------------------------
--- Component
--------------------------------------------
---@class lc-ui.Component.opts
---@field position?  position
---@field hl? string
---@field on_press? function
---@field padding? component.padding

---@class lc-ui.Component.config
---@field lines? NuiLine[] | string[]
---@field opts? lc-ui.Component.opts

--------------------------------------------
--- Group
--------------------------------------------
---@class lc-ui.Group.opts
---@field spacing? integer
---@field padding? padding
---@field position? position

---@class lc-ui.Group.config
---@field components? lc-ui.Component[]
---@field opts? lc-ui.Group.opts

--------------------------------------------
--- Layout
--------------------------------------------
---@class component.padding
---@field top? integer
---@field right? integer | string
---@field bot? integer
---@field left? integer | string

---@class lc-ui.Layout.opts
---@field padding? component.padding | integer
---@field position? position

---@class lc-ui.Layout.config
---@field components? lc-ui.Component[]
---@field opts? lc-ui.Layout.opts
---@field bufnr? integer
---@field winid? integer
