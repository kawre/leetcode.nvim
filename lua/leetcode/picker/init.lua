local log = require("leetcode.logger")

---@class leet.Picker
local P = {}

function P.hl_to_ansi(hl_group)
    local color = vim.api.nvim_get_hl(0, { name = hl_group })
    if color and color.fg then
        return string.format(
            "\x1b[38;2;%d;%d;%dm",
            bit.rshift(color.fg, 16),
            bit.band(bit.rshift(color.fg, 8), 0xFF),
            bit.band(color.fg, 0xFF)
        )
    end
    return ""
end

function P.apply_hl(text, hl_group)
    if not hl_group then
        return text
    end
    return P.hl_to_ansi(hl_group) .. text .. "\x1b[0m"
end

function P.normalize(items)
    return vim.tbl_map(function(item)
        return table.concat(
            vim.tbl_map(function(col)
                if type(col) == "table" then
                    return P.apply_hl(col[1], col[2])
                else
                    return col
                end
            end, item.entry),
            " "
        )
    end, items)
end

function P.pick(path, ...)
    local type

    if pcall(require, "fzf-lua") then
        type = "fzf"
    elseif pcall(require, "telescope") then
        type = "telescope"
    end
    assert(type, "picker not found")

    return require(table.concat({ "leetcode.picker", path, type }, "."))(...)
end

function P.language(...)
    P.pick("language", ...)
end

function P.question(...)
    P.pick("question", ...)
end

function P.tabs()
    local utils = require("leetcode.utils")
    local tabs = utils.question_tabs()

    if vim.tbl_isempty(tabs) then
        return log.warn("No questions opened")
    end

    P.pick("tabs", tabs)
end

function P.hidden_field(text, deli)
    return text:match(("([^%s]+)$"):format(deli))
end

return P
