---Get highlight group value by name.
---
---@param name string String for looking up highlight group.
---@return table
local function hl(name)
    local highlight = vim.api.nvim_get_hl(0, { name = name, link = true })
    setmetatable(highlight, {
        __index = function(self, key)
            if key == "bg" then return self.background end
            if key == "fg" then return self.foreground end

            return nil
        end,
    })

    return highlight
end

---@alias lc.Themes table<string, table>
---@type lc.Themes
return function()
    return {
        easy = { fg = "#46c6c2" },
        medium = { fg = "#fac31d" },
        hard = { fg = "#f8615c" },

        ok = { fg = hl("DiagnosticOk").fg },
        info = { fg = hl("DiagnosticInfo").fg },
        hint = { fg = hl("DiagnosticHint").fg },
        error = { fg = hl("DiagnosticError").fg },

        bold = { bold = true },
        italic = { fg = hl("FloatTitle").fg, italic = true },

        normal = { fg = hl("FloatTitle").fg },
        alt = { fg = hl("Comment").fg },
        code = { fg = hl("Type").fg },
        example = { fg = hl("DiagnosticHint").fg },
        constraints = { fg = hl("DiagnosticInfo").fg },
        indent = { fg = hl("Comment").fg },
        link = { fg = hl("Function").fg },
        list = { fg = hl("Tag").fg },
    }
end
