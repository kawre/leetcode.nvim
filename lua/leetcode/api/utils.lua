local curl = require("plenary.curl")
local log = require("leetcode.logger")
local config = require("leetcode.config")
local headers = require("leetcode.api.headers")
local urls = require("leetcode.api.urls")

---@class lc.Api.Utils
local utils = {}

---@param endpoint string
function utils.post(endpoint, body)
    return utils.curl("post", {
        endpoint = endpoint,
        body = body,
    })
end

function utils.get(endpoint, cb)
    return utils.curl("get", {
        endpoint = endpoint,
        callback = cb,
    })
end

---@param query string
---@param variables? table optional
---@param opts? { callback?: function }
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
    }, params or {})
    local url = config.domain .. params.endpoint

    if type(params.body) == "table" then params.body = vim.json.encode(params.body) end

    local tries = params.retry
    local function should_retry(err) return err and err.status >= 500 and tries > 0 end

    if params.callback then
        local cb = vim.schedule_wrap(params.callback)
        params.callback = function(out, _)
            local res, err = utils.handle_res(out)

            if should_retry(err) then
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
            params_cpy.retry = tries - 1
            utils.curl(method, params_cpy)
        else
            return res, err
        end
    end
end

---@private
---@return table|nil, lc.err|nil
function utils.handle_res(out)
    log.debug(out)
    local res, err

    if out.exit ~= 0 then
        err = {
            code = out.exit,
            err = "curl failed",
        }
    elseif out.status >= 300 then
        res = out.body
        err = {
            code = 0,
            status = out.status,
            response = out,
            out = out.body,
        }
    else
        res = utils.decode(out.body)
    end

    return res, err
end

function utils.decode(str)
    local ok, res = pcall(vim.json.decode, str)
    assert(ok, str)
    return res
end

---@private
function utils.auth_guard()
    local auth = require("leetcode.config").auth
    assert(auth and auth.is_signed_in, "User not signed in")
end

function utils.normalize_similar_cn(s)
    -- if type(s) ~= "string" then return s end

    s = select(2, pcall(utils.decode, s))

    return vim.tbl_map(function(sq)
        sq.title = sq.translatedTitle
        sq.paid_only = sq.isPaidOnly
        sq.title_slug = sq.titleSlug
        return sq
    end, s)
end

function utils.lvl_to_name(lvl) return ({ "Easy", "Medium", "Hard" })[lvl] end

---@return lc.Cache.Question[]
function utils.normalize_problems(problems)
    problems = vim.tbl_filter(function(p) return not p.stat.question__hide end, problems)

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

    return vim.tbl_map(
        function(p)
            return {
                status = p.status,
                id = p.stat.question_id,
                frontend_id = p.stat.frontend_question_id,
                title = p.stat.question__title,
                title_cn = "",
                title_slug = p.stat.question__title_slug,
                link = ("%s/problems/%s/"):format(config.domain, p.stat.question__title_slug),
                paid_only = p.paid_only,
                ac_rate = p.stat.total_acs * 100 / p.stat.total_submitted,
                difficulty = utils.lvl_to_name(p.difficulty.level),
                starred = p.is_favor,
                topic_tags = {},
            }
        end,
        problems
    )
end

---@param problems lc.Cache.Question[]
---@param titles { questionId: integer, title: string }[]
function utils.translate_titles(problems, titles)
    local map = {}
    for _, t in ipairs(titles) do
        map[t.questionId] = t.title
    end

    return vim.tbl_map(function(p)
        local title = map[tostring(p.id)]
        if title then p.title_cn = title end
        return p
    end, problems)
end

return utils
