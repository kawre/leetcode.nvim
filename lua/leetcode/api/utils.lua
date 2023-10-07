local curl = require("plenary.curl")
local Job = require("plenary.job")
local log = require("leetcode.logger")
local config = require("leetcode.config")
local headers = require("leetcode.api.headers")

local lc = "https://leetcode." .. config.user.domain
local endpoint = lc .. "/graphql"

local utils = {}

function utils.to_curl_headers()
    local t = {}

    for key, value in pairs(headers.get()) do
        table.insert(t, "-H")
        table.insert(t, key .. ": " .. value)
    end

    return unpack(t)
end

---@param url string
function utils.post(url, body)
    local response = curl.post(url, {
        headers = headers.get(),
        body = vim.json.encode(body),
    })

    local ok, data = pcall(vim.json.decode, response.body)
    if response.status == 429 then log.warn("You have attempted to run code too soon") end
    assert(ok, "Failed to fetch")

    return data
end

---@return table
function utils.get(url)
    local response = curl.get(url)

    local ok, data = pcall(vim.json.decode, response.body)
    assert(ok, "Failed to fetch")

    return data
end

---@param url string
---@param cb function
function utils._get(url, cb)
    local args = { url, utils.to_curl_headers() }

    Job:new({
        command = "curl",
        args = args,
        on_exit = vim.schedule_wrap(function(self, val)
            local result = table.concat(self:result(), "\n")
            local decoded = vim.json.decode(result)
            cb(decoded)
        end),
        on_stderr = function(error, data, self) end,
    }):start()
end

---@param query string
---@param variables? table optional
--@param callback? function optional
---
---@return table
function utils.query(query, variables)
    local response = curl.post(endpoint, {
        headers = headers.get(),
        body = vim.json.encode({
            query = query,
            variables = variables or {},
        }),
    })

    local ok, data = pcall(vim.json.decode, response["body"])
    if not ok then log.error(data) end
    assert(ok and data and data["data"], "Failed to query data")
    return data.data
end

---@param body table
---@param cb function
function utils._query(body, cb)
    curl.post(endpoint, {
        headers = headers.get(),
        body = vim.json.encode(body),
        callback = vim.schedule_wrap(cb),
    })
end

function utils.auth_guard()
    local auth = require("leetcode.config").auth
    assert(auth and auth.is_signed_in, "User not signed in")
end

return utils
