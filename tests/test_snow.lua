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
		snow = require("leetcode.ui.menu.snow")
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
		require("leetcode.config").user.ui.snow = true
		_G.cookie = { csrftoken = "x" }
		menu = require("leetcode.ui.menu")
		menu.win.buf = vim.api.nvim_get_current_buf()
		menu.win:show()
		menu.render()
		vim.wait(100, function() reactive.flush(); return menu.page() ~= "loading" end, 5)
		reactive.flush()

		before_marks = #vim.tbl_filter(function(mark)
			return vim.startswith(mark[4].hl_group, "leetcode_snow_")
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
			return vim.startswith(mark[4].hl_group, "leetcode_snow_")
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

T["snow"]["stays off when ui.snow is false"] = function()
	child.lua([[
		Markup.animate.enabled = true
		Markup.animate.manual = true
		require("leetcode.config").user.ui.snow = false
		_G.cookie = { csrftoken = "x" }
		menu = require("leetcode.ui.menu")
		menu.win.buf = vim.api.nvim_get_current_buf()
		menu.win:show()
		menu.render()
		vim.wait(100, function() reactive.flush(); return menu.page() ~= "loading" end, 5)
		reactive.flush()

		snow_marks = #vim.tbl_filter(function(mark)
			return vim.startswith(mark[4].hl_group, "leetcode_snow_")
		end, menu.view:highlights())
	]])
	eq(child.lua_get("snow_marks"), 0)
end

return T
