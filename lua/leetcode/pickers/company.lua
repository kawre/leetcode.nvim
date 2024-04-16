local log = require("leetcode.logger")
local t = require("leetcode.translator")
local utils = require("leetcode.api.utils")
local companies_api = require("leetcode.api.companies")


local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local config = require("leetcode.config")

local entry_display = require("telescope.pickers.entry_display")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

---@param company lc.cache.Company
---
---@return string
local function company_formatter(company)
    return ("%s"):format(
        company.name
    )
end


---@param company lc.cache.Company
local function display_company(company)
    local question_count = { company.questionCount, "leetcode_ref" }
    local name = { company.name }
    return unpack({ name, question_count })
end

local displayer = entry_display.create({
    separator = " ",
    items = {
        { width = 90 },
        { width = 5 },
    },
})

local function make_display(entry)
    ---@type lc.cache.Company
    local c = entry.value

    return displayer({
        display_company(c),
    })
end

local function entry_maker(entry)
    return {
        value = entry,
        display = make_display,
        ordinal = company_formatter(entry),
    }
end

local theme = require("telescope.themes").get_dropdown({
    layout_config = {
        width = 100,
        height = 20,
    },
})


return {
    ---@param companies lc.cache.Company[]
    pick = function(companies, options)
        pickers
            .new(theme, {
                prompt_title = t("Select a Company"),
                finder = finders.new_table({
                    results = companies,
                    entry_maker = entry_maker,
                }),
                sorter = conf.generic_sorter(theme),
                attach_mappings = function(prompt_bufnr, map)
                    actions.select_default:replace(function()
                        local selection = action_state.get_selected_entry()
                        if not selection then
                            return
                        end

                        local c = selection.value
                        actions.close(prompt_bufnr)
                        local p, err = companies_api.problems(c.slug, function(res, err)
                            if err then
                                return log.error(err.msg)
                            end
                            local problems = utils.normalize_company_problems(res)
                            require("leetcode.pickers.question").pick(problems, options)
                        end)
                    end)

                    return true
                end,
            })
            :find()
    end,
}
---
---
