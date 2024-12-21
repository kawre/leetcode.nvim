local utils = require("leetcode.api.utils")
local config = require("leetcode.config")
local log = require("leetcode.logger")
local queries = require("leetcode.api.queries")
local urls = require("leetcode.api.urls")
local Spinner = require("leetcode.logger.spinner")

---@class lc.CompaniesApi
local Companies = {}

---@param cb? fun(res: lc.cache.Company[]|nil, err: lc.err)
---@param noti? boolean
--
---@return lc.cache.Company[] lc.err
function Companies.all(cb, noti)
    local query = queries.companies

    local spinner
    if noti then
        spinner = Spinner:init("updating cache...", "points")
    end
    if cb then
        utils.query(query, _, {
            endpoint = urls.companies,
            callback = function(res, err)
                if err then
                    if spinner then
                        spinner:stop(err.msg, false)
                    end
                    return cb(nil, err)
                end
                local data = res.data
                local companies = data["companyTags"]
                if spinner then
                    spinner:stop("cache updated")
                end
                cb(companies)
            end,
        })
    else
        local res, err = utils.query(query)
        if err then
            if spinner then
                spinner:stop(err.msg, false)
            end
            return nil, err
        else
            local data = res.data
            local companies = data["companyTags"]
            if spinner then
                spinner:stop("cache updated")
            end
            return companies
        end
    end
end

function Companies.problems(company, cb)
    local url = urls.company_problems:format(company)

    if cb then
        utils.get(url, {
            callback = function(res, err)
                if err then
                    return cb(nil, err)
                end
                local questions = res["questions"]
                cb(questions)
            end
        })
    else
        local res, err = utils.get(url)
        if err then
            return nil, err
        end
        local questions = res.data["questions"]
        return questions
    end
end

return Companies
