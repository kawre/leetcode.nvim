local path = require("plenary.path")
local problems_api = require("leetcode.api.problems")

local log = require("leetcode.logger")
local config = require("leetcode.config")
local interval = config.user.cache.update_interval

---@type Path
local file = config.storage.cache:joinpath(("problemlist%s"):format(config.is_cn and "_cn" or ""))

---@type { at: integer, payload: lc.cache.payload }
local hist = nil

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
    return Problemlist.read().data
end

---@return lc.cache.payload
function Problemlist.read()
    if not file:exists() then
        return Problemlist.populate()
    end

    local time = os.time()
    if hist and (time - hist.at) <= math.min(60, interval) then
        return hist.payload
    end

    local contents = file:read()
    if not contents or type(contents) ~= "string" then
        return Problemlist.populate()
    end

    local cached = Problemlist.parse(contents)

    if not cached or (cached.version ~= config.version or cached.username ~= config.auth.name) then
        return Problemlist.populate()
    end

    hist = { at = time, payload = cached }
    if (time - cached.updated_at) > interval then
        Problemlist.update()
    end

    return cached
end

---@return lc.cache.payload
function Problemlist.populate()
    local res, err = problems_api.all(nil, true)

    if not res or err then
        local msg = (err or {}).msg or "failed to fetch problem list"
        error(msg)
    end

    Problemlist.write({ data = res })
    return hist.payload
end

function Problemlist.update()
    problems_api.all(function(res, err)
        if not err then
            Problemlist.write({ data = res })
        end
    end, true)
end

---@return lc.cache.Question
function Problemlist.get_by_title_slug(title_slug)
    local problems = Problemlist.get()

    local problem = vim.tbl_filter(function(e)
        return e.title_slug == title_slug
    end, problems)[1]

    assert(problem, ("Problem `%s` not found. Try updating cache?"):format(title_slug))
    return problem
end

---@param payload? lc.cache.payload
function Problemlist.write(payload)
    payload = vim.tbl_deep_extend("force", {
        version = config.version,
        updated_at = os.time(),
        username = config.auth.name,
    }, payload)

    if not payload.data then
        payload.data = Problemlist.get()
    end

    file:write(vim.json.encode(payload), "w")
    hist = { at = os.time(), payload = payload }
end

---@alias lc.cache.payload { version: string, data: lc.cache.Question[], updated_at: integer, username: string }

---@param str string
---
---@return lc.cache.payload
function Problemlist.parse(str)
    return vim.json.decode(str)
end

---@param title_slug string
---@param status "ac" | "notac"
Problemlist.change_status = vim.schedule_wrap(function(title_slug, status)
    local cached = Problemlist.read()

    cached.data = vim.tbl_map(function(p)
        if p.title_slug == title_slug then
            p.status = status
        end
        return p
    end, cached.data)

    Problemlist.write(cached)
end)

function Problemlist.delete()
    if not file:exists() then
        return false
    end
    return pcall(path.rm, file)
end

---@class lc.filter.CustomList
---@field problems { id: string, tags: string[] }[] List of problem definitions
---@field source string Source file path
local function parse_custom_list(filepath)
    local expanded_path = vim.fn.expand(filepath)
    
    -- Check file existence 
    if not vim.fn.filereadable(expanded_path) then
        error(("File does not exist or is not readable: %s"):format(expanded_path))
    end

    local file = io.open(expanded_path, "r")
    if not file then
        error(("Cannot open custom filter file: %s"):format(filepath))
    end

    local problems = {}
    local file_ext = filepath:match("%.([^%.]+)$")
    
    if file_ext == "json" then
        local content = file:read("*all")
        file:close()
        
        local ok, decoded = pcall(vim.json.decode, content)
        if not ok then
            error(("Invalid JSON in file: %s"):format(filepath))
        end
        
        -- Support both simple arrays and structured format
        if type(decoded) == "table" then
            if decoded[1] then -- Simple array format
                for _, item in ipairs(decoded) do
                    problems[#problems + 1] = {
                        id = tostring(item),
                        tags = {}
                    }
                end
            else -- Structured format
                for group, items in pairs(decoded) do
                    for _, item in ipairs(items) do
                        problems[#problems + 1] = {
                            id = tostring(item),
                            tags = { group }
                        }
                    end
                end
            end
        end
    else -- Assume text file
        for line in file:lines() do
            line = line:match("^%s*(.-)%s*$")
            if line ~= "" and not line:match("^#") then
                local id, tags = line:match("([^|]+)|?(.*)")
                if id then
                    problems[#problems + 1] = {
                        id = id:match("^%s*(.-)%s*$"),
                        tags = vim.split(tags, ",")
                    }
                end
            end
        end
        file:close()
    end

    return {
        problems = problems,
        source = filepath
    }
end

---@param problems lc.cache.Question[]
---@param custom_list lc.filter.CustomList
---@param options lc.filter.Options
---@return lc.cache.Question[]
local function filter_by_custom_list(problems, custom_list, options)
    local filtered = {}
    local problem_map = {}
    
    -- Create lookup maps for both title slugs and problem IDs
    for _, problem in ipairs(problems) do
        problem_map[problem.title_slug] = problem
        problem_map[problem.frontend_id] = problem
    end

    -- Filter problems based on the custom list
    for _, item in ipairs(custom_list.problems) do
        local problem = problem_map[item.id]
        if problem then
            -- Apply additional filters if specified
            if options then
                local matches = true
                
                -- Apply difficulty filter
                if options.difficulty and problem.difficulty ~= options.difficulty then
                    matches = false
                end
                
                -- Apply status filter
                if matches and options.status and options.status ~= "any" then
                    if options.status == "ac" and problem.status ~= "ac" then
                        matches = false
                    elseif options.status == "notac" and problem.status == "ac" then
                        matches = false
                    end
                end
                
                if matches then
                    table.insert(filtered, problem)
                end
            else
                table.insert(filtered, problem)
            end
        end
    end

    return filtered
end

---@param filepath string Path to custom filter file
---@param options? lc.filter.Options Additional filters to apply
---@return lc.cache.Question[]
function Problemlist.filter_by_file(filepath, options)
    local problems = Problemlist.get()
    local custom_list = parse_custom_list(filepath)
    return filter_by_custom_list(problems, custom_list, options)
end

return Problemlist
