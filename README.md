<div align="center">

# leetcode.nvim

🔥 Solve [LeetCode] problems within [Neovim] 🔥

<!-- 🇺🇸 English, 🇨🇳 <a href="README.zh.md">简体中文</a> -->

</div>

https://github.com/kawre/leetcode.nvim/assets/69250723/aee6584c-e099-4409-b114-123cb32b7563

## ✨ Features

- 📌 an intuitive dashboard for effortless navigation within [leetcode.nvim]

- 😍 question description formatting for a better readability

- 📈 [LeetCode] profile statistics within [Neovim]

- 🔀 support for daily and random questions

- 💾 caching for optimized performance

## 📬 Requirements

- [Neovim] >= 0.9.0

- [telescope.nvim] or [fzf-lua]

- [plenary.nvim]

- [nui.nvim]

- [tree-sitter-html] _**(optional, but highly recommended)**_
  used for formatting the question description.
  Can be installed with [nvim-treesitter].

- [Nerd Font][nerd-font] & [nvim-web-devicons] _**(optional)**_

## 📦 Installation

- [lazy.nvim]

```lua
{
    "kawre/leetcode.nvim",
    build = ":TSUpdate html", -- if you have `nvim-treesitter` installed
    dependencies = {
        "nvim-telescope/telescope.nvim",
        -- "ibhagwan/fzf-lua",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
    },
    opts = {
        -- configuration goes here
    },
}
```

## 🛠️ Configuration

To see full configuration types see [template.lua](./lua/leetcode/config/template.lua)

### ⚙️ default configuration

```lua
{
    ---@type string
    arg = "leetcode.nvim",

    ---@type lc.lang
    lang = "cpp",

    cn = { -- leetcode.cn
        enabled = false, ---@type boolean
        translator = true, ---@type boolean
        translate_problems = true, ---@type boolean
    },

    ---@type lc.storage
    storage = {
        home = vim.fn.stdpath("data") .. "/leetcode",
        cache = vim.fn.stdpath("cache") .. "/leetcode",
    },

    ---@type table<string, boolean>
    plugins = {
        non_standalone = false,
    },

    ---@type boolean
    logging = true,

    injector = {}, ---@type table<lc.lang, lc.inject>

    cache = {
        update_interval = 60 * 60 * 24 * 7, ---@type integer 7 days
    },

    console = {
        open_on_runcode = true, ---@type boolean

        dir = "row", ---@type lc.direction

        size = { ---@type lc.size
            width = "90%",
            height = "75%",
        },

        result = {
            size = "60%", ---@type lc.size
        },

        testcase = {
            virt_text = true, ---@type boolean

            size = "40%", ---@type lc.size
        },
    },

    description = {
        position = "left", ---@type lc.position

        width = "40%", ---@type lc.size

        show_stats = true, ---@type boolean
    },

    ---@type lc.picker
    picker = { provider = nil },

    hooks = {
        ---@type fun()[]
        ["enter"] = {},

        ---@type fun(question: lc.ui.Question)[]
        ["question_enter"] = {},

        ---@type fun()[]
        ["leave"] = {},
    },

    keys = {
        toggle = { "q" }, ---@type string|string[]
        confirm = { "<CR>" }, ---@type string|string[]

        reset_testcases = "r", ---@type string
        use_testcase = "U", ---@type string
        focus_testcases = "H", ---@type string
        focus_result = "L", ---@type string
    },

    ---@type lc.highlights
    theme = {},

    ---@type boolean
    image_support = false,
}
```

### arg

Argument for [Neovim]

```lua
---@type string
arg = "leetcode.nvim"
```

