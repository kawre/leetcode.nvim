---@module 'mini.test'

local helpers = dofile("tests/helpers.lua")
local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality
local child = MiniTest.new_child_neovim()

local T = new_set({
	hooks = {
		pre_case = function()
			helpers.boot(child)
			child.lua([[
				_G.cookie = { str = "LEETCODE_SESSION=s; csrftoken=c", csrftoken = "c" }
				api = require("leetcode.api")
				calls = {}
				replies = {}

				-- curl, played back from `replies`.
				vim.system = function(args, opts, on_exit)
					calls[#calls + 1] = { args = args, stdin = opts.stdin }
					local reply = table.remove(replies, 1) or { code = 0, stdout = "{}\n200" }
					local proc = { code = reply.code, stdout = reply.stdout, stderr = reply.stderr }
					if on_exit then
						on_exit(proc)
					end
					return { wait = function() return proc end }
				end

				function has_arg(call, value)
					return vim.tbl_contains(calls[call].args, value)
				end
			]])
		end,
		post_once = function()
			child.stop()
		end,
	},
})

local function run(code)
	child.lua(code)
end

local function get(code)
	return child.lua_get(code)
end

--- Waits for callbacks, which come back on the main loop.
local function settle()
	run("vim.wait(50, function() return done end, 5)")
end

T["needs no plenary"] = function()
	eq(get("package.loaded['plenary.curl'] == nil and package.loaded['plenary.path'] == nil"), true)
	eq(get("pcall(require, 'plenary.path')"), false)
end

T["gets and decodes json"] = function()
	run([[
		replies = { { code = 0, stdout = '{"a":1}\n200' } }
		res, err = api.get("/x")
	]])
	eq(get("res"), { a = 1 })
	eq(get("err"), vim.NIL)
	eq(get("has_arg(1, 'GET')"), true)
	eq(get("has_arg(1, 'https://leetcode.com/x')"), true)
end

T["sends the cookie and the csrf token"] = function()
	run("api.get('/x')")
	eq(get("has_arg(1, 'Cookie: LEETCODE_SESSION=s; csrftoken=c')"), true)
	eq(get("has_arg(1, 'x-csrftoken: c')"), true)
end

T["posts json through stdin"] = function()
	run([[api.post("/run", { body = { lang = "python3", code = "print(1)" } })]])
	eq(get("has_arg(1, 'POST')"), true)
	eq(get("has_arg(1, '@-')"), true)
	eq(get("vim.json.decode(calls[1].stdin)"), { lang = "python3", code = "print(1)" })
	eq(
		get(
			"vim.iter(calls[1].args):any(function(arg) return arg:find('print', 1, true) ~= nil end)"
		),
		false
	)
end

T["calls back on the main loop"] = function()
	run([[
		replies = { { code = 0, stdout = '{"ok":true}\n200' } }
		api.get("/x", { callback = function(res) result = res; done = true end })
	]])
	settle()
	eq(get("result"), { ok = true })
end

T["reports http errors with their messages"] = function()
	run([[
		replies = { { code = 0, stdout = '{"errors":[{"message":"bad query"}]}\n400' } }
		res, err = api.get("/x")
	]])
	eq(get("err.status"), 400)
	eq(get("err.msg:find('bad query', 1, true) ~= nil"), true)
end

T["explains expired cookies"] = function()
	run([[
		replies = { { code = 0, stdout = '{}\n403' } }
		res, err = api.get("/x")
	]])
	eq(get("err.msg:find('cookie may have expired', 1, true) ~= nil"), true)
end

T["retries server errors"] = function()
	run([[
		replies = { { code = 0, stdout = "{}\n502" }, { code = 0, stdout = '{"ok":1}\n200' } }
		res, err = api.get("/x")
	]])
	eq(get("#calls"), 2)
	eq(get("res"), { ok = 1 })
end

T["retries in the background too"] = function()
	run([[
		replies = { { code = 0, stdout = "{}\n500" }, { code = 0, stdout = '{"ok":2}\n200' } }
		api.get("/x", { callback = function(res) result = res; done = true end })
	]])
	settle()
	eq(get("#calls"), 2)
	eq(get("result"), { ok = 2 })
end

T["gives up after a few retries"] = function()
	run([[
		for i = 1, 10 do replies[i] = { code = 0, stdout = "{}\n503" } end
		res, err = api.get("/x")
	]])
	eq(get("#calls"), 6)
	eq(get("err.status"), 503)
end

T["a failed curl is an error, not a crash"] = function()
	run([[
		replies = { { code = 6, stdout = "", stderr = "Could not resolve host" } }
		ok, res, err = pcall(api.get, "/x")
	]])
	eq(get("ok"), true)
	eq(get("#calls"), 1)
	eq(get("err.msg:find('Could not resolve host', 1, true) ~= nil"), true)
end

T["graphql queries post to the endpoint"] = function()
	run([[
		replies = { { code = 0, stdout = '{"data":{"x":1}}\n200' } }
		res = api.query("query { x }", { a = 1 })
	]])
	eq(get("res.data.x"), 1)
	eq(get("vim.json.decode(calls[1].stdin)"), { query = "query { x }", variables = { a = 1 } })
end

T["storage"] = new_set()

T["storage"]["is plain absolute paths"] = function()
	run([[storage = require("leetcode.config").storage]])
	eq(get("type(storage.home)"), "string")
	eq(get("type(storage.cache)"), "string")
	eq(get("storage.home:sub(1, 1)"), "/")
	eq(get("vim.fn.isdirectory(storage.cache)"), 1)
end

T["storage"]["files read back what was written"] = function()
	run([[
		util = require("leetcode.util")
		path = vim.fs.joinpath(require("leetcode.config").storage.cache, "roundtrip")
		util.write_file(path, "one\ntwo")
	]])
	eq(get("util.read_file(path)"), "one\ntwo")
	eq(get("util.read_file(path .. '.missing')"), vim.NIL)
end

return T
