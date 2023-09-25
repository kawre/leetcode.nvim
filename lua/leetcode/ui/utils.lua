local utils = {}

---@param question lc.Problem
---
---@return string
function utils.question_formatter(question)
    return string.format(
        "%d. %s (%d%%, %s)",
        question.frontend_id,
        question.title,
        question.ac_rate,
        question.difficulty
    )
end

return utils
