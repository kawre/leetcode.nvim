--- Gentle falling snow painted on a background canvas behind the menu.

local m = require("markup")

local api = vim.api
local floor, sin, max = math.floor, math.sin, math.max

---@class leet.ui.snow
local M = {}

local FRAME_MS = 50
local CELLS_PER_FLAKE = 75
local MIN_FLAKES = 12

local SPRITE_W = 9
local SPRITE_H = 3
local SPARKLES = { "∗", "·", "·", "." }
local FIRST_FLYBY = { 3, 6 }
local NEXT_FLYBY = { 10, 18 }

local LAYERS = {
	{
		glyphs = { ".", "·", "˙" },
		style = "snow_far",
		speed = { 1.4, 2.6 },
		drift = { -0.4, 0.4 },
		amp = { 0.8, 1.8 },
		freq = { 0.35, 0.7 },
		weight = 0.5,
	},
	{
		glyphs = { "·", "∙", "∘" },
		style = "snow_mid",
		speed = { 2.8, 4.6 },
		drift = { -0.7, 0.9 },
		amp = { 1.4, 3.0 },
		freq = { 0.5, 1.0 },
		weight = 0.35,
	},
	{
		glyphs = { "*", "∗", "✻", "❄" },
		style = "snow_near",
		speed = { 4.8, 7.2 },
		drift = { -0.8, 1.4 },
		amp = { 2.0, 4.0 },
		freq = { 0.65, 1.3 },
		weight = 0.15,
	},
}

--- Builds the plugin's palette from the active colorscheme.
function M.palette()
	local color, mix = Markup.animate.color, Markup.animate.mix
	local light = vim.o.background == "light"
	local bg = color("Normal", "bg") or (light and 0xffffff or 0x1e1e2e)
	local fg = color("Normal", "fg") or (light and 0x1e1e2e or 0xcdd6f4)
	local accent = color("leetcode_accent", "fg") or 0xffa116
	return {
		snow_far = { fg = mix(bg, fg, 0.22) },
		snow_mid = { fg = mix(bg, fg, 0.42) },
		snow_near = { fg = mix(bg, fg, 0.68) },
		reindeer = { fg = mix(bg, 0xd4a373, light and 0.85 or 0.72) },
		reindeer_nose = { fg = color("DiagnosticError", "fg") or 0xf8615c, bold = true },
		reindeer_sparkle = { fg = mix(bg, accent, 0.6) },
	}
end

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

--- Creates a small formation of 1–3 flying reindeer crossing the sky.
---@param width integer
---@param height integer
---@param started number seconds when the flyby begins
---@return table
function M.spawn_herd(width, height, started)
	local dir = math.random() < 0.5 and 1 or -1
	local count = math.random(1, 3)
	local max_y = max(1, height - SPRITE_H - 1)
	local upper_y = max(1, floor(height * 0.28))
	local base_y = math.random() < 0.65 and math.random(1, upper_y) or math.random(1, max_y)

	local members = {}
	for i = 1, count do
		members[i] = {
			offset_x = (i - 1) * 13,
			offset_y = i == 1 and 0 or (i % 2 == 0 and 1 or -1),
			bob_phase = (i - 1) * 1.1,
			rudolph = i == 1,
		}
	end

	return {
		dir = dir,
		speed = between({ 11, 16 }),
		base_y = base_y,
		started = started,
		width = width,
		members = members,
	}
end

