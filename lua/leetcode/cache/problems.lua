---@mod lc.cache.problems

local log = require("leetcode.logger")

local config = require("leetcode.config")
local path = require("plenary.path")
local file = path:new(config.user.directory .. "/.problemlist")

---@class lc.Problem
---@field frontend_id string
---@field title string
---@field title_slug string
---@field status string
---@field paid_only boolean
---@field ac_rate number
---@field difficulty "Easy" | "Medium" | "Hard"
local Problems = {}

local function populate()
    local spinner = require("leetcode.logger.spinner")
    local noti = spinner:init("Fetching Problem List", "points")

    local cb = function(data)
        file:write(vim.json.encode(data), "w")
        -- config.cache.problems = data

        noti:done("Problem List Cache Updated!")
    end

    require("leetcode.api.problems")._all(cb)
end

---@return lc.Problem[]
function Problems.get()
    Problems.update()

    local r_ok, contents = pcall(path.read, file)
    assert(r_ok)
    -- if not r_ok then return end

    local ok, problems = pcall(Problems.parse, contents)
    assert(ok)
    -- if not ok then return end

    return problems
end

---@param force? boolean
function Problems.update(force)
    if force then return populate() end

    local stats = file:_stat()

    if vim.tbl_isempty(stats) then return populate() end

    local mod_time = stats.mtime.sec
    local curr_time = os.time()

    if (curr_time - mod_time) > 60 * 60 * 24 * 7 then return populate() end
end

function Problems.get_by_title_slug(title_slug)
    local problems = Problems.get()

    for _, p in ipairs(problems or {}) do
        if p.title_slug == title_slug then return p end
    end

    return nil
end

---@param problems_str string
---
---@return lc.Problem[]
function Problems.parse(problems_str)
    ---@type boolean, lc.Problem[]
    local ok, problems = pcall(vim.json.decode, problems_str)
    assert(ok, "Failed to parse problems")

    return problems
end

return Problems
