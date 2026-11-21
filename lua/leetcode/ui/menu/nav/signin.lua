--- Before there is a user: one card that says how to sign in, lit as the only
--- thing there is to do, and a way out.

local m = require("markup")
local i18n = require("leetcode.i18n")
local kit = require("leetcode.ui.kit")
local Frame = require("leetcode.ui.menu.dashboard.frame")

---@param props { width: integer }
return m.component(function(props)
	local cmd = require("leetcode.cmd")
	local function quit()
		require("leetcode").stop()
	end
	m.use_key("i", cmd.cookie_prompt, { nowait = true })
	m.use_key("q", quit, { nowait = true })

	return m.block({
		width = props.width,
		Frame({
			selected = function()
				return true
			end,
			width = props.width,
			style = "leetcode_daily",
			on_press = cmd.cookie_prompt,
			children = {
				m.flex({
					justify = "between",
					white_space = "nowrap",
					m.inline(kit.icons.code .. " " .. i18n.sign_in_card, "leetcode_accent"),
					m.inline(" i ", "leetcode_tab_active"),
				}),
				m.block(" "),
				m.block(i18n.sign_in_hint, "leetcode_strong"),
				m.block(i18n.sign_in_local, "leetcode_muted"),
			},
		}),
		m.flex({
			margin_top = 1,
			padding = { 0, 1 },
			justify = "between",
			white_space = "nowrap",
			m.inline({ kit.Key("i"), m.inline(" " .. i18n.sign_in_desc, "leetcode_muted") }),
			m.inline({ kit.Key("q"), m.inline(" " .. i18n.quit_hint, "leetcode_muted") }),
		}),
	})
end)
