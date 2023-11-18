local path = require("plenary.path")
local log = require("leetcode.logger")

local config = require("leetcode.config")
---@type Path
local file = config.home:joinpath((".problemlist%s"):format(config.is_cn and "_cn" or ""))

local hist = {}

local problems_api = require("leetcode.api.problems")

---@class lc.Cache.Question.topicTags
---@field name string
---@field slug string

---@class lc.Cache.Question
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
---@field topic_tags lc.Cache.Question.topicTags[]

---@class lc.cache.Problemlist
local Problemlist = {}

---@return lc.Cache.Question[]
function Problemlist.get()
    if not file:exists() then return Problemlist.populate() end

    local fstats = file:_stat()
    local ftime = fstats.mtime.sec
    local curr_time = os.time()

    if (curr_time - ftime) > config.user.cache.update_interval then Problemlist.update() end

    local hproblem = hist[ftime]
    if hproblem then return hproblem end

    local contents = file:read()
    if not contents or type(contents) ~= "string" then return Problemlist.populate() end

    local cached = Problemlist.parse(contents)
    if not cached or cached.version ~= config.version then return Problemlist.populate() end

    hist[ftime] = cached.data
    return cached.data
end

function Problemlist.populate()
    local spinner = require("leetcode.logger.spinner")
    local noti = spinner:init("fetching problem list", "points")

    local data = problems_api.all()
    noti:stop("problems cache updated")

    Problemlist.write(data)
    return data
end

function Problemlist.update()
    local spinner = require("leetcode.logger.spinner")
    local noti = spinner:init("fetching problemlist", "points")

    problems_api.all(function(data)
        Problemlist.write(data)
        noti:stop("problems cache updated!")
    end)
end

---@return lc.Cache.Question
function Problemlist.get_by_title_slug(title_slug)
    local problems = Problemlist.get()
    return vim.tbl_filter(function(e) return e.title_slug == title_slug end, problems)[1] or {}
end

---@param problems table
function Problemlist.write(problems)
    local tbl = {
        version = config.version,
        data = problems,
    }

    file:write(vim.json.encode(tbl), "w")

    local ftime = file:_stat().mtime.sec
    hist[ftime] = problems
end

---@param str string
---
---@return { version: string, data: lc.Cache.Question[] }
function Problemlist.parse(str)
    return vim.json.decode(str) ---@diagnostic disable-line
end

---@param title_slug string
---@param status "ac" | "notac"
function Problemlist.change_status(title_slug, status)
    local problist = Problemlist.get()

    Problemlist.write(vim.tbl_map(function(p)
        if p.title_slug == title_slug then p.status = status end
        return p
    end, problist))
end

function Problemlist.delete()
    if not file:exists() then return false end
    return pcall(path.rm, file)
end

return Problemlist
