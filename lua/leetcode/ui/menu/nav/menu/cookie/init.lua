--- The account: who is signed in, and the session cookie that does it.

local m = require("markup")
local i18n = require("leetcode.i18n")
local kit = require("leetcode.ui.kit")
local Tile = require("leetcode.ui.menu.dashboard.tile")
local Echo = require("leetcode.ui.menu.dashboard.echo")

local GAP = 2

---@param props { width: integer }
return m.component(function(props)
	local cmd = require("leetcode.cmd")
	m.use_key("q", function()
		Leet.menu.set_page("menu")
	end, { nowait = true })
	Leet.menu.use_actions({ { title = i18n.back, lhs = "q" } })

	local tile = math.floor((props.width - GAP) / 2)
	local width = tile * 2 + GAP

	return m.vflex({
		width = width,
		m.block({
			-- The width of the box, padding included.
			width = width - 4,
			style = "leetcode_surface",
			padding = { 1, 2 },
			margin_bottom = 1,
			function()
				local auth = Leet.auth()
				return m.inline({
					m.inline(i18n.signed_in_as .. " ", "leetcode_muted"),
					m.inline(auth and auth.name or "", "leetcode_strong"),
				})
			end,
		}),
		m.flex({
			spacing = GAP,
			Tile({
				id = "account.cookie",
				title = i18n.cookie,
				desc = i18n.cookie_tile,
				detail = i18n.cookie_detail,
				lhs = "u",
				width = tile,
				on_press = cmd.cookie_prompt,
			}),
			Tile({
				id = "account.sign_out",
				title = i18n.sign_out,
				desc = i18n.sign_out_tile,
				detail = i18n.sign_out_detail,
				lhs = "d",
				width = tile,
				on_press = cmd.sign_out,
			}),
		}),
		m.block({ margin_top = 1, Echo(width) }),
	})
end)
