-- Minimal setup for the UI tests. `make deps` gets what they need.
--
-- markup.nvim comes from $MARKUP_PATH (the Makefile sets it to ../markup.nvim
-- when that is there), else deps/markup.nvim, a release cloned by the Makefile.
local root = vim.fn.getcwd()
local markup = vim.env.MARKUP_PATH ~= "" and vim.env.MARKUP_PATH or nil
if not markup then
	markup = vim.uv.fs_stat(root .. "/deps/markup.nvim") and root .. "/deps/markup.nvim"
		or root .. "/../markup.nvim"
end

vim.opt.rtp:prepend(root)
vim.opt.rtp:prepend(markup)
vim.opt.rtp:append(vim.fn.stdpath("data") .. "/site")
vim.opt.rtp:append(root .. "/deps/mini.test")
-- The HTML parser `make deps` builds, so descriptions read the same as for
-- users with nvim-treesitter.
vim.opt.rtp:prepend(root .. "/deps/parsers")

-- Lua coverage with LuaCov when COVERAGE is set (`make coverage`). Every
-- Neovim, the test runner and each child, writes stats of its own, which
-- scripts/coverage.lua merges into one report.
if vim.env.COVERAGE then
	local tree = root .. "/.tests/rocks"
	package.path = ("%s/share/lua/5.1/?.lua;%s/share/lua/5.1/?/init.lua;"):format(tree, tree)
		.. package.path
	-- cluacov, LuaCov's hook in C, when it is there: several times faster.
	package.cpath = ("%s/lib/lua/5.1/?.so;"):format(tree) .. package.cpath
	-- Line hooks only run in the interpreter, compiled traces would skip them.
	jit.off(true, true)
	local runner = require("luacov.runner")
	vim.fn.mkdir(root .. "/.tests/coverage", "p")
	runner.init({
		statsfile = ("%s/.tests/coverage/luacov.stats.%d.out"):format(root, vim.fn.getpid()),
		include = { "lua/leetcode" },
	})
	vim.api.nvim_create_autocmd("VimLeavePre", {
		callback = function()
			runner.save_stats()
		end,
	})
end

if #vim.api.nvim_list_uis() == 0 then
	require("mini.test").setup()

	-- With TEST_TRACE, name every case as it starts and ends, on stderr and at
	-- once, so a case that hangs is named even when the output is piped.
	if vim.env.TEST_TRACE then
		local stdout = MiniTest.gen_reporter.stdout()
		local seen = {}
		MiniTest.config.execute.reporter = {
			start = stdout.start,
			finish = stdout.finish,
			update = function(id)
				stdout.update(id)
				local case = MiniTest.current.all_cases[id]
				local state = case.exec and case.exec.state or "start"
				if seen[id] ~= state then
					seen[id] = state
					io.stderr:write(
						("[%s] %s: %s\n"):format(
							os.date("%H:%M:%S"),
							table.concat(case.desc, " | "),
							state
						)
					)
					io.stderr:flush()
				end
			end,
		}
	end
end