--- Draws one galloping reindeer sprite at `(x, y)` without overwriting empty
--- surrounding cells so snowflakes stay visible around it.
---@param ctx markup.canvas.context
---@param x integer
---@param y integer
---@param dir 1|-1
---@param frame 1|2
---@param rudolph boolean
---@param palette table<string, vim.api.keyset.highlight>
local function draw_deer(ctx, x, y, dir, frame, rudolph, palette)
	local body = palette.reindeer
	local nose = rudolph and palette.reindeer_nose or body

	if dir == 1 then
		ctx:text(x + 6, y, "\\Y/", body)
		ctx:text(x + 1, y + 1, "`___/^o", body)
		ctx:set(x + 8, y + 1, "•", nose)
		if frame == 1 then
			ctx:text(x, y + 2, "/ /", body)
			ctx:text(x + 5, y + 2, "\\ \\", body)
		else
			ctx:text(x + 1, y + 2, "\\ \\", body)
			ctx:text(x + 5, y + 2, "/ /", body)
		end
	else
		ctx:text(x, y, "\\Y/", body)
		ctx:set(x, y + 1, "•", nose)
		ctx:text(x + 1, y + 1, "o^\\___'", body)
		if frame == 1 then
			ctx:text(x + 1, y + 2, "/ /", body)
			ctx:text(x + 6, y + 2, "\\ \\", body)
		else
			ctx:text(x + 1, y + 2, "\\ \\", body)
			ctx:text(x + 5, y + 2, "/ /", body)
		end
	end
end

--- Draws an active reindeer herd and its sparkle trail, returning whether any
--- reindeer is still on or approaching the canvas.
---@param ctx markup.canvas.context
---@param herd table
---@param seconds number
---@param palette table<string, vim.api.keyset.highlight>
---@return boolean alive
function M.draw_reindeer(ctx, herd, seconds, palette)
	local w = ctx.width
	local age = max(seconds - herd.started, 0)
	local dir = herd.dir
	local lead_x = dir == 1 and (-SPRITE_W + herd.speed * age) or (w - herd.speed * age)
	local alive = false

	for _, member in ipairs(herd.members) do
		local x = floor(dir == 1 and (lead_x - member.offset_x) or (lead_x + member.offset_x))
		local bob = sin(age * 3.2 + member.bob_phase) * 0.8
		local y = floor(herd.base_y + member.offset_y + bob + 0.5)
		local frame = (floor(age * 5 + member.bob_phase) % 2) + 1

		if (dir == 1 and x - 10 < w) or (dir == -1 and x + SPRITE_W + 10 >= 0) then
			alive = true
			-- Soft twinkling stardust trail behind the tail.
			for s = 1, #SPARKLES do
				if floor(age * 8 + s * 3 + member.bob_phase) % 3 ~= 0 then
					local sx = dir == 1 and (x - s * 2) or (x + SPRITE_W + s * 2 - 1)
					local sy = y + 1 + ((s + floor(age * 4)) % 2 == 0 and 0 or -1)
					ctx:set(sx, sy, SPARKLES[s], palette.reindeer_sparkle)
				end
			end
			draw_deer(ctx, x, y, dir, frame, member.rudolph, palette)
		end
	end

	return alive
end

--- Draws every flake (and any passing reindeer) at `seconds` onto `ctx`.
---@param ctx markup.canvas.context
---@param flakes table[]
---@param seconds number
---@param palette table<string, vim.api.keyset.highlight>
---@param state? { herd?: table, next_at?: number }
function M.draw(ctx, flakes, seconds, palette, state)
	local w, h = ctx.width, ctx.height
	if w <= 0 or h <= 0 then
		return
	end
	M.populate(flakes, w, h)
	for i = 1, #flakes do
		local flake = flakes[i]
		local col, row = M.position(flake, seconds, w, h)
		ctx:set(col, row, flake.glyph, palette[flake.style])
	end

	if state and h >= SPRITE_H + 1 and w >= SPRITE_W + 4 then
		if not state.herd and seconds >= (state.next_at or 0) then
			state.herd = M.spawn_herd(w, h, seconds)
		end
		if state.herd and not M.draw_reindeer(ctx, state.herd, seconds, palette) then
			state.herd = nil
			state.next_at = seconds + between(NEXT_FLYBY)
		end
	end
end

local Snow = m.component(function(props)
	local view = m.use_view()
	local palette = m.signal(M.palette())
	local colorscheme = api.nvim_create_autocmd("ColorScheme", {
		callback = function()
			palette(M.palette())
		end,
	})
	m.on_cleanup(function()
		api.nvim_del_autocmd(colorscheme)
	end)
	local seconds = m.signal(0)
	local flakes = {}
	local state = { next_at = between(FIRST_FLYBY) }
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
			M.draw(ctx, flakes, seconds(), palette(), state)
		end,
	})
end)

M.component = Snow

return M
