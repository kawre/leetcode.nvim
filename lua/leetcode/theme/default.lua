local M = {}

---Get highlight group value by name.
---
---@param name string String for looking up highlight group.
---@return table
local function hl(name)
    local highlight = vim.api.nvim_get_hl(0, { name = name, link = false })
    setmetatable(highlight, {
        __index = function(self, key)
            if key == "bg" then return self.background end
            if key == "fg" then return self.foreground end

            return nil
        end,
    })

    return highlight
end

---@alias lc.highlights table<string, table>
---@return lc.highlights
M.get = function()
    return {
        [""] = { fg = hl("Normal").fg },

        easy = { fg = "#46c6c2" },
        medium = { fg = "#fac31d" },
        hard = { fg = "#f8615c" },

        ok = { fg = hl("DiagnosticOk").fg },
        info = { fg = hl("DiagnosticInfo").fg },
        hint = { fg = hl("DiagnosticHint").fg },
        error = { fg = hl("DiagnosticError").fg },

        alt = { fg = hl("Comment").fg },
        normal = { fg = hl("Delimiter").fg },
        italic = { fg = hl("Normal").fg, italic = true },
        bold = { fg = hl("Normal").fg, bold = true },
        underline = { underline = true },

        code = { fg = hl("Type").fg, bg = hl("Normal").bg },
        example = { fg = hl("DiagnosticHint").fg },
        constraints = { fg = hl("DiagnosticInfo").fg },
        indent = { fg = hl("Comment").fg },
        link = { fg = hl("Function").fg, underline = true },
        list = { fg = hl("SpecialChar").fg },
    }
end

return M
