local log = require("leetcode.logger")
local curl = require("plenary.curl")
local headers = require("leetcode.api.headers")
local Job = require("plenary.job")

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

local function to_headers()
    local t = {}

    for key, value in pairs(headers.get()) do
        table.insert(t, "-H")
        table.insert(t, key .. ": " .. value)
    end

    return unpack(t)
end

---@param url string
---@param cb function
function utils._get(url, cb)
    local args = { url, to_headers() }

    Job:new({
        command = "curl",
        args = args,
        on_exit = function(self, val)
            local result = table.concat(self:result(), "\n")
            local decoded = vim.json.decode(result)
            cb(decoded)
        end,
        on_stdout = function(error, data, self)
            -- log.info(data)
        end,
        on_stderr = function(error, data, self)
            --
            -- log.info(data)
        end,
    }):start()
end

return utils
