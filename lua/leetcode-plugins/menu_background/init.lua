local config = require("leetcode.config")
local M = {}

local backgrounds = {
	snow = "leetcode-plugins.menu_background.backgrounds.snow",
}

---@param props leet.MenuBackgroundProps
function M.menu_background(props)
	local selected = config.user.plugins.menu_background
	if selected == true then
		selected = "snow"
	end

	local module = backgrounds[selected]
	if not module then
		require("leetcode.logger").warn(("Unknown menu background: %s"):format(tostring(selected)))
		return
	end

	local m = require("markup")
	if m.canvas and Markup.animate.enabled then
		return require(module).component(props)
	end
end

return M
