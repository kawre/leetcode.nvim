---@class leet.guard
local M = {}

function M.auth()
	local config = require("leetcode.config")
	if not config.auth.is_signed_in then
		Markup.log.error("You need to sign in to access this feature.")
		return false
	end
end

return M
