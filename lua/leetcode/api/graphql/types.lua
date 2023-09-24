--------------------------------------------
--- Code snipppet
--------------------------------------------
---@class lc.QuestionCodeSnippet
---@field lang string
---@field lang_slug string
---@field code string

---@alias code_snippet lc.QuestionCodeSnippet

--------------------------------------------
--- Metadata Param
--------------------------------------------
---@class lc.QuestionResponse.metadata.param
---@field name string
---@field type string

---@alias metadata_param lc.QuestionResponse.metadata.param

--------------------------------------------
--- Metadata Return
--------------------------------------------
---@class lc.QuestionResponse.metadata.return
---@field type string
---@field size integer

---@alias metadata_return lc.QuestionResponse.metadata.return

--------------------------------------------
--- Metadata
--------------------------------------------
---@class lc.QuestionResponse.metadata
---@field manual boolean
---@field name string
---@field params metadata_param[]
---@field return metadata_return

---@alias metadata lc.QuestionResponse.metadata

--------------------------------------------
--- Question Response
--------------------------------------------
---@class lc.QuestionResponse
---@field id integer
---@field frontend_id integer
---@field title string
---@field title_slug string
---@field id_paid_only boolean
---@field difficulty string
---@field likes integer
---@field dislikes integer
---@field category_title string
---@field content string
---@field mysql_schemas string[]
---@field data_schemas string[]
---@field code_snippets code_snippet[]
---@field testcase_list string[]
---@field meta_data metadata

---@alias question_response lc.QuestionResponse
