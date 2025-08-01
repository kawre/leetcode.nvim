local path = require("plenary.path")
local problems_api = require("leetcode.api.problems")

local log = require("leetcode.logger")
local config = require("leetcode.config")
local interval = config.user.cache.update_interval

---@type Path
local file = config.storage.cache:joinpath(("problemlist%s"):format(config.is_cn and "_cn" or ""))

---@type { at: integer, payload: lc.cache.payload }
local hist = nil

---@class leet.cache.problem
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

---@class leet.cache.problems
local M = {}

---@return leet.cache.problem[]
function M.get()
    return M.read().data
end

---@return lc.cache.payload
function M.read()
    if not file:exists() then
        return M.populate()
    end

    local time = os.time()
    if hist and (time - hist.at) <= math.min(60, interval) then
        return hist.payload
    end

    local contents = file:read()
    if not contents or type(contents) ~= "string" then
        return M.populate()
    end

    local cached = M.parse(contents)

    if not cached or (cached.version ~= config.version or cached.username ~= config.auth.name) then
        return M.populate()
    end

    hist = { at = time, payload = cached }
    if (time - cached.updated_at) > interval then
        M.update()
    end

    return cached
end

---@return lc.cache.payload
function M.populate()
    local res, err = problems_api.all(nil, true)

    if not res or err then
        local msg = (err or {}).msg or "failed to fetch problem list"
        error(msg)
    end

    M.write({ data = res })
    return hist.payload
end

function M.update()
    problems_api.all(function(res, err)
        if not err then
            M.write({ data = res })
        end
    end, true)
end

---@return leet.cache.problem
function M.by_slug(slug)
    local problems = M.get()

    local problem = vim.tbl_filter(function(e)
        return e.title_slug == slug
    end, problems)[1]

    assert(problem, ("Problem `%s` not found. Try updating cache?"):format(slug))
    return problem
end

---@param payload? lc.cache.payload
function M.write(payload)
    payload = vim.tbl_deep_extend("force", {
        version = config.version,
        updated_at = os.time(),
        username = config.auth.name,
    }, payload)

    if not payload.data then
        payload.data = M.get()
    end

    file:write(vim.json.encode(payload), "w")
    hist = { at = os.time(), payload = payload }
end

---@alias lc.cache.payload { version: string, data: leet.cache.problem[], updated_at: integer, username: string }

---@param str string
---
---@return lc.cache.payload
function M.parse(str)
    return vim.json.decode(str)
end

---@param title_slug string
---@param status "ac" | "notac"
M.change_status = vim.schedule_wrap(function(title_slug, status)
    local cached = M.read()

    cached.data = vim.tbl_map(function(p)
        if p.title_slug == title_slug then
            p.status = status
        end
        return p
    end, cached.data)

    M.write(cached)
end)

function M.delete()
    if not file:exists() then
        return false
    end
    return pcall(path.rm, file)
end

return M
