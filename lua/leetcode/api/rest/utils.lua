local log = require("leetcode.logger")
local curl = require("plenary.curl")
local headers = require("leetcode.api.headers")

local utils = {}

---@param url string
function utils.post(url, body)
    local response = curl.post(url, {
        headers = headers.get(),
        body = vim.json.encode(body),
    })

    local ok, data = pcall(vim.json.decode, response["body"])
    assert(ok, "Failed to fetch")

    return data
end

---@return table
function utils.get(url)
    local response = curl.get(url)

    local ok, data = pcall(vim.json.decode, response["body"])
    assert(ok, "Failed to fetch")

    return data
end

return utils
