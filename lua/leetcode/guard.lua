local M = {}

function M.auth()
    local auth_api = require("leetcode.api.auth")
    local _, aerr = auth_api.user()

    if aerr then
        return aerr.msg
    end

    return true
end

-- ---@param problem leet.res.problem
-- function M.premium(problem)
--     local config = require("leetcode.config")
--     if not config.auth.is_premium then
--         return "You need to be a premium user to access this feature."
--     end
-- 	if
--         not problem --
--         or (problem.is_paid_only and not config.auth.is_premium)
-- 	then
--
-- 	end
--
--     return true
-- end

return M
