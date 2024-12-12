local log = require("leetcode.logger")
local t = require("leetcode.translator")
local config = require("leetcode.config")
local utils = require("leetcode.utils")

local L = {}

L.width = 80
L.height = 15

---@param snippet lc.QuestionCodeSnippet
local function dislay_icon(snippet)
    local hl = "leetcode_lang_" .. snippet.t.slug
    vim.api.nvim_set_hl(0, hl, { fg = snippet.t.color })

    return { snippet.t.icon, hl }
end

---@param snippet lc.QuestionCodeSnippet
local function display_lang(snippet)
    return { snippet.lang }
end

function L.entry(item)
    return {
        dislay_icon(item),
        display_lang(item),
    }
end

---@param item lc.QuestionCodeSnippet
function L.ordinal(item)
    return ("%s %s"):format(item.t.lang, item.t.slug)
end

function L.items(content)
    return vim.tbl_map(function(item)
        ---@type lc.language
        item.t = utils.get_lang(item.lang_slug)
        if not item.t then
            return
        end
        return { entry = L.entry(item), value = item }
    end, content)
end

function L.select(selection, question, cb, close)
    if question.lang == selection.slug then
        return log.warn(("%s: %s"):format(t("Language already set to"), selection.lang))
    end

    config.lang = selection.slug
    if close then
        close()
    end

    if cb then
        cb(selection.slug)
    else
        question:change_lang(selection.slug)
    end
end

return L
