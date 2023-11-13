local config = require("leetcode.config")

---@class lc.Api.Queries
local queries = {}

local function com_or(query, query_cn) return not config.is_cn and query or query_cn end

function queries.auth()
    local query = [[
        query globalData {
            userStatus {
                id: userId
                name: username
                is_signed_in: isSignedIn
                is_premium: isPremium
                is_verified: isVerified
            }
        }
    ]]

    local query_cn = [[
        query globalData {
            userStatus {
                slug: userSlug
                name: username
                real_name: realName
                is_signed_in: isSignedIn
                is_premium: isPremium
                is_verified: isVerified
            }
        }
    ]]

    return com_or(query, query_cn)
end

function queries.problemset()
    local query = [[
        query problemsetQuestionList($limit: Int) {
            problemsetQuestionList: questionList(
                categorySlug: ""
                limit: $limit
                filters: {  }
            ) {
                questions: data {
                    frontend_id: questionFrontendId
                    title
                    title_slug: titleSlug
                    status
                    paid_only: isPaidOnly
                    ac_rate: acRate
                    difficulty
                    topic_tags: topicTags {
                        name
                        slug
                        id
                    }
                }
            }
        }
    ]]

    local query_cn = [[
        query problemsetQuestionList($limit: Int) {
            problemsetQuestionList(
                categorySlug: ""
                limit: $limit
                filters: {  }
            ) {
                questions {
                    frontend_id: frontendQuestionId
                    title
                    title_slug: titleSlug
                    title_cn: titleCn
                    status
                    paid_only: paidOnly
                    ac_rate: acRate
                    difficulty
                    topic_tags: topicTags {
                        name
                        slug
                        id
                    }
                }
            }
        }
    ]]

    return com_or(query, query_cn)
end

function queries.qot()
    local query = [[
        query questionOfToday {
            todayRecord: activeDailyCodingChallengeQuestion {
                question {
                    title_slug: titleSlug
                }
            }
        }
    ]]

    local query_cn = [[
        query questionOfToday {
            todayRecord {
                question {
                    title_slug: titleSlug
                }
            }
        }
    ]]

    return com_or(query, query_cn)
end

function queries.question()
    local query = [[
        query ($titleSlug: String!) {
            question(titleSlug: $titleSlug) {
                id: questionId
                frontend_id: questionFrontendId
                title
                title_slug: titleSlug
                is_paid_only: isPaidOnly
                difficulty
                likes
                dislikes
                category_title: categoryTitle
                content
                mysql_schemas: mysqlSchemas
                data_schemas: dataSchemas
                code_snippets: codeSnippets {
                    lang
                    lang_slug: langSlug
                    code
                }
                testcase_list: exampleTestcaseList
                meta_data: metaData
                ac_rate: acRate
                stats
                hints
                topic_tags: topicTags {
                    name
                    slug
                }
                similar: similarQuestionList {
                    difficulty
                    title_slug: titleSlug
                    title
                    paid_only: isPaidOnly
                }
            }
        }
    ]]

    local query_cn = [[
        query ($titleSlug: String!) {
            question(titleSlug: $titleSlug) {
                id: questionId
                frontend_id: questionFrontendId
                title: translatedTitle
                title_slug: titleSlug
                is_paid_only: isPaidOnly
                difficulty
                likes
                dislikes
                category_title: categoryTitle
                content: translatedContent
                mysql_schemas: mysqlSchemas
                data_schemas: dataSchemas
                code_snippets: codeSnippets {
                    lang
                    lang_slug: langSlug
                    code
                }
                testcase_list: exampleTestcaseList
                meta_data: metaData
                ac_rate: acRate
                stats
                hints
                topic_tags: topicTags {
                    name: translatedName
                    slug
                }
                similar: similarQuestions
            }
        }
    ]]

    return com_or(query, query_cn)
end

function queries.random_question()
    local query = [[
        query randomQuestion($categorySlug: String) {
            randomQuestion(categorySlug: $categorySlug, filters: {  }) {
                title_slug: titleSlug
                paid_only: isPaidOnly
            }
        }
    ]]

    local query_cn = [[
        query problemsetRandomFilteredQuestion(
            $categorySlug: String!
        ) {
            randomQuestion: problemsetRandomFilteredQuestion(categorySlug: $categorySlug, filters: {  })
        }
    ]]

    return com_or(query, query_cn)
end

function queries.translations()
    local query_cn = [[
        query getQuestionTranslation($lang: String) {
            translations: allAppliedQuestionTranslations(lang: $lang) {
                title
                questionId
            }
        }
    ]]

    return com_or(nil, query_cn)
end

return queries
