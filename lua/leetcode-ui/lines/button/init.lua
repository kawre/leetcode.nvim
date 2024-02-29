local Lines = require("leetcode-ui.lines")
local log = require("leetcode.logger")

---@class lc.ui.Button : lc.ui.Lines
local Button = Lines:extend("LeetButton")

---@alias lc.ui.Button.opts { sc?: string, on_press?: function } | lc.ui.opts

---@param renderer lc.ui.Renderer
---@param opts lc.ui.opts
function Button:draw(renderer, opts)
    renderer:apply_button(self)

    local options = self._.opts
    if options.on_press then
        renderer:map("n", options.sc, options.on_press, {
            noremap = false,
            silent = true,
            nowait = true,
            clearable = true,
        })
    end

    Button.super.draw(self, renderer, opts)
end

function Button:press()
    self._.opts.on_press()
end

---@param lines lc.ui.Line[]
---@param opts lc.ui.Button.opts
function Button:init(lines, opts) --
    local options = vim.tbl_deep_extend("force", {
        on_press = function() end,
    }, opts or {})

    Button.super.init(self, lines, options)
end

---@type fun(lines?: lc.ui.Line[], opts?: lc.ui.Button.opts): lc.ui.Button
local LeetButton = Button

return LeetButton
