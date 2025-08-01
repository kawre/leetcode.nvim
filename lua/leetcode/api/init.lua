local Cookie = require("leetcode.cache.cookie")
local config = require("leetcode.config")
local urls = require("leetcode.api.urls")
local curl = require("plenary.curl")

---@alias leet.api.method
---| fun(endpoint: string, opts?: table)

---@class leet.api
---@field problems leet.api.problems
---@field queries leet.api.queries
---@field interpreter leet.api.interpreter
---@field post leet.api.method
---@field get leet.api.method
---@field put leet.api.method
---@overload fun(method: string, endpoint: string, opts?: table): any
local M = setmetatable({}, {
    __index = function(t, k)
        if k == "post" or k == "get" or k == "put" then
            t[k] = function(endpoint, opts)
                opts = vim.tbl_extend("keep", opts or {}, { endpoint = endpoint })
                return t(k, endpoint, opts)
            end
        else
            t[k] = require("leetcode.api." .. k)
        end
        return rawget(t, k)
    end,
    __call = function(t, ...)
        return t.curl(...)
    end,
})

local function headers()
    local cookie = Cookie.get()

    return vim.tbl_extend("force", {
        ["User-Agent"] = "Mozilla/5.0 (X11; Linux x86_64; rv:123.0) Gecko/20100101 Firefox/123.0",
        ["Referer"] = ("https://leetcode.%s"):format(config.domain),
        ["Origin"] = ("https://leetcode.%s/"):format(config.domain),
        ["Content-Type"] = "application/json",
        ["Accept"] = "application/json",
        ["Host"] = ("leetcode.%s"):format(config.domain),
        -- ["X-Requested-With"] = "XMLHttpRequest",
    }, cookie and {
        ["Cookie"] = cookie.str,
        ["x-csrftoken"] = cookie.csrftoken,
    } or {})
end

---@param err lc.err
local function check_err(err)
    if not err then
        return
    end

    if err.status then
        if err.status == 401 or err.status == 403 then
            err.msg =
                "Your cookie may have expired, or LeetCode has temporarily restricted API access"
        end
    end

    return err
end

---@private
---@return table, lc.err
local function handle_res(out)
    local res, err
    Markup.log.debug(out)

    if out.exit ~= 0 then
        err = {
            code = out.exit,
            msg = "curl failed",
        }
    elseif out.status >= 300 then
        local ok, msg = pcall(function()
            local dec = vim.json.decode(out.body)

            if dec.error then
                return dec.error
            end

            local tbl = {}
            for _, e in ipairs(dec.errors) do
                table.insert(tbl, e.message)
            end

            return table.concat(tbl, "\n")
        end)

        res = out.body
        err = {
            code = 0,
            status = out.status,
            response = out,
            msg = "http error " .. out.status .. (ok and ("\n\n" .. msg) or ""),
            out = out.body,
        }
    else
        res = vim.json.decode(out.body)
    end

    return res, check_err(err)
end

---@private
---@param method string
---@param params table
function M.curl(method, params)
    local params_cpy = vim.deepcopy(params)

    params = vim.tbl_deep_extend("force", {
        headers = headers(),
        compressed = false,
        retry = 5,
        endpoint = urls.base,
    }, params or {})
    local url = ("https://leetcode.%s%s"):format(config.domain, params.endpoint)

    if type(params.body) == "table" then
        params.body = vim.json.encode(params.body)
    end

    local tries = params.retry
    local function should_retry(err)
        return err and err.status >= 500 and tries > 0
    end

    if params.callback then
        local cb = vim.schedule_wrap(params.callback)
        params.callback = function(out, _)
            local res, err = handle_res(out)

            if should_retry(err) then
                Markup.log.debug("retry " .. tries)
                params_cpy.retry = tries - 1
                M.curl(method, params_cpy)
            else
                cb(res, err)
            end
        end

        curl[method](url, params)
    else
        local out = curl[method](url, params)
        local res, err = handle_res(out)

        if should_retry(err) then
            Markup.log.debug("retry " .. tries)
            params_cpy.retry = tries - 1
            M.curl(method, params_cpy)
        else
            return res, err
        end
    end
end

---@param query string
---@param variables? table optional
---@param opts? { callback?: function, endpoint?: string }
function M.query(query, variables, opts)
    opts = vim.tbl_deep_extend("force", {
        body = { query = query, variables = variables },
    }, opts or {})

    return M.curl("post", opts)
end

function M.normalize_similar_cn(s)
    return vim.tbl_map(function(sq)
        return {
            title = sq.title,
            translated_title = sq.translatedTitle,
            paid_only = sq.isPaidOnly,
            title_slug = sq.titleSlug,
            difficulty = sq.difficulty,
        }
    end, vim.json.decode(s))
end

---@param problems lc.cache.Question[]
---@param titles { questionId: integer, title: string }[]
function M.translate_titles(problems, titles)
    local map = {}
    for _, title in ipairs(titles) do
        map[title.questionId] = title.title
    end

    return vim.tbl_map(function(p)
        local title = map[tostring(p.id)]
        if title then
            p.title_cn = title
        end
        return p
    end, problems)
end

return M
