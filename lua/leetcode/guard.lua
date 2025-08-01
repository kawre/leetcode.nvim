---@class leet.guard
local M = {}

function M.auth()
	local config = require("leetcode.config")
	if not config.auth.is_signed_in then
		Markup.log.error("You need to sign in to access this feature.")
		return false
	end
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
