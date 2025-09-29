local log = require("leetcode.logger")
local config = require("leetcode.config")

local provider_order = { "snacks-picker", "fzf-lua", "telescope", "mini-picker" }
local providers = {
    ["fzf-lua"] = {
        name = "fzf",
        is_available = function()
            return pcall(require, "fzf-lua")
        end,
    },
    ["snacks-picker"] = {
        name = "snacks",
        is_available = function()
            return pcall(function() ---@diagnostic disable-next-line: undefined-field
                assert(Snacks.config["picker"].enabled)
            end)
        end,
    },
    ["telescope"] = {
        name = "telescope",
        is_available = function()
            return pcall(require, "telescope")
        end,
    },
    ["mini-picker"] = {
        name = "mini",
        is_available = function()
            return pcall(function()
                -- If MiniPick is set up correctly, :Pick command should be available
                return assert(vim.api.nvim_get_commands({})["Pick"])
            end)
        end,
    },
}

local available_pickers = table.concat(
    vim.tbl_map(function(p)
        return providers[p].name
    end, provider_order),
    ", "
)

---@return "fzf" | "telescope" | "snacks" | "mini"
local function resolve_provider()
    ---@type string
    local provider = config.user.picker.provider

    if provider == nil then
        for _, key in ipairs(provider_order) do
            local picker = providers[key]

            if picker.is_available() then
                return picker.name
            end
        end

        error(("No picker is available. Please install one of the following: `%s`") --
            :format(available_pickers))
    end

    local picker = providers[provider]
    assert(
        picker,
        ("Picker `%s` is not supported. Available pickers: `%s`") --
            :format(provider, available_pickers)
    )

    local ok = picker.is_available()
    assert(ok, ("Picker `%s` is not available. Make sure it is installed"):format(provider))
    return picker.name
end

---@class leet.Picker
local P = {}
P.provider = resolve_provider()

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
    local rpath = table.concat({ "leetcode.picker", path, P.provider }, ".")
    return require(rpath)(...)
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
