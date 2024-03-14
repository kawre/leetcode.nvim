local curl = require("plenary.curl")
local log = require("leetcode.logger")
local config = require("leetcode.config")
local headers = require("leetcode.api.headers")
local urls = require("leetcode.api.urls")

---@class lc.Api.Utils
local utils = {}

---@param endpoint string
function utils.put(endpoint, opts)
    local options = vim.tbl_deep_extend("force", {
        endpoint = endpoint,
    }, opts or {})

    return utils.curl("put", options)
end

---@param endpoint string
function utils.post(endpoint, opts)
    local options = vim.tbl_deep_extend("force", {
        endpoint = endpoint,
    }, opts or {})

    return utils.curl("post", options)
end

---@param endpoint string
---@param opts? table
function utils.get(endpoint, opts)
    local options = vim.tbl_deep_extend("force", {
        endpoint = endpoint,
    }, opts or {})

    return utils.curl("get", options)
end

---@param query string
---@param variables? table optional
---@param opts? { callback?: function, endpoint?: string }
function utils.query(query, variables, opts)
    opts = vim.tbl_deep_extend("force", {
        body = {
            query = query,
            variables = variables,
        },
    }, opts or {})

    return utils.curl("post", opts)
end

---@private
---@param method string
---@param params table
function utils.curl(method, params)
    local params_cpy = vim.deepcopy(params)

    params = vim.tbl_deep_extend("force", {
        headers = headers.get(),
        compressed = false,
        retry = 5,
        endpoint = urls.base,
        http_version = "HTTP/2",
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
            local res, err = utils.handle_res(out)

            if should_retry(err) then
                log.debug("retry " .. tries)
                params_cpy.retry = tries - 1
                utils.curl(method, params_cpy)
            else
                cb(res, err)
            end
        end

        curl[method](url, params)
    else
        local out = curl[method](url, params)
        local res, err = utils.handle_res(out)

        if should_retry(err) then
            log.debug("retry " .. tries)
            params_cpy.retry = tries - 1
            utils.curl(method, params_cpy)
        else
            return res, err
        end
    end
end

---@private
---@return table, lc.err
function utils.handle_res(out)
    local res, err
    log.debug(out)

    if out.exit ~= 0 then
        err = {
            code = out.exit,
            msg = "curl failed",
        }
    elseif out.status >= 300 then
        local ok, msg = pcall(function()
            local dec = utils.decode(out.body)

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
        res = utils.decode(out.body)
    end

    return res, utils.check_err(err)
end

---@param err lc.err
function utils.check_err(err)
    if not err then
        return
    end

    if err.status then
        if err.status == 401 or err.status == 403 then
            require("leetcode.command").expire()
            err.msg = "Session expired? Enter a new cookie to keep using `leetcode.nvim`"
        end
    end

    return err
end

function utils.decode(str)
    return vim.json.decode(str)
    -- local ok, res = pcall(vim.json.decode, str)
    -- assert(ok, str)
    -- return res
end

function utils.normalize_similar_cn(s)
    s = select(2, pcall(utils.decode, s))

    return vim.tbl_map(function(sq)
        return {
            title = sq.title,
            translated_title = sq.translatedTitle,
            paid_only = sq.isPaidOnly,
            title_slug = sq.titleSlug,
            difficulty = sq.difficulty,
        }
    end, s)
end

function utils.lvl_to_name(lvl)
    return ({ "Easy", "Medium", "Hard" })[lvl]
end

---@return lc.cache.Question[]
function utils.normalize_problems(problems)
    problems = vim.tbl_filter(function(p)
        return not p.stat.question__hide
    end, problems)

    local comp = function(a, b)
        local a_fid = a.stat.frontend_question_id
        local b_fid = b.stat.frontend_question_id

        local is_num_a = tonumber(a_fid)
        local is_num_b = tonumber(b_fid)

        if is_num_a and is_num_b then
            return tonumber(a_fid) < tonumber(b_fid)
        elseif is_num_a then
            return true
        elseif is_num_b then
            return false
        else
            return a_fid < b_fid
        end
    end
    table.sort(problems, comp)

    return vim.tbl_map(function(p)
        return {
            status = p.status,
            id = p.stat.question_id,
            frontend_id = p.stat.frontend_question_id,
            title = p.stat.question__title,
            title_cn = "",
            title_slug = p.stat.question__title_slug,
            link = ("https://leetcode.%s/problems/%s/"):format(
                config.domain,
                p.stat.question__title_slug
            ),
            paid_only = p.paid_only,
            ac_rate = p.stat.total_acs * 100 / math.max(p.stat.total_submitted, 1),
            difficulty = utils.lvl_to_name(p.difficulty.level),
            starred = p.is_favor,
            topic_tags = {},
        }
    end, problems)
end

---@param problems lc.cache.Question[]
---@param titles { questionId: integer, title: string }[]
function utils.translate_titles(problems, titles)
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

return utils
