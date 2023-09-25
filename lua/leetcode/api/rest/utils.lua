local log = require("leetcode.logger")
local curl = require("plenary.curl")
local headers = require("leetcode.api.headers")
local Job = require("plenary.job")
local api_utils = require("leetcode.api.utils")

local utils = {}

---@param url string
function utils.post(url, body)
    local response = curl.post(url, {
        headers = headers.get(),
        body = vim.json.encode(body),
    })

    local ok, data = pcall(vim.json.decode, response.body)
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
    local args = { url, api_utils.to_curl_headers() }

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

return utils
