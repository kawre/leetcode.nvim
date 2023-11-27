local Object = require("nui.object")

---@class lc.ui.opts
---@field padding padding
---@field spacing integer
---@field position position

---@class lc.ui.Opts
---@field opts lc.ui.opts
local Opts = Object("LeetOpts")

function Opts:get_padding() --
    local pad = vim.deepcopy(self.opts.padding)
    self.opts.padding = {}
    return pad
end

function Opts:get_spacing() --
    local spacing = self.opts.spacing
    self.opts.spacing = nil
    return spacing
end

function Opts:merge(opts) --
    self.opts = vim.tbl_deep_extend("force", self.opts, opts or {})

    return self
end

function Opts:set(opts) self.opts = vim.tbl_deep_extend("force", self.opts, opts) end

function Opts:get() return self.opts end

function Opts:init(opts) --
    self.opts = vim.tbl_deep_extend("force", {
        padding = {},
    }, vim.deepcopy(opts) or {})
end

---@type fun(opts: table): lc.ui.Opts
local LeetOpts = Opts

return LeetOpts
