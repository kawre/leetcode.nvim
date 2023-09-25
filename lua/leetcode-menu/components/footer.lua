local Text = require("leetcode-ui.component.text")
local config = require("leetcode.config")

---@class lc-menu.Footer
---@field text lc-ui.Text
local footer = {}
footer.__index = footer

function footer:content() return self.text end

---@param opts? any
function footer:init(opts)
    opts = vim.tbl_deep_extend("force", {
        position = "center",
        hl = "Keyword",
    }, opts or {})

    local text = Text:init({
        opts = opts,
    })

    if config.auth.name then text:append("Signed in as: " .. config.auth.name, opts.hl) end

    local obj = setmetatable({
        text = text,
    }, self)

    return obj
end

return footer
