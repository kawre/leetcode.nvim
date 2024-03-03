local M = {}

---Get highlight group value by name.
---
---@param name string String for looking up highlight group.
---@return table
local function hl(name)
    local highlight = vim.api.nvim_get_hl(0, { name = name, link = false })
    setmetatable(highlight, {
        __index = function(self, key)
            if key == "bg" then
                return self.background
            end
            if key == "fg" then
                return self.foreground
            end

            return nil
        end,
    })

    return highlight
end

---@alias lc.highlights table<string, vim.api.keyset.highlight>

---@return lc.highlights
M.get = function()
    return {
        [""] = { fg = hl("Normal").fg },

        easy = { fg = "#46c6c2" },
        medium = { fg = "#fac31d" },
        hard = { fg = "#f8615c" },

        easy_alt = { fg = "#294d35" },
        medium_alt = { fg = "#5e4e25" },
        hard_alt = { fg = "#5a302f" },

        ok = { fg = hl("DiagnosticOk").fg },
        info = { fg = hl("DiagnosticInfo").fg },
        hint = { fg = hl("DiagnosticHint").fg },
        error = { fg = hl("DiagnosticError").fg },

        case_ok = { fg = hl("DiagnosticOk").fg, bg = hl("Normal").bg, bold = true },
        case_err = { fg = hl("DiagnosticError").fg, bg = hl("Normal").bg, bold = true },

        case_focus_ok = { bg = hl("DiagnosticOk").fg, fg = hl("NormalSB").bg, bold = true },
        case_focus_err = { bg = hl("DiagnosticError").fg, fg = hl("NormalSB").bg, bold = true },

        normal = { fg = hl("Conceal").fg },
        alt = { fg = hl("Comment").fg },

        italic = { italic = true },
        bold = { bold = true },
        underline = { underline = true },

        code = { fg = hl("Type").fg, bg = hl("Normal").bg },
        example = { fg = hl("DiagnosticHint").fg },
        constraints = { fg = hl("DiagnosticInfo").fg },
        header = { fg = hl("SpecialChar").fg, bold = true },
        followup = { fg = hl("Number").fg, bold = true },

        indent = { fg = hl("Comment").fg },
        link = { fg = hl("Function").fg, underline = true },
        list = { fg = hl("SpecialChar").fg },
        ref = { fg = hl("Tag").fg },
        su = { fg = hl("Number").fg },

        -- calendar
        calendar_0 = { fg = "#45475b" },
        calendar_10 = { fg = "#004d1b" },
        calendar_20 = { fg = "#016620" },
        calendar_30 = { fg = "#078029" },
        calendar_40 = { fg = "#109932" },
        calendar_50 = { fg = "#1cb33d" },
        calendar_60 = { fg = "#28c244" },
        calendar_70 = { fg = "#51d164" },
        calendar_80 = { fg = "#7fe18b" },
        calendar_90 = { fg = "#b3f0b8" },
        calendar_100 = { fg = "#d8ffda" },

        all = { fg = hl("Normal").fg },
        all_alt = { fg = "#45475b" },
    }
end

return M
