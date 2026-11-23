---@module 'mini.test'

local helpers = dofile("tests/helpers.lua")
local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality
local child = MiniTest.new_child_neovim()

local T = new_set({
	hooks = {
		pre_case = function()
			helpers.boot(child)
		end,
		post_once = function()
			child.stop()
		end,
	},
})

T["snow"] = new_set()

T["snow"]["moves flakes downward and wraps within bounds"] = function()
	child.lua([[
		snow = require("leetcode-plugins.snow.canvas")
		flake = {
			x = 5,
			y = 2,
			speed = 4,
			drift = 1,
			amp = 0,
			freq = 0,
			phase = 0,
			glyph = "*",
			style = "leetcode_snow_near",
			depth = 3,
		}
		c0, r0 = snow.position(flake, 0, 20, 10)
		c1, r1 = snow.position(flake, 1, 20, 10)
		c2, r2 = snow.position(flake, 3, 20, 10)
	]])
	eq(child.lua_get("{ c0, r0 }"), { 5, 2 })
	eq(child.lua_get("{ c1, r1 }"), { 6, 6 })
	eq(child.lua_get("{ c2, r2 }"), { 8, 4 })
end

T["snow"]["renders behind the menu and animates with zero layouts"] = function()
	child.lua([[
		if not m.canvas then
			_G.skipped = true
			return
		end
		Markup.animate.enabled = true
		Markup.animate.manual = true
		local config = require("leetcode.config")
		config.user.plugins = { snow = true }
		config.load_plugins()
		_G.cookie = { csrftoken = "x" }
		menu = require("leetcode.ui.menu")
		menu.win.buf = vim.api.nvim_get_current_buf()
		menu.win:show()
		menu.render()
		vim.wait(100, function() reactive.flush(); return menu.page() ~= "loading" end, 5)
		reactive.flush()

		before_marks = #vim.tbl_filter(function(mark)
			return vim.startswith(mark[4].hl_group, "MarkupCanvas_")
		end, menu.view:highlights())

		-- Let intro animations settle, then confirm snow redraws with zero layouts.
		for _ = 1, 20 do
			Markup.animate.tick(100)
			reactive.flush()
		end
		before_text = table.concat(buffer_text(menu.win.buf), "\n")
		Markup.animate.tick(250)
		reactive.flush()
		tick_layouts = menu.view.stats.layouts
		after_text = table.concat(buffer_text(menu.win.buf), "\n")
		after_marks = #vim.tbl_filter(function(mark)
			return vim.startswith(mark[4].hl_group, "MarkupCanvas_")
		end, menu.view:highlights())
		has_dashboard = contains(menu.win.buf, "leetcode.nvim")
	]])
	if child.lua_get("_G.skipped == true") then
		return
	end
	eq(child.lua_get("before_marks > 0"), true)
	eq(child.lua_get("after_marks > 0"), true)
	eq(child.lua_get("before_text ~= after_text"), true)
	eq(child.lua_get("tick_layouts"), 0)
	eq(child.lua_get("has_dashboard"), true)
end

T["snow"]["draws flying reindeer across the canvas and retires them offscreen"] = function()
	child.lua([[
		if not m.canvas then
			_G.skipped = true
			return
		end
		local canvas = require("markup.view.canvas")
		local snow = require("leetcode-plugins.snow.canvas")
		local ctx = canvas.context(40, 12)
		local palette = snow.palette()
		local herd = {
			dir = 1,
			speed = 10,
			base_y = 3,
			started = 0,
			width = 40,
			members = { { offset_x = 0, offset_y = 0, bob_phase = 0, rudolph = true } },
		}
		mid_alive = snow.draw_reindeer(ctx, herd, 2, palette)
		has_antlers = table.concat(ctx.chars):find("\\Y/", 1, true) ~= nil
		has_nose = false
		local nose_id = require("markup.view.hl").id(palette.reindeer_nose)
		for _, id in ipairs(ctx.hls) do
			if id == nose_id then
				has_nose = true
				break
			end
		end
		ctx:clear()
		done_alive = snow.draw_reindeer(ctx, herd, 20, palette)
	]])
	if child.lua_get("_G.skipped == true") then
		return
	end
	eq(child.lua_get("mid_alive"), true)
	eq(child.lua_get("has_antlers"), true)
	eq(child.lua_get("has_nose"), true)
	eq(child.lua_get("done_alive"), false)
end

T["snow"]["leaves snow unloaded by default"] = function()
	child.lua([[
		Markup.animate.enabled = true
		Markup.animate.manual = true
		_G.cookie = { csrftoken = "x" }
		menu = require("leetcode.ui.menu")
		menu.win.buf = vim.api.nvim_get_current_buf()
		menu.win:show()
		menu.render()
		vim.wait(100, function() reactive.flush(); return menu.page() ~= "loading" end, 5)
		reactive.flush()

		snow_marks = #vim.tbl_filter(function(mark)
			return vim.startswith(mark[4].hl_group, "MarkupCanvas_")
		end, menu.view:highlights())
	]])
	eq(child.lua_get("snow_marks"), 0)
	eq(child.lua_get("package.loaded[\"leetcode-plugins.snow\"] == nil"), true)
	eq(child.lua_get("package.loaded[\"leetcode-plugins.snow.canvas\"] == nil"), true)
end

T["snow"]["leaves the canvas unloaded when animations are disabled"] = function()
	child.lua([[
		local config = require("leetcode.config")
		config.user.plugins = { snow = true }
		config.load_plugins()
		local background = config.menu_backgrounds[1]
		local size = function() return 10 end
		inactive = background({ width = size, height = size }) == nil
	]])
	eq(child.lua_get("inactive"), true)
	eq(child.lua_get("package.loaded[\"leetcode-plugins.snow.canvas\"] == nil"), true)
end

return T
