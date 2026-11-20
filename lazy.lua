-- lazy.nvim reads this from the plugin and installs what it lists, so a
-- `"kawre/leetcode.nvim"` spec gets markup.nvim without naming it.
-- markup.nvim's build.lua then downloads its engine.
return {
	-- The release line leetcode.nvim works with; lua/leetcode/deps.lua checks
	-- the same at start.
	{ "kawre/markup.nvim", version = "^0.2" },
}
