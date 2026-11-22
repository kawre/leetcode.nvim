--- Gentle falling snow painted on a background canvas behind the menu.

local m = require("markup")
local config = require("leetcode.config")

local api = vim.api
local floor, sin, max = math.floor, math.sin, math.max

---@class leet.ui.snow
local M = {}

local FRAME_MS = 50
local CELLS_PER_FLAKE = 75
local MIN_FLAKES = 12

local LAYERS = {
	{
		glyphs = { ".", "·", "˙" },
		style = "leetcode_snow_far",
		speed = { 1.4, 2.6 },
		drift = { -0.4, 0.4 },
		amp = { 0.8, 1.8 },
		freq = { 0.35, 0.7 },
		weight = 0.5,
	},
	{
		glyphs = { "·", "∙", "∘" },
		style = "leetcode_snow_mid",
		speed = { 2.8, 4.6 },
		drift = { -0.7, 0.9 },
		amp = { 1.4, 3.0 },
		freq = { 0.5, 1.0 },
		weight = 0.35,
	},
	{
		glyphs = { "*", "∗", "✻", "❄" },
		style = "leetcode_snow_near",
		speed = { 4.8, 7.2 },
		drift = { -0.8, 1.4 },
		amp = { 2.0, 4.0 },
		freq = { 0.65, 1.3 },
		weight = 0.15,
	},
}

local function between(bounds)
	return bounds[1] + math.random() * (bounds[2] - bounds[1])
end

local function pick_layer()
	local roll, acc = math.random(), 0
	for index, layer in ipairs(LAYERS) do
		acc = acc + layer.weight
		if roll <= acc then
			return index, layer
		end
	end
	return #LAYERS, LAYERS[#LAYERS]
end

--- Creates one snowflake distributed across `width` × `height`.
---@param width integer
---@param height integer
---@return table
function M.flake(width, height)
	local depth, layer = pick_layer()
	return {
		x = math.random() * max(width, 1),
		y = math.random() * max(height, 1),
		speed = between(layer.speed),
		drift = between(layer.drift),
		amp = between(layer.amp),
		freq = between(layer.freq),
		phase = math.random() * math.pi * 2,
		glyph = layer.glyphs[math.random(#layer.glyphs)],
		style = layer.style,
		depth = depth,
	}
end

--- Keeps `flakes` sized to the surface area, sorted far-to-near so closer
--- flakes draw on top of distant ones.
---@param flakes table[]
---@param width integer
---@param height integer
---@return table[]
function M.populate(flakes, width, height)
	local target = max(MIN_FLAKES, floor(width * height / CELLS_PER_FLAKE))
	if #flakes == target then
		return flakes
	end
	while #flakes < target do
		flakes[#flakes + 1] = M.flake(width, height)
	end
	while #flakes > target do
		table.remove(flakes)
	end
	table.sort(flakes, function(a, b)
		return a.depth < b.depth
	end)
	return flakes
end

--- Zero-indexed `(col, row)` of `flake` at `seconds` inside `width` × `height`.
---@param flake table
---@param seconds number
---@param width integer
---@param height integer
---@return integer col
---@return integer row
function M.position(flake, seconds, width, height)
	local row = floor((flake.y + flake.speed * seconds) % height)
	local sway = sin(seconds * flake.freq + flake.phase) * flake.amp
	local col = floor((flake.x + flake.drift * seconds + sway) % width)
	return col, row
end

--- Draws every flake at `seconds` onto `ctx`.
---@param ctx markup.canvas.context
---@param flakes table[]
---@param seconds number
function M.draw(ctx, flakes, seconds)
	local w, h = ctx.width, ctx.height
	if w <= 0 or h <= 0 then
		return
	end
	M.populate(flakes, w, h)
	for i = 1, #flakes do
		local flake = flakes[i]
		local col, row = M.position(flake, seconds, w, h)
		ctx:set(col, row, flake.glyph, flake.style)
	end
end

local Snow = m.component(function(props)
	if not (config.user.ui.snow and Markup.animate.enabled and m.canvas) then
		return nil
	end

	local view = m.use_view()
	local seconds = m.signal(0)
	local flakes = {}
	local elapsed, last_t = 0, 0

	Markup.animate.run({
		duration = 1000,
		easing = "linear",
		loop = true,
		next = function()
			return FRAME_MS
		end,
		update = function(t)
			local delta = t - last_t
			if delta < 0 then
				delta = delta + 1
			end
			last_t = t
			elapsed = elapsed + delta
			local win = view.win.win
			if
				not (win and api.nvim_win_is_valid(win))
				or api.nvim_win_get_tabpage(win) ~= api.nvim_get_current_tabpage()
			then
				return
			end
			seconds(elapsed)
		end,
	})

	return m.canvas({
		position = "absolute",
		top = function()
			return view:scroll()
		end,
		left = 0,
		z = -1,
		inert = true,
		snap = false,
		width = props.width,
		height = props.height,
		draw = function(ctx)
			M.draw(ctx, flakes, seconds())
		end,
	})
end)

M.component = Snow

return setmetatable(M, {
	__call = function(_, props)
		return Snow(props)
	end,
})