<small>See [usage](#-usage) for more info</small>

### lang

Language to start your session with

```lua
---@type lc.lang
lang = "cpp"
```

<details>
  <summary>available languages</summary>

| Language   | lang       |
| ---------- | ---------- |
| C++        | cpp        |
| Java       | java       |
| Python     | python     |
| Python3    | python3    |
| C          | c          |
| C#         | csharp     |
| JavaScript | javascript |
| TypeScript | typescript |
| PHP        | php        |
| Swift      | swift      |
| Kotlin     | kotlin     |
| Dart       | dart       |
| Go         | golang     |
| Ruby       | ruby       |
| Scala      | scala      |
| Rust       | rust       |
| Racket     | racket     |
| Erlang     | erlang     |
| Elixir     | elixir     |
| Bash       | bash       |

</details>

### cn

Use [leetcode.cn] instead of [leetcode.com][leetcode]

```lua
cn = { -- leetcode.cn
    enabled = false, ---@type boolean
    translator = true, ---@type boolean
    translate_problems = true, ---@type boolean
},
```

### storage

storage directories

```lua
---@type lc.storage
storage = {
    home = vim.fn.stdpath("data") .. "/leetcode",
    cache = vim.fn.stdpath("cache") .. "/leetcode",
},
```

### plugins

[plugins list](#-plugins)

```lua
---@type table<string, boolean>
plugins = {
    non_standalone = false,
},
```

### logging

Whether to log [leetcode.nvim] status notifications

```lua
---@type boolean
logging = true
```

### injector

Inject code before or after your solution, injected code won't be submitted or run.

#### default imports

You can also pass `before = true` to inject default imports for the language.
Supported languages are `python`, `python3`, `java`

Access default imports via `require("leetcode.config.imports")`

```lua
injector = { ---@type table<lc.lang, lc.inject>
    ["python3"] = {
        before = true
    },
    ["cpp"] = {
        before = { "#include <bits/stdc++.h>", "using namespace std;" },
        after = "int main() {}",
    },
    ["java"] = {
        before = "import java.util.*;",
    },
}
```

### picker

Supported picker providers are `telescope` and `fzf-lua`.
When provider is `nil`, [leetcode.nvim] will first try to use `fzf-lua`,
if not found it will fallback to `telescope`.

```lua
---@type lc.picker
picker = { provider = nil },
```

### hooks

List of functions that get executed on specified event

```lua
hooks = {
    ---@type fun()[]
    ["enter"] = {},

    ---@type fun(question: lc.ui.Question)[]
    ["question_enter"] = {},

    ---@type fun()[]
    ["leave"] = {},
},
```

### theme

Override the [default theme](./lua/leetcode/theme/default.lua).

Each value is the same type as val parameter in `:help nvim_set_hl`

```lua
---@type lc.highlights
theme = {
    ["alt"] = {
        bg = "#FFFFFF",
    },
    ["normal"] = {
        fg = "#EA4AAA",
    },
},
```

### image support

Whether to render question description images using [image.nvim]

> [!WARNING]
> Enabling this will disable question description wrap,
> because of https://github.com/3rd/image.nvim/issues/62#issuecomment-1778082534

```lua
---@type boolean
image_support = false,
```

## 📋 Commands

### `Leet` opens menu dashboard

- `menu` same as `Leet`

- `exit` close [leetcode.nvim]

- `console` opens console pop-up for currently opened question

- `info` opens a pop-up containing information about the currently opened question

- `tabs` opens a picker with all currently opened question tabs

- `yank` yanks the current question solution

- `lang` opens a picker to change the language of the current question

- `run` run currently opened question

- `test` same as `Leet run`

- `submit` submit currently opened question

- `random` opens a random question

- `daily` opens the question of today

- `list` opens a problem list picker

- `open` opens the current question in a default browser

- `reset` reset current question to default code definition

- `last_submit` retrieve last submitted code for the current question

- `restore` try to restore default question layout

- `inject` re-inject code for the current question

- `session`

  - `create` create a new session
  - `change` change the current session

  - `update` update the current session in case it went out of sync

- `desc` toggle question description

  - `toggle` same as `Leet desc`

  - `stats` toggle description stats visibility

- `cookie`

  - `update` opens a prompt to enter a new cookie

  - `delete` sign-out

- `cache`

  - `update` updates cache

#### Some commands can take optional arguments. To stack argument values separate them by a `,`

- `Leet list`

  ```
  Leet list status=<status> difficulty=<difficulty>
  ```

- `Leet random`

  ```
  Leet random status=<status> difficulty=<difficulty> tags=<tags>
  ```

## 🚀 Usage

This plugin can be initiated in two ways:

- To start [leetcode.nvim], simply pass [`arg`](#arg)
  as the _first and **only**_ [Neovim] argument

  ```
  nvim leetcode.nvim
  ```

- _**(Experimental)**_ Alternatively, you can use `:Leet` command to open [leetcode.nvim]
  within your preferred dashboard plugin. The only requirement is that [Neovim]
  must not have any listed buffers open.

### Switching between questions

To switch between questions, use `Leet tabs`

### Sign In

It is **required** to be **signed-in** to use [leetcode.nvim]

https://github.com/kawre/leetcode.nvim/assets/69250723/b7be8b95-5e2c-4153-8845-4ad3abeda5c3

## 🍴 Recipes

### 💤 lazy loading with [lazy.nvim]

> [!WARNING]
> opting for either option makes the alternative
> launch method unavailable due to lazy loading

- with [`arg`](#arg)

  ```lua
  local leet_arg = "leetcode.nvim"
  ```

  ```lua
  {
      "kawre/leetcode.nvim",
      lazy = leet_arg ~= vim.fn.argv(0, -1),
      opts = { arg = leet_arg },
  }
  ```

- with `:Leet`

  ```lua
  {
      "kawre/leetcode.nvim",
      cmd = "Leet",
  }
  ```

### 🪟 Windows

If you are using Windows,
it is recommended to use [Cygwin](https://www.cygwin.com/) for a more consistent and Unix-like experience.

## 🧩 Plugins

### Non-Standalone mode

To run [leetcode.nvim] in a non-standalone mode (i.e. not with argument or an empty Neovim session),
enable the `non_standalone` plugin in your config:

```lua
plugins = {
    non_standalone = true,
}
```

You can then exit [leetcode.nvim] using `:Leet exit` command

## 🙌 Credits

- [Leetbuddy.nvim](https://github.com/Dhanus3133/Leetbuddy.nvim)

- [alpha-nvim](https://github.com/goolord/alpha-nvim)

[image.nvim]: https://github.com/3rd/image.nvim
[lazy.nvim]: https://github.com/folke/lazy.nvim
[leetcode]: https://leetcode.com
[leetcode.cn]: https://leetcode.cn
[leetcode.nvim]: https://github.com/kawre/leetcode.nvim
[neovim]: https://github.com/neovim/neovim
[nerd-font]: https://www.nerdfonts.com
[nui.nvim]: https://github.com/MunifTanjim/nui.nvim
[nvim-treesitter]: https://github.com/nvim-treesitter/nvim-treesitter
[nvim-web-devicons]: https://github.com/nvim-tree/nvim-web-devicons
[telescope.nvim]: https://github.com/nvim-telescope/telescope.nvim
[fzf-lua]: https://github.com/ibhagwan/fzf-lua
[tree-sitter-html]: https://github.com/tree-sitter/tree-sitter-html
[plenary.nvim]: https://github.com/nvim-lua/plenary.nvim
