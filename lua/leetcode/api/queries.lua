---@class leet.api.queries
local queries = {}

queries.auth = [[
	query globalData {
		userStatus {
			id: userId
			name: username
			is_signed_in: isSignedIn
			is_premium: isPremium
			is_verified: isVerified
			session_id: activeSessionId
		}
	}
]]

queries.qot = [[
	query questionOfToday {
		todayRecord: activeDailyCodingChallengeQuestion {
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

queries.random_question = [[
	query randomQuestion($categorySlug: String, $filters: QuestionListFilterInput) {
		randomQuestion(categorySlug: $categorySlug, filters: $filters) {
			title_slug: titleSlug
			paid_only: isPaidOnly
		}
	}
]]

queries.translations = nil

queries.solved = [[
	query userCalendar($username: String!) {
		allQuestionsCount {
			difficulty
			count
		}
		matchedUser(username: $username) {
			submit_stats: submitStatsGlobal {
				acSubmissionNum {
					difficulty
					count
				}
			}
		}
	}
]]

queries.calendar = [[
	query userCalendar($username: String!, $year: Int) {
		matchedUser(username: $username) {
			calendar: userCalendar(year: $year) {
				active_years: activeYears
				streak
				total_active_days: totalActiveDays
				dcc_badges: dccBadges {
					timestamp
					badge {
						name
						icon
					}
				}
				submission_calendar: submissionCalendar
			}
			solved_beats: problemsSolvedBeatsStats {
				difficulty
				percentage
			}
			submit_stats: submitStatsGlobal {
				acSubmissionNum {
					difficulty
					count
				}
			}
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

queries.languages = [[
	query languageStats($username: String!) {
		matchedUser(username: $username) {
			languageProblemCount {
				lang: languageName
				problems_solved: problemsSolved
			}
		}
	}
]]

queries.streak = [[
	query getStreakCounter {
		streakCounter {
			streakCount
			daysSkipped
			todayCompleted: currentDayCompleted
		}
	}
]]

queries.session_progress = [[
	query userSessionProgress($username: String!) {
		matchedUser(username: $username) {
			submitStats {
				acSubmissionNum {
					difficulty
					count
				}
			}
		}
	}
]]

return queries
