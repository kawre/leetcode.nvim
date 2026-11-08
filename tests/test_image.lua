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

T["gif"] = new_set()

T["gif"]["plays as its frames, each for its delay, and is kept"] = function()
	if vim.fn.executable("magick") == 0 then
		MiniTest.skip("needs ImageMagick")
	end
	child.lua([[
		local dir = vim.fn.tempname()
		vim.fn.mkdir(dir, "p")
		gif = dir .. "/spin.gif"
		-- Three frames: 0.2 s, 0.05 s and 0 (shown as 0.1 s, as browsers do).
		vim.system({ "magick",
			"-delay", "20", "-size", "8x8", "xc:red",
			"-delay", "5", "-size", "8x8", "xc:green",
			"-delay", "0", "-size", "8x8", "xc:blue",
			gif }):wait()
		image = require("leetcode.image")
		data = image.load("file://" .. gif)
		vim.wait(5000, function() return data() ~= nil end, 20)
		frames = data()
	]])
	eq(child.lua_get("type(frames)"), "table")
	eq(child.lua_get("#frames"), 3)
	eq(child.lua_get("vim.tbl_map(function(f) return f.delay end, frames)"), { 200, 50, 100 })
	eq(child.lua_get("frames[1].data:sub(2, 4)"), "PNG")

	-- Read back from the cache the next time, without a download.
	child.lua([[
		package.loaded["leetcode.image"] = nil
		again = require("leetcode.image").load("file://" .. gif)()
	]])
	eq(child.lua_get("type(again) == 'table' and #again"), 3)
end

T["gif"]["a png stays one image"] = function()
	if vim.fn.executable("magick") == 0 then
		MiniTest.skip("needs ImageMagick")
	end
	child.lua([[
		local png = vim.fn.tempname() .. ".png"
		vim.system({ "magick", "-size", "8x8", "xc:red", png }):wait()
		data = require("leetcode.image").load("file://" .. png)
		vim.wait(5000, function() return data() ~= nil end, 20)
	]])
	eq(child.lua_get("type(data())"), "string")
	eq(child.lua_get("data():sub(2, 4)"), "PNG")
end

return T
