local Object = require("nui.object")
local config = require("leetcode.config")
local log = require("leetcode.logger")

---@alias lc.recent table<string, integer>

---@type Path
local file = config.storage.cache:joinpath(("recent%s"):format(config.is_cn and "_cn" or ""))

---@class lc.Recent
local Recent = Object("LeetRecent")

function Recent.populate()
    Recent.write({})
end

---@param recent lc.recent|string
function Recent.write(recent)
    file:write("return " .. vim.inspect(recent), "w")
end

---@return lc.recent
function Recent.get()
    if not file:exists() then
        Recent.populate()
    end

    local content = file:read()
    local chunk = load(content)
    return chunk()
end

---@return { slug: string, time: integer }[]
function Recent.sorted()
    local recent = Recent.get()

    local sorted = {}
    for slug, time in pairs(recent) do
        table.insert(sorted, { slug = slug, time = time })
    end

    table.sort(sorted, function(a, b)
        return a.time > b.time
    end)

    return sorted
end

function Recent.convert()
    local map = require("leetcode.cache.problemlist").get_map()
    local sorted = Recent.sorted()

    local recent = {}
    for _, item in ipairs(sorted) do
        if map[item.slug] then
            table.insert(recent, map[item.slug])
        end
    end
    return recent
end

---@param slug string
---@param recent? lc.recent
function Recent.contains(slug, recent)
    if not recent then
        recent = Recent.get()
    end

    return recent[slug] == true
end

function Recent.add(slug)
    local recent = Recent.get()

    recent[slug] = os.time()
    Recent.write(recent)

    return true
end

function Recent.remove(slug)
    local recent = Recent.get()

    local tmp = recent[slug]
    recent[slug] = nil

    Recent.write(recent)
    return tmp
end

return Recent
