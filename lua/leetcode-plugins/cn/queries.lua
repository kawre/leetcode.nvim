local queries = require("leetcode.api.queries")

queries.auth = [[
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

queries.qot = [[
        query questionOfToday {
            todayRecord {
                question {
                    title_slug: titleSlug
                }
            }
        }
    ]]

queries.question = [[
        query ($titleSlug: String!) {
            question(titleSlug: $titleSlug) {
                id: questionId
                frontend_id: questionFrontendId
                title_slug: titleSlug
                is_paid_only: isPaidOnly
                difficulty
                likes
                dislikes
                category_title: categoryTitle
                content
                translated_content: translatedContent
                title
                translated_title: translatedTitle
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

queries.random_question = [[
        query problemsetRandomFilteredQuestion(
            $categorySlug: String!
            $filters: QuestionListFilterInput
        ) {
            randomQuestion: problemsetRandomFilteredQuestion(categorySlug: $categorySlug, filters: $filters)
        }
    ]]

queries.translations = [[
        query getQuestionTranslation($lang: String) {
            translations: allAppliedQuestionTranslations(lang: $lang) {
                title
                questionId
            }
        }
    ]]

queries.solved = [[
        query userStats($username: String!) {
            submit_stats: userProfileUserQuestionProgress(userSlug: $username) {
                numAcceptedQuestions {
                    difficulty
                    count
                }
                numFailedQuestions {
                    difficulty
                    count
                }
                numUntouchedQuestions {
                    difficulty
                    count
                }
            }
        }
    ]]

queries.calendar = [[
        query userProfileCalendar($username: String!, $year: Int) {
            calendar: userCalendar(userSlug: $username, year: $year) {
                active_years: activeYears
                streak
                total_active_days: totalActiveDays
                submission_calendar: submissionCalendar
            }
        }
    ]]

queries.languages = [[
        query languageStats($username: String!) {
            languageProblemCount: userLanguageProblemCount(userSlug: $username) {
                lang: languageName
                problems_solved: problemsSolved
            }
        }
    ]]

queries.skills = [[
        query skillStats($username: String!) {
            matchedUser(username: $username) {
                tag_problems_counts: tagProblemCounts {
                    advanced {
                        tag: tagName
                        slug: tagSlug
                        problems_solved: problemsSolved
                    }
                    intermediate {
                        tag: tagName
                        slug: tagSlug
                        problems_solved: problemsSolved
                    }
                    fundamental {
                        tag: tagName
                        slug: tagSlug
                        problems_solved: problemsSolved
                    }
                }
            }
        }
    ]]

queries.streak = [[
        query getStreakCounter {
            streakCounter: problemsetStreakCounter {
                streakCount
                daysSkipped
                todayCompleted
            }
        }
    ]]

queries.session_progress = [[
        query userSessionProgress($userSlug: String!) {
            userProfileUserQuestionProgress(userSlug: $userSlug) {
                numAcceptedQuestions {
                    difficulty
                    count
                }
            }
        }
    ]]

queries.streak = [[
        query questionCompanyTags {
            companyTags {
                name
                slug
                questionCount
            }
        }
    ]]
