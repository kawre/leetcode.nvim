---@class lc.api.urls
local urls = {}

urls.base = "/graphql/"
urls.solved = "/graphql/"
urls.calendar = "/graphql/"
urls.languages = "/graphql/"
urls.companies = "/graphql/"
urls.skills = "/graphql/"
urls.auth = "/graphql/"

urls.problems = "/api/problems/%s/"
urls.company_problems = "/problems/tag-data/company-tags/%s/"
urls.interpret = "/problems/%s/interpret_solution/"
urls.submit = "/problems/%s/submit/"
urls.run = "/problems/%s/interpret_solution/"
urls.check = "/submissions/detail/%s/check/"
urls.latest_submission = "/submissions/latest/?qid=%s&lang=%s"
urls.streak_counter = "/graphql/"
urls.session = "/session/"

return urls
