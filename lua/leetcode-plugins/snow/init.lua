local M = {}

---@param props leet.MenuBackgroundProps
function M.menu_background(props)
	local m = require("markup")
	if m.canvas and Markup.animate.enabled then
		return require("leetcode-plugins.snow.canvas").component(props)
	end
end

return M
