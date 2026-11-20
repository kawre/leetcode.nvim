-- Merges the LuaCov stats of every Neovim a test run started into one LCOV
-- report, and prints a summary of it.
--
--   nvim -l scripts/coverage.lua
--
-- Writes `.tests/coverage/lua.lcov` with paths relative to the repository,
-- and fails when the total is below `COVERAGE_MIN` percent.
--

local dir = ".tests/coverage"
local tree = vim.fn.getcwd() .. "/.tests/rocks"
package.path = ("%s/share/lua/5.1/?.lua;%s/share/lua/5.1/?/init.lua;"):format(tree, tree)
    .. package.path
-- cluacov, LuaCov's hook in C, when it is there: several times faster.
package.cpath = ("%s/lib/lua/5.1/?.so;"):format(tree) .. package.cpath

local runner = require("luacov.runner")
local stats = require("luacov.stats")

local root = vim.fn.getcwd() .. "/"
local merged = {}
local parts = vim.fn.glob(dir .. "/luacov.stats.*.out", false, true)
if #parts == 0 then
    io.stderr:write("no coverage stats in " .. dir .. ", run `make coverage` first\n")
    os.exit(1)
end
for _, part in ipairs(parts) do
    for name, data in pairs(stats.load(part) or {}) do
        -- Paths as the repository has them, the same on every machine.
        name = name:gsub("^@", "")
        if name:sub(1, #root) == root then
            name = name:sub(#root + 1)
        end
        if merged[name] then
            runner.update_stats(merged[name], data)
        else
            merged[name] = data
        end
    end
end

-- Files no test loads count as not covered, rather than not exist.
for name, kind in vim.fs.dir("lua/leetcode", { depth = math.huge }) do
    local path = "lua/leetcode/" .. name
    if kind == "file" and name:match("%.lua$") and not merged[path] then
        merged[path] = { max = 0, max_hits = 0 }
    end
end

local statsfile = dir .. "/luacov.stats.out"
stats.save(statsfile, merged)

runner.load_config({
    statsfile = statsfile,
    reportfile = dir .. "/lua.lcov",
    include = { "^lua/leetcode/" },
    reporter = "lcov",
})
local reporter = require("luacov.reporter.lcov")
reporter.report()

-- A summary from the report: hit and found lines per file and in total.
local found, hit, files = 0, 0, {}
local file
for line in io.lines(dir .. "/lua.lcov") do
    local sf = line:match("^SF:(.*)")
    if sf then
        file = { name = sf, found = 0, hit = 0 }
        files[#files + 1] = file
    end
    local count = line:match("^DA:%d+,(%d+)")
    if count then
        file.found = file.found + 1
        file.hit = file.hit + (tonumber(count) > 0 and 1 or 0)
    end
end
for _, f in ipairs(files) do
    found, hit = found + f.found, hit + f.hit
end
table.sort(files, function(a, b)
    return a.name < b.name
end)
local function pct(h, f)
    return f == 0 and 100 or h / f * 100
end
for _, f in ipairs(files) do
    print(("%6.1f%%  %5d/%-5d  %s"):format(pct(f.hit, f.found), f.hit, f.found, f.name))
end
print(("%6.1f%%  %5d/%-5d  total"):format(pct(hit, found), hit, found))

local min = tonumber(vim.env.COVERAGE_MIN or "")
if min and pct(hit, found) < min then
    io.stderr:write(("Lua coverage %.1f%% is below %d%%\n"):format(pct(hit, found), min))
    os.exit(1)
end
