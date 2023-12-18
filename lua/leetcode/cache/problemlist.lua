local path = require("plenary.path")

local config = require("leetcode.config")

---@type Path
local file = config.home:joinpath((".problemlist%s"):format(config.is_cn and "_cn" or ""))

local hist = {}

local problems_api = require("leetcode.api.problems")

---@class lc.cache.Question
---@field id integer
---@field frontend_id string
---@field link string
---@field title string
---@field title_cn string
---@field title_slug string
---@field status string
---@field paid_only boolean
---@field ac_rate number
---@field difficulty "Easy" | "Medium" | "Hard"
---@field topic_tags { name:string, slug: string }

---@class lc.cache.Problemlist
local Problemlist = {}

---@return lc.cache.Question[]
function Problemlist.get()
    if not file:exists() then return Problemlist.populate() end

    local contents = file:read()
    if not contents or type(contents) ~= "string" then return Problemlist.populate() end

    local cached = Problemlist.parse(contents)
    if --
        not cached
        or cached.version ~= config.version
        or cached.username ~= config.auth.name
    then
        return Problemlist.populate()
    end

    if (os.time() - cached.updated_at) > config.user.cache.update_interval then
        Problemlist.update()
    end

    local hproblem = hist[cached.updated_at]
    if hproblem then return hproblem end

    hist[cached.updated_at] = cached.data
    return cached.data
end

function Problemlist.populate()
    local res, err = problems_api.all(nil, true)
    if not res or err then
        local msg = (err or {}).msg or "failed to fetch problem list"
        error(msg)
    end

    Problemlist.write(res)
    return res
end

function Problemlist.update()
    problems_api.all(function(res, err)
        if not err then Problemlist.write(res) end
    end, true)
end

---@return lc.cache.Question
function Problemlist.get_by_title_slug(title_slug)
    local problems = Problemlist.get()

    local problem = vim.tbl_filter(function(e) return e.title_slug == title_slug end, problems)[1]

    assert(problem, ("Problem `%s` not found. Try updating cache?"):format(title_slug))
    return problem
end

---@param problems table
function Problemlist.write(problems)
    local payload = {
        version = config.version,
        updated_at = os.time(),
        username = config.auth.name,
        data = problems,
    }

    file:write(vim.json.encode(payload), "w")
    hist[payload.updated_at] = problems
end

---@param str string
---
---@return { version: string, data: lc.cache.Question[], updated_at: integer, username: string }
function Problemlist.parse(str)
    return vim.json.decode(str) ---@diagnostic disable-line
end

---@param title_slug string
---@param status "ac" | "notac"
Problemlist.change_status = vim.schedule_wrap(function(title_slug, status)
    local problist = Problemlist.get()

    Problemlist.write(vim.tbl_map(function(p)
        if p.title_slug == title_slug then p.status = status end
        return p
    end, problist))
end)

function Problemlist.delete()
    if not file:exists() then return false end
    return pcall(path.rm, file)
end

return Problemlist
