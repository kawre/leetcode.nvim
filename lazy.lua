-- lazy.nvim reads this from the plugin and installs what it lists, so a
-- `"kawre/leetcode.nvim"` spec gets markup.nvim without naming it.
-- Pin the revision providing config.supports() until it ships in a release.
return {
	{ "kawre/markup.nvim", commit = "e7a3c532302491a611be6c5d276e19a218ae8cb0" },
}
