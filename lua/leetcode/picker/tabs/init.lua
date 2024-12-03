local log = require("leetcode.logger")
local utils = require("leetcode.utils")
local ui_utils = require("leetcode-ui.utils")
local t = require("leetcode.translator")

local config = require("leetcode.config")
local icons = config.icons

local T = {}

---@param q lc.QuestionResponse
function T.ordinal(q)
    return ("%s. %s %s"):format(q.frontend_id, q.title, q.translated_title)
end

local function display_current(entry)
    local tabp = vim.api.nvim_get_current_tabpage()
    if tabp ~= entry.tabpage then
        return unpack({ "", "" })
    end

    return { icons.caret.right, "leetcode_ref" }
end

local function display_difficulty(q)
    local lang = utils.get_lang(q.lang)
    if not lang then
        return {}
    end
    return { lang.icon, "leetcode_lang_" .. lang.slug }
end

---@param question lc.QuestionResponse
local function display_question(question)
    local hl = ui_utils.diff_to_hl(question.difficulty)

    local index = { question.frontend_id .. ".", hl }
    local title = { utils.translate(question.title, question.translated_title) }

    return unpack({ index, title })
end

function T.entry(item)
    return {
        display_current(item),
        display_difficulty(item.question),
        display_question(item.question.q),
    }
end

function T.items(content)
    return vim.tbl_map(function(item)
        return { entry = T.entry(item), value = item }
    end, content)
end

return T
