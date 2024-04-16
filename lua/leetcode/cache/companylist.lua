local path = require("plenary.path")
local companies_api = require("leetcode.api.companies")

local log = require("leetcode.logger")
local config = require("leetcode.config")
local interval = config.user.cache.update_interval

---@type Path
local file = config.storage.cache:joinpath(("companylist%s"):format(config.is_cn and "_cn" or ""))

---@type { at: integer, payload: lc.cache.payload }
local hist = nil

---@class lc.cache.Company
---@field name string
---@field slug string
---@field questionCount number


---@class lc.cache.Copmanylist
local Companylist = {}

---@return lc.cache.Company[]
function Companylist.get()
    return Companylist.read().data
end

---@return lc.cache.payload
function Companylist.read()
    if not file:exists() then
        return Companylist.populate()
    end

    local time = os.time()
    if hist and (time - hist.at) <= math.min(60, interval) then
        return hist.payload
    end

    local contents = file:read()
    if not contents or type(contents) ~= "string" then
        return Companylist.populate()
    end

    local cached = Companylist.parse(contents)

    if not cached or (cached.version ~= config.version or cached.username ~= config.auth.name) then
        return Companylist.populate()
    end

    hist = { at = time, payload = cached }
    if (time - cached.updated_at) > interval then
        Companylist.update()
    end

    return cached
end

---@return lc.cache.payload
function Companylist.populate()
    local res, err = companies_api.all(nil, true)

    if not res or err then
        local msg = (err or {}).msg or "failed to fetch company list"
        error(msg)
    end

    Companylist.write({ data = res })
    return hist.payload
end

function Companylist.update()
    companies_api.all(function(res, err)
        if not err then
            Companylist.write({ data = res })
        end
    end, true)
end

---@return lc.cache.Company
function Companylist.get_by_title_slug(title_slug)
    local companies = Companylist.get()

    local company = vim.tbl_filter(function(e)
        return e.title_slug == slug
    end, companies)[1]

    assert(company("Company `%s` not found. Try updating cache?"):format(title_slug))
    return company
end

---@param payload? lc.cache.payload
function Companylist.write(payload)
    payload = vim.tbl_deep_extend("force", {
        version = config.version,
        updated_at = os.time(),
        username = config.auth.name,
    }, payload)

    if not payload.data then
        payload.data = Companylist.get()
    end

    file:write(vim.json.encode(payload), "w")
    hist = { at = os.time(), payload = payload }
end

---@alias lc.cache.payload { version: string, data: lc.cache.Company[], updated_at: integer, username: string }

---@param str string
---
---@return lc.cache.payload
function Companylist.parse(str)
    return vim.json.decode(str)
end

function Companylist.delete()
    if not file:exists() then
        return false
    end
    return pcall(path.rm, file)
end

return Companylist
