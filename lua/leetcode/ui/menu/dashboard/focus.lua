--- What the cursor is on in the dashboard. Only one thing at a time is lit, and
--- the rest steps back, so that it shows from across the screen.

local m = require("markup")

local M = {}

---@class leet.ui.menu.focused
---@field id string
---@field title string
---@field detail? string what pressing it does, for the line below the tiles

---@type fun(value?: leet.ui.menu.focused): leet.ui.menu.focused?
M.current = m.signal(nil)

--- Joins a component to the focus. Returns what to give `on_hover`, and whether
--- it is the one lit, or one of those stepping back.
---@param item leet.ui.menu.focused
---@return fun(hovered: boolean) on_hover
---@return fun(): boolean selected
---@return fun(): boolean dimmed
function M.use(item)
	local function mine()
		local current = m.untrack(M.current)
		return current ~= nil and current.id == item.id
	end

	m.on_cleanup(function()
		if mine() then
			M.current(nil)
		end
	end)

	local function on_hover(hovered)
		-- A page on its way out lights nothing up as it falls past the cursor.
		if hovered and Leet.menu.dropping then
			return
		end
		if hovered then
			M.current(item)
		elseif mine() then
			M.current(nil)
		end
	end

	local function selected()
		local current = M.current()
		return current ~= nil and current.id == item.id
	end

	local function dimmed()
		local current = M.current()
		return current ~= nil and current.id ~= item.id
	end

	return on_hover, selected, dimmed
end

--- Whether something is lit, which is when everything else steps back.
---@return boolean
function M.any()
	return M.current() ~= nil
end

return M
