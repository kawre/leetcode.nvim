local log = require("leetcode.logger")

local cn_utils = {}

---@param str string
local function capitalizeFirst(str)
    return str:lower():gsub("^%l", string.upper)
end

---@return table
function cn_utils.calc_question_count(stats)
    ---@type table<string, { all: integer, solved: integer }>
    local lvls = {
        All = {},
        Easy = {},
        Medium = {},
        Hard = {},
    }

    local all = lvls["All"]
    for key, value in pairs(stats) do
        for _, count in ipairs(value) do
            local diff = count.difficulty
            local lvl = lvls[capitalizeFirst(diff)]

            all.all = (all.all or 0) + count.count
            lvl.all = (lvl.all or 0) + count.count

            if key == "numAcceptedQuestions" then
                all.solved = (all.solved or 0) + count.count
                lvl.solved = (lvl.solved or 0) + count.count
            end
        end
    end

    local ac_count, all_count = {}, {}
    for key, lvl in pairs(lvls) do
        table.insert(ac_count, { difficulty = key, count = lvl.solved })
        table.insert(all_count, { difficulty = key, count = lvl.all })
    end

    return {
        submit_stats = { acSubmissionNum = ac_count },
        questions_count = all_count,
    }
end

return cn_utils
