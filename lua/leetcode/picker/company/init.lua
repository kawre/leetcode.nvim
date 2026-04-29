local config = require("leetcode.config")
local Picker = require("leetcode.picker")

---@class leet.Picker.Company: leet.Picker
local P = {}

P.width = 100
P.height = 0.6

---@param company { name: string, slug: string, question_count: number }
local function display_entry(company)
    local name = { company.name, "leetcode_normal" }
    local count = { ("(%d)"):format(company.question_count), "leetcode_ref" }
    return { name, count }
end

---@param company { name: string, slug: string, question_count: number }
local function ordinal(company)
    return ("%s %s"):format(company.name, company.slug)
end

---@param company { name: string, slug: string, question_count: number }
function P.entry(company)
    return display_entry(company)
end

function P.ordinal(company)
    return ordinal(company)
end

function P.select(selection, close)
    if close then
        close()
    end

    local problems_api = require("leetcode.api.problems")
    local problemlist = require("leetcode.cache.problemlist")
    local log = require("leetcode.logger")

    problems_api.company_questions(selection.slug, function(questions, err)
        if err then
            return log.err(err)
        end

        if not questions or vim.tbl_isempty(questions) then
            return log.warn("No questions found for this company")
        end

        local slug_order = {}
        for i, q in ipairs(questions) do
            slug_order[q.titleSlug] = i
        end

        local cached = problemlist.get()
        local company_questions = vim.tbl_filter(function(q)
            return slug_order[q.title_slug] ~= nil
        end, cached)

        table.sort(company_questions, function(a, b)
            return slug_order[a.title_slug] < slug_order[b.title_slug]
        end)

        local question_picker = require("leetcode.picker")
        question_picker.question(company_questions, {})
    end)
end

return P
