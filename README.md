<div align="center">

# 🍴 leetcode.nvim (Extended Fork)

**Extended hooks and external integration for [kawre/leetcode.nvim](https://github.com/kawre/leetcode.nvim)**

The original project seems not be not actively maintained thats why i forked it
Track problems, time spent, and submissions via external services.

</div>

## ✨ What's New

This fork adds submission tracking and session management capabilities to leetcode.nvim:

- **Session Timer Commands**: `:Leet timer_start` / `:Leet timer_stop`
- **Extended Hooks**: `timer_start`, `question_leave`, and improved `upload_submit_result` / `upload_test_result`
- **External Integration**: Wire hooks to external APIs for persistence
- **Bug Fix**: Resolved `nvim_win_is_valid` fast event crash in timer display

## 🎯 New Hooks

Beyond the original hooks, this fork adds:

| Hook | Signature | When |
|------|-----------|------|
| `timer_start` | `fun(question: lc.ui.Question)` | Session timer started (`:Leet session start`) |
| `question_leave` | `fun(question: lc.ui.Question)` | Question window closed or session stopped |

Existing hooks also trigger on submissions:

| Hook | Signature | When |
|------|-----------|------|
| `upload_submit_result` | `fun(question, buffer, item_json)` | After `:Leet submit` |
| `upload_test_result` | `fun(question, buffer, item_json)` | After `:Leet run` |

## 🛠️ New Commands

```vim
:Leet timer_start          " Start tracking session time
:Leet timer_stop           " Stop tracking (drop session without saving)
:Leet session start        " Alias for timer_start
:Leet session stop         " Alias for timer_stop
```

## 📡 External Integration Example

Connect to a submission server to save data:

```lua
-- ~/.config/nvim/init.lua or plugin spec
local db_saver = require("submission_db_saver")

return {
    "kawre/leetcode.nvim",
    opts = {
        hooks = {
            -- Track time on a problem
            ["timer_start"] = {
                function(question)
                    db_saver.timer_start(question)
                    question:start_timer_display()
                end,
            },
            -- Clean up timer on close
            ["question_leave"] = {
                function(question)
                    db_saver.drop_session(question)
                end,
            },
            -- Save test runs
            ["upload_test_result"] = {
                function(question, buffer, item)
                    db_saver.save_submission(question, buffer, item)
                end,
            },
            -- Save final submissions
            ["upload_submit_result"] = {
                function(question, buffer, item)
                    db_saver.save_submission(question, buffer, item)
                end,
            },
        },
    },
}
```

## 🖥️ Server API

Expected server endpoints:

```
POST /api/session
{
    "action": "start_timer" | "drop_timer" | "save_submission",
    "title_slug": "two-sum",
    "content": "...",          // for save_submission
    "item": {...}              // for save_submission
}
```

Server should respond with:
```json
{
    "success": true,
    "action": "start_timer"
}
```

## 📝 Implementation Details

### Files Modified

- `lua/leetcode/command/init.lua` - Added `timer_start` / `timer_stop` commands
- `lua/leetcode/config/hooks.lua` - Registered new hook events
- `lua/leetcode/config/template.lua` - Hook type aliases
- `lua/leetcode-ui/question.lua` - Fire `question_leave` on unmount, fixed timer fast event bug
- `packages/submission_server/src/submission_server.py` - Added `DROP_TIMER` action
- `packages/submission_server/src/submission_db_saver.lua` - Added `timer_start()` and `drop_session()`

### Usage Pattern

1. User runs `:Leet session start` → `timer_start` hook fires → server starts session timer
2. User closes question or runs `:Leet session stop` → `question_leave` hook fires → server drops timer
3. User submits code → `upload_submit_result` hook fires → server saves submission
4. Time and submissions are persisted in external database

## 🔧 Installation

Use this fork instead of the original:

```lua
{
    "jingyi-zhao-01/leetcode.nvim",  -- or your fork
    build = ":TSUpdate html",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
    },
    opts = {
        -- See hooks example above
    },
}
```

## 📚 Refer to Original

For core leetcode.nvim features, installation, and configuration, see:
https://github.com/kawre/leetcode.nvim
