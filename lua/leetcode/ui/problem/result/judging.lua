local m = require("markup")
local kit = require("leetcode.ui.kit")

local animate = Markup.animate

local STEPS = { "Queued", "Judging", "Result" }
local STEP_OF = { PENDING = 1, STARTED = 2 }
local TRACK = 44
local RUNNER = 10

--- What the console shows while the judge works.
---@param props { state: fun(): string?, submit: boolean, lang?: string }
return m.component(function(props)
	-- One loader for the whole run, rather than a new one at every step.
	local names = require("markup.view.components").loader_names()
	local loader = names[math.random(#names)]

	local position = m.signal(0)
	animate.run({
		duration = 1400,
		easing = "linear",
		loop = true,
		update = function(t)
			-- There and back, slowing down at both ends.
			position(animate.easing.in_out_cubic(t < 0.5 and t * 2 or (1 - t) * 2))
		end,
	})

	local function step()
		return STEP_OF[props.state()] or 1
	end

	local function Step(index)
		return m.inline({
			m.inline({
				style = function()
					local current = step()
					return index < current and "leetcode_ok"
						or index == current and "leetcode_accent"
						or "leetcode_muted"
				end,
				function()
					local current = step()
					if index < current then
						return kit.icons.check
					end
					return index == current and m.loader({ name = loader }) or "○"
				end,
			}),
			m.inline({
				style = function()
					return index == step() and "leetcode_strong" or "leetcode_muted"
				end,
				" " .. STEPS[index],
			}),
			index < #STEPS and m.inline({
				style = function()
					return index < step() and "leetcode_ok" or "leetcode_muted"
				end,
				" ─── ",
			}),
		})
	end

	-- Progress to watch, not text to move through.
	return m.block({
		padding = { 1, 3 },
		snap = false,
		m.block({
			margin_bottom = 1,
			m.inline(
				props.submit and "Submitting your solution" or "Running your testcases",
				"leetcode_strong"
			),
		}),
		m.block({ margin_bottom = 1, white_space = "nowrap", Step(1), Step(2), Step(3) }),
		m.block({
			white_space = "nowrap",
			m.inline({
				style = "leetcode_track",
				width = TRACK,
				m.inline(function()
					return (" "):rep(math.floor(position() * (TRACK - RUNNER) + 0.5))
				end),
				m.inline(("█"):rep(RUNNER), "leetcode_bar_accent"),
			}),
		}),
	})
end)
