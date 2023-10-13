local path = require("plenary.path")
local log = require("leetcode.logger")

local config = require("leetcode.config")
local file = config.home:joinpath(".problemlist")

local problems_api = require("leetcode.api.problems")

---@class lc.Cache.Question
---@field frontend_id string
---@field title string
---@field title_slug string
---@field status string
---@field paid_only boolean
---@field ac_rate number
---@field difficulty "Easy" | "Medium" | "Hard"
local problemlist = {}

local function populate()
    local spinner = require("leetcode.logger.spinner")

    local noti = spinner:init("Fetching Problem List", "points")
    local data = problems_api.all()
    problemlist.write(data)
    noti:stop("Problems Cache Updated!")
end

---@param data string|table
function problemlist.write(data)
    local str

    if type(data) == "table" then
        local ok, dec = pcall(vim.json.encode, data)
        assert(ok, dec)
        str = dec
    else
        str = data
    end

    file:write(str, "w")
end

---@return lc.Cache.Question[]
function problemlist.get()
    problemlist.update()

    local r_ok, contents = pcall(path.read, file)
    assert(r_ok)

    local ok, problems = pcall(problemlist.parse, contents)
    assert(ok)

    return problems
end

---@param force? boolean
function problemlist.update(force)
    local stats = file:_stat()
    if vim.tbl_isempty(stats) then return populate() end

    local mod_time = stats.mtime.sec
    local curr_time = os.time()

    if force or (curr_time - mod_time) > 60 * 60 * 24 * 7 then
        local spinner = require("leetcode.logger.spinner")
        local noti = spinner:init("Fetching Problem List", "points")

        problems_api._all(function(data)
            problemlist.write(data)
            noti:stop("Problems Cache Updated!")
        end)
    end
end

function problemlist.get_by_title_slug(title_slug)
    local problems = problemlist.get()
    return vim.tbl_filter(function(e) return e.title_slug == title_slug end, problems)[1]
end

---@param problems_str string
---
---@return lc.Cache.Question[]
function problemlist.parse(problems_str)
    ---@type boolean, lc.Cache.Question[]
    local ok, problems = pcall(vim.json.decode, problems_str)
    assert(ok, "Failed to parse problems")

    return problems
end

---@param title_slug string
---@param status "ac" | "notac"
function problemlist.change_status(title_slug, status)
    local problist = problemlist.get()

    vim.tbl_map(function(p)
        if p.title_slug == title_slug then p.status = status end
        return p
    end, problist)

    problemlist.write(problist)
end

function problemlist.delete() file:rm() end

return problemlist
