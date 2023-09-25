local Text = require("leetcode-ui.component.text")
local config = require("leetcode.config")
local NuiLine = require("nui.line")

---@class lc-menu.Footer
---@field text lc-ui.Text
local footer = {}
footer.__index = footer

function footer:content() return self.text end

---@param opts? any
function footer:init(opts)
    opts = vim.tbl_deep_extend("force", {
        position = "center",
        hl = "Number",
    }, opts or {})

    local text = Text:init({
        opts = opts,
    })

    if config.auth.is_signed_in then
        local line = NuiLine()
        line:append("Signed in as: ", "Comment")
        line:append(config.auth.name, opts.hl)
        text:append(line)
    end

    local obj = setmetatable({
        text = text,
    }, self)

    return obj
end

return footer
