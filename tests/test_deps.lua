---@module 'mini.test'

local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality
local child = MiniTest.new_child_neovim()

local T = new_set({
	hooks = {
		pre_case = function()
			child.restart({ "-u", "tests/init.lua" })
			child.lua([[
                deps = require("leetcode.deps")
                real_load = deps.load
                -- Pretend some modules are not there.
                function without(missing)
                    deps.load = function(name)
                        if missing[name] then
                            return false, "module '" .. name .. "' not found"
                        end
                        return real_load(name)
                    end
                end
            ]])
		end,
		post_once = function()
			child.stop()
		end,
	},
})

local function check()
	return child.lua_get("deps.check()")
end

T["markup.nvim with its engine is ready"] = function()
	eq(check(), vim.NIL)
	eq(child.lua_get("deps.ensure()"), true)
end

T["says how to get markup.nvim when it is not there"] = function()
	child.lua([[without({ ["markup.config"] = true })]])
	local problem = check()
	eq(problem:find("now needs markup.nvim", 1, true) ~= nil, true)
	eq(problem:find("v0.3.1", 1, true) ~= nil, true)
end

T["reports the installed version when markup.nvim rejects the range"] = function()
	child.lua([[
		local config = require("markup.config")
		config.version = "0.4.0"
		config.supports = function(range)
			requested = range
			return false
		end
	]])
	eq(child.lua_get("deps.check()"), "leetcode.nvim requires markup.nvim ^0.3 (installed: 0.4.0).")
	eq(child.lua_get("requested"), dofile("lazy.lua")[1].version)
end

T["says to build the engine when only it is missing"] = function()
	child.lua([[without({ ["markup.core"] = true })]])
	eq(check():find("not its engine", 1, true) ~= nil, true)
end

T["tells once, and stops the command"] = function()
	child.lua([[
        without({ ["markup.config"] = true })
        told = 0
        vim.notify = function() told = told + 1 end
        first, second = deps.ensure(), deps.ensure()
    ]])
	eq(child.lua_get("{ first, second, told }"), { false, false, 1 })
end

T["the tests run on a markup.nvim the plugin asks for"] = function()
	-- The release the Makefile clones for the tests (CI) must be in the range
	-- lazy.lua and deps.lua ask for, or the tests check another markup.nvim
	-- than the one users get.
	local makefile = table.concat(vim.fn.readfile("Makefile"), "\n")
	local tested = makefile:match("\nMARKUP_VERSION %?= v?([%d%.]+)")
	eq(type(tested), "string")
	local range = child.lua_get("deps.markup")
	eq(vim.version.range(range):has(tested), true)
end

return T
