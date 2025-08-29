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

- [Picker](#picker)

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
        -- include a picker of your choice, see picker section for more details
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

    editor = {
        reset_previous_code = true, ---@type boolean
        fold_imports = true, ---@type boolean
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

Imports will be injected at the top of the buffer, automatically
folded by default.

```lua
injector = { ---@type table<lc.lang, lc.inject>
    ["python3"] = {
        imports = function(default_imports)
            vim.list_extend(default_imports, { "from .leetcode import *" })
            return default_imports
        end,
        after = { "def test():", "    print('test')" },
    },
    ["cpp"] = {
        imports = function()
            -- return a different list to omit default imports
            return { "#include <bits/stdc++.h>", "using namespace std;" }
        end,
        after = "int main() {}",
    },
},
```

### picker

Supported picker providers are:

- [`snacks-picker`][snacks.nvim]
- [`fzf-lua`][fzf-lua]
- [`telescope`][telescope.nvim]

If `provider` is `nil`, [leetcode.nvim] will try to resolve the first
available one in the order above.

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

- `yank` yanks the code section

- `lang` opens a picker to change the language of the current question

- `run` run currently opened question

- `test` same as `Leet run`

- `submit` submit currently opened question

- `random` opens a random question

- `daily` opens the question of today problem

- `list` opens a picker with all available leetcode problems

- `open` opens the current question in a default browser

- `restore` try to restore default question layout

- `last_submit` tries to replace the editor code section with the latest submitted code

- `reset` resets editor code section to the default snippet

- `inject` re-injects editor code, keeping the code section intact

- `fold` applies folding to the current question imports section

<!-- - `session` -->
<!--   - `create` create a new session -->
<!--   - `change` change the current session -->
<!---->
<!--   - `update` update the current session in case it went out of sync -->

- `desc` toggle question description
  - `toggle` same as `Leet desc`

  - `stats` toggle description stats visibility

- `cookie`
  - `update` opens a prompt to enter a new cookie

  - `delete` deletes stored cookie and logs out of [leetcode.nvim]

- `cache`
  - `update` fetches all available problems and updates the local cache of [leetcode.nvim]

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

- Use `:Leet` command to open [leetcode.nvim]
  within your preferred dashboard plugin. The only requirement is that [Neovim]
  must not have any listed buffers open.
  To bypass this requirement use [`non_standalone`](#non-standalone-mode) plugin.

### Sign In

> [!WARNING]
> Be sure to copy the `Cookie` from request headers, not the `set-cookie` from
> response headers.

> [!WARNING]
> If you are using **brave browser**, see [this
> issue](https://github.com/kawre/leetcode.nvim/issues/160#issuecomment-2619611920)

https://github.com/kawre/leetcode.nvim/assets/69250723/b7be8b95-5e2c-4153-8845-4ad3abeda5c3

## ❓ FAQ

### I keep getting `cookie expired` error

If you keep getting `Your cookie may have expired, or LeetCode has temporarily
restricted API access`, it most likely means that LeetCode website is under
heavy load and is restricting API access (mostly during contests).

All you can do is wait it out, try disabling a VPN if you’re using one, and if
the problem is persistent, open an issue.

### Switching between test cases

To switch between test cases, just press the number of the corresponding case:  
`1` for `Case (1)`, `2` for `Case (2)`, and so on.

### Switching between questions

To switch between questions, use `Leet tabs`

### I'm not getting LSP completions

Some languages require additional setup to get LSP completions.  
For example, Rust needs extra configuration — see [this issue](https://github.com/kawre/leetcode.nvim/issues/86).

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
[snacks.nvim]: https://github.com/folke/snacks.nvim
[tree-sitter-html]: https://github.com/tree-sitter/tree-sitter-html
[plenary.nvim]: https://github.com/nvim-lua/plenary.nvim
