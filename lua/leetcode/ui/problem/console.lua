local m = require("markup")

local ICONS = {
    testcase = "\u{f0668}",
    result = "\u{f0b8e}",
    add = "\u{f0415}",
}

--- A pressable chip, a tab or a case, lighter under the cursor.
---@param props { variant: "tab"|"case", label: string|fun(): string, active: fun(): boolean, press: function }
local function Chip(props)
    local hovered = m.signal(false)
    return m.inline({
        click = "double",
        on_press = props.press,
        on_hover = hovered,
        white_space = "nowrap",
        style = function()
            local group = "leetcode_console_" .. props.variant
            if props.active() then
                group = group .. "_active"
            end
            if hovered() then
                group = group .. "_hover"
            end
            return group
        end,
        props.label,
    })
end

--- A field holding the value of one parameter. Pressing it types over it.
---@param props { console: leet.problem.console, param: integer, hovered: markup.reactive.signal }
local function Field(props)
    local testcase = props.console.testcase
    local hovered = m.signal(false)

    local function press()
        testcase:edit(props.param)
    end
    -- So typing can find where the field is.
    testcase.fields[props.param] = press
    m.on_cleanup(function()
        if testcase.fields[props.param] == press then
            testcase.fields[props.param] = nil
        end
    end)

    return m.flex({
        click = "double",
        on_press = press,
        on_hover = function(on)
            hovered(on)
            if on then
                props.hovered(props.param)
            end
        end,
        white_space = "nowrap",
        margin_bottom = 1,
        style = function()
            local typing = props.console.typing() == props.param
            return (typing or hovered()) and "leetcode_input_focus" or "leetcode_input"
        end,
        m.inline({
            "▌ ",
            style = function()
                return props.console.typing() == props.param and "leetcode_accent"
                    or "leetcode_muted"
            end,
        }),
        m.inline(function()
            local case = testcase.cases()[testcase.selected()] or {}
            local value = case[props.param] or ""
            return value == "" and " " or value
        end),
    })
end

--- The cases to run, one at a time, with a field for each parameter.
---@param props { console: leet.problem.console }
local Testcases = m.component(function(props)
    local console = props.console
    local testcase = console.testcase
    -- The field last under the cursor, which `i` types into.
    local hovered = m.signal(1)

    for i = 1, 9 do
        m.use_key(tostring(i), function()
            testcase:select(i)
        end)
    end
    m.use_key("a", function()
        testcase:add()
    end)
    m.use_key("d", function()
        testcase:remove()
    end)
    m.use_key("r", function()
        testcase:reset()
    end)
    m.use_key("i", function()
        testcase:edit(m.untrack(hovered))
    end)

    local fields = {}
    for i, name in ipairs(testcase:names()) do
        fields[#fields + 1] = m.block({ m.inline(name .. " =", "leetcode_muted") })
        fields[#fields + 1] = Field({ console = console, param = i, hovered = hovered })
    end

    return m.block({
        padding = { 1, 3, 0, 3 },
        m.block({
            margin_bottom = 1,
            m.inline({
                spacing = 1,
                m.each(function()
                    local list = {}
                    for i = 1, #testcase.cases() do
                        list[i] = i
                    end
                    return list
                end, function(i)
                    return Chip({
                        variant = "case",
                        label = (" Case %d "):format(i),
                        active = function()
                            return testcase.selected() == i
                        end,
                        press = function()
                            testcase:select(i)
                        end,
                    })
                end),
                Chip({
                    variant = "case",
                    label = (" %s "):format(ICONS.add),
                    active = function()
                        return false
                    end,
                    press = function()
                        testcase:add()
                    end,
                }),
            }),
        }),
        fields,
        m.block({
            m.inline("a", "leetcode_key"),
            m.inline(" add  ", "leetcode_muted"),
            m.inline("d", "leetcode_key"),
            m.inline(" remove  ", "leetcode_muted"),
            m.inline("r", "leetcode_key"),
            m.inline(" reset  ", "leetcode_muted"),
            m.inline("i", "leetcode_key"),
            m.inline(" edit", "leetcode_muted"),
        }),
    })
end)

--- What the last run or submission came to, or how to get one.
---@param props { console: leet.problem.console }
local function Results(props)
    return function()
        local content = props.console.result.content()
        if content then
            return content.render()
        end
        -- How to get a result, which there is nothing to do with but read.
        return m.block({
            padding = { 1, 3, 0, 3 },
            snap = false,
            m.block({ "Run your code to see how it does.", style = "leetcode_muted" }),
            m.block({
                margin_top = 1,
                m.inline(":Leet run", "leetcode_key"),
                m.inline(" tries the testcases, ", "leetcode_muted"),
                m.inline(":Leet submit", "leetcode_key"),
                m.inline(" sends it to be judged", "leetcode_muted"),
            }),
        })
    end
end

local TABS = {
    { key = "testcase", label = "Testcase", icon = ICONS.testcase },
    { key = "result", label = "Result", icon = ICONS.result },
}

--- One panel below the editor: the testcases to run, and what running them did.
---@param props { console: leet.problem.console }
return m.component(function(props)
    local console = props.console

    local function switch(by)
        for i, tab in ipairs(TABS) do
            if tab.key == m.untrack(console.tab) then
                console.tab(TABS[(i - 1 + by) % #TABS + 1].key)
                return
            end
        end
    end
    -- Presses what the cursor is on: a tab, a case, or a field to type into.
    local view = m.use_view()
    local confirm = Leet.config.user.keys.confirm
    for _, lhs in ipairs(type(confirm) == "table" and confirm or { confirm }) do
        m.use_key(lhs, function()
            view:press()
        end)
    end
    m.use_key("<Tab>", function()
        switch(1)
    end)
    m.use_key("<S-Tab>", function()
        switch(-1)
    end)

    local tabs = {}
    for _, tab in ipairs(TABS) do
        local function active()
            return console.tab() == tab.key
        end
        tabs[#tabs + 1] = Chip({
            variant = "tab",
            -- The icon of the tab shown takes the accent.
            label = m.inline({
                " ",
                m.inline(tab.icon, function()
                    return active() and "leetcode_accent" or nil
                end),
                (" %s "):format(tab.label),
            }),
            active = function()
                return console.tab() == tab.key
            end,
            press = function()
                console.tab(tab.key)
            end,
        })
    end

    return m.block({
        white_space = "nowrap",
        -- A solid band, the color of the description's header.
        m.flex({
            justify = "between",
            -- A row above the tabs, and half a row below them.
            padding = { 1, 3 },
            style = "leetcode_description_header",
            m.inline({ spacing = 1, tabs }),
            -- What the last run came to, or how to switch tabs before there is one.
            function()
                local content = console.result.content()
                if content and content.status then
                    return content.status()
                end
                return m.inline({
                    snap = false,
                    m.inline("<Tab>", "leetcode_key"),
                    m.inline(" switch", "leetcode_muted"),
                })
            end,
        }),
        function()
            if console.tab() == "testcase" then
                return Testcases({ console = console })
            end
            return m.block({ white_space = "normal", Results({ console = console }) })
        end,
    })
end)
