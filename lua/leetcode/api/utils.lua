local curl = require("plenary.curl")
local log = require("leetcode.logger")
local config = require("leetcode.config")
local headers = require("leetcode.api.headers")

local lc = "https://leetcode." .. config.user.domain
local endpoint = lc .. "/graphql"

---@class lc.Api.Utils
local utils = {}

---@param url string
function utils.post(url, body)
    return utils.curl("post", url, {
        body = body,
    })
end

function utils.get(url, cb)
    return utils.curl("get", url, {
        callback = cb,
    })
end

---@param query string
---@param variables? table optional
---@param cb? function optional
function utils.query(query, variables, cb)
    local body = {
        query = query,
        variables = variables,
    }

    return utils.curl("post", endpoint, {
        body = body,
        callback = cb,
    })
end

---@private
function utils.curl(method, url, params)
    local params_cpy = vim.deepcopy(params)
    params = vim.tbl_deep_extend("force", {
        headers = headers.get(),
        compressed = false,
        retry = 5,
    }, params or {})

    if type(params.body) == "table" then params.body = vim.json.encode(params.body) end

    local tries = params.retry
    if params.callback then
        local cb = vim.schedule_wrap(params.callback)
        params.callback = function(out, _)
            local res, err = utils.handle_res(out)

            if err and tries > 0 then
                params_cpy.retry = tries - 1
                utils.curl(method, url, params_cpy)
            else
                cb(res, err)
            end
        end

        curl[method](url, params)
    else
        local res, err

        repeat
            local out = curl[method](url, params)
            res, err = utils.handle_res(out)
            tries = tries - 1
        until not (res and not err) or tries > 0

        return res, err
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

    -- if err then log.debug(err) end
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

return utils
