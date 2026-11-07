--- A burst of particles over the editor. Each one is a window of a single cell:
--- a transparent float would hide the floats below it, because Neovim only
--- blends against the default grid.

local animate = Markup.animate

local api = vim.api

---@class leet.ui.confetti
local M = {}

local GLYPHS = { "▪", "●", "◆", "▴", "•", "■" }
local COLORS = { "#46c6c2", "#fac31d", "#f8615c", "#ffa116", "#89b4fa", "#cba6f7" }
local COUNT = 56
local DURATION = 1200
--- Seconds of flight per second on screen, so that a shorter burst still lands.
local PACE = 1700 / DURATION
local GRAVITY = 42

--- Fired from the bottom, spreading out and falling back down.
---@param width integer
---@param origin { row: integer, col: integer }
local function particles(width, origin)
	local result = {}
	for i = 1, COUNT do
		local angle = (math.random() - 0.5) * math.pi * 0.9 - math.pi / 2
		local speed = 18 + math.random() * 34
		result[i] = {
			x = origin.col + (math.random() - 0.5) * width * 0.5,
			y = origin.row,
			-- Cells are twice as tall as wide.
			vx = math.cos(angle) * speed * 2,
			vy = math.sin(angle) * speed,
			glyph = GLYPHS[math.random(#GLYPHS)],
			color = math.random(#COLORS),
		}
	end
	return result
end

--- Where a particle is after `seconds`.
---@param particle table
---@param seconds number
---@return integer row
---@return integer col
function M.position(particle, seconds)
	return math.floor(particle.y + particle.vy * seconds + GRAVITY * seconds ^ 2 / 2 + 0.5),
		math.floor(particle.x + particle.vx * seconds + 0.5)
end

---@param particle table
local function open(particle)
	local buf = api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"
	api.nvim_buf_set_lines(buf, 0, -1, false, { particle.glyph })

	particle.win = api.nvim_open_win(buf, false, {
		relative = "editor",
		row = 0,
		col = 0,
		width = 1,
		height = 1,
		style = "minimal",
		focusable = false,
		noautocmd = true,
		hide = true,
		zindex = 250,
	})
	vim.wo[particle.win].winhighlight = "NormalFloat:LeetConfetti" .. particle.color
end

---@param particle table
---@param seconds number
---@param width integer
---@param height integer
local function move(particle, seconds, width, height)
	if not api.nvim_win_is_valid(particle.win) then
		return
	end

	local row, col = M.position(particle, seconds)
	local visible = row >= 0 and row < height and col >= 0 and col < width

	api.nvim_win_set_config(particle.win, {
		relative = "editor",
		row = math.max(row, 0),
		col = math.max(col, 0),
		hide = not visible,
	})
end

--- Celebrates from a point on the screen, which is the bottom center by default.
---@param origin? { row: integer, col: integer }
function M.burst(origin)
	if not animate.enabled then
		return
	end

	for i, color in ipairs(COLORS) do
		api.nvim_set_hl(0, "LeetConfetti" .. i, { fg = color })
	end

	local width, height = vim.o.columns, vim.o.lines - vim.o.cmdheight
	local items = particles(width, origin or { row = height - 1, col = math.floor(width / 2) })

	for _, particle in ipairs(items) do
		open(particle)
	end

	animate.run({
		duration = DURATION,
		easing = "linear",
		update = function(t)
			for _, particle in ipairs(items) do
				move(particle, t * DURATION / 1000 * PACE, width, height)
			end
		end,
		done = function()
			for _, particle in ipairs(items) do
				if api.nvim_win_is_valid(particle.win) then
					api.nvim_win_close(particle.win, true)
				end
			end
		end,
	})
end

return M
