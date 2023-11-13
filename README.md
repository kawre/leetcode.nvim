<div align="center">

🚨 **leetcode.nvim is currently in the _alpha stage_ of development** 🚨

______________________________________________________________________

# leetcode.nvim

🔥 Solve [LeetCode] problems within [Neovim] 🔥

</div>

https://github.com/kawre/leetcode.nvim/assets/69250723/309088c9-4ff7-4dff-ab61-ab3f09b43740

## ✨ Features

- 📌 an intuitive dashboard for effortless navigation within [leetcode.nvim]

- 😍 question description formatting for a better readability

- 📈 [LeetCode] profile statistics within [Neovim]

- 🔀 support for daily and random questions

- 💾 caching for optimized performance

## 📬 Requirements

- [Neovim] >= 0.9.0

- [telescope.nvim]

- [nui.nvim]

- [nvim-treesitter] _**(optional, but highly recommended)**_
  used for formatting the question description.
  Make sure to install the parser for `html`.

- [nvim-notify] _**(optional)**_

- [Nerd Font][nerd-font] & [nvim-web-devicons] _**(optional)**_

## 📦 Installation

- [lazy.nvim]

```lua
{
    "kawre/leetcode.nvim",
    build = ":TSUpdate html",
    dependencies = {
        "nvim-telescope/telescope.nvim",
        "nvim-lua/plenary.nvim", -- required by telescope
        "MunifTanjim/nui.nvim",

        -- optional
        "nvim-treesitter/nvim-treesitter",
        "rcarriga/nvim-notify",
        "nvim-tree/nvim-web-devicons",
    },
    opts = {
        -- configuration goes here
    },
}
```

<!-- [packer.nvim]: https://github.com/wbthomason/packer.nvim -->

## 🛠️ Configuration

To see full configuration types see [template.lua](./lua/leetcode/config/template.lua)

### ⚙️ default configuration

<!-- <details> -->

<!--   <summary>Click to see</summary> -->

```lua
{
    ---@type lc.domain
    domain = "com", -- For now "com" is the only one supported

    ---@type string
    arg = "leetcode.nvim",

    ---@type lc.lang
    lang = "cpp",

    ---@type lc.sql
    sql = "mysql",

    ---@type string
    directory = vim.fn.stdpath("data") .. "/leetcode/",

    ---@type boolean
    logging = true,

    console = {
        open_on_runcode = true, ---@type boolean

        dir = "row", ---@type "col" | "row"

        size = {
            width = "90%", ---@type string | integer
            height = "75%", ---@type string | integer
        },

        result = {
            size = "60%", ---@type string | integer
        },

        testcase = {
            virt_text = true, ---@type boolean

            size = "40%", ---@type string | integer
        },
    },

    description = {
        position = "left", ---@type "top" | "right" | "bottom" | "left"

        width = "40%", ---@type string | integer
    },

    hooks = {
        ---@type fun()[]
        LeetEnter = {},

        ---@type fun(question: { lang: string })[]
        LeetQuestionNew = {},
    },

    ---@type boolean
    image_support = false, -- setting this to `true` will disable question description wrap
}
```

<!-- </details> -->

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

---@type lc.sql_lang
sql = "mysql"
```

### domain

[LeetCode] domain.

```lua
---@type lc.domain
domain = "com" -- For now "com" is the only one supported
```

### directory

Where to store [leetcode.nvim] data

```lua
---@type string
directory = vim.fn.stdpath("data") .. "/leetcode/"
```

### logging

Whether to log [leetcode.nvim] status notifications

```lua
---@type boolean
logging = true
```

### hooks

List of functions that get executed on specified event

```lua
hooks = {
    ---@type fun()[]
    LeetEnter = {},

    ---@type fun(question: { lang: string })[]
    LeetQuestionNew = {},
},
```

### image support

Whether to render question description images using [image.nvim]

```lua
---@type boolean
image_support = false, -- setting this to `true` will disable question description wrap
```

## 📋 Commands

### `Leet` opens menu dashboard

- `menu` same as `Leet`

- `console` opens console pop-up for currently opened question

- `info` opens a pop-up containing information about the currently opened question

- `tabs` opens a picker with all currently opened question tabs

- `lang` opens a picker to change the language of the current question

- `run` run currently opened question

- `test` same as `Leet run`

- `submit` submit currently opened question

- `random` opens a random question

- `daily` opens the question of today

- [`list`](#leet-list) opens a problemlist picker

- `desc` toggle question description

  - `toggle` same as `Leet desc`

- `cookie`

  - `update` opens a prompt to enter a new cookie

  - `delete` sign-out

- `cache`

  - `update` updates cache

#### `Leet list`

Can take optional arguments. To stack argument values separate them by a `,`

```
Leet list status=<status> topics=<topic1,...,topicN> difficulty=<difficulty>
```

## 🚀 Usage

This plugin is meant to be used within a **fresh** [Neovim] instance.
Meaning that to launch [leetcode.nvim] you **have** to pass
[`arg`](#arg) as the _first and **only**_ [Neovim] argument

```
nvim leetcode.nvim
```

### Sign In

It is **required** to be **signed-in** to use [leetcode.nvim]

https://github.com/kawre/leetcode.nvim/assets/69250723/b7be8b95-5e2c-4153-8845-4ad3abeda5c3

## 🍴 Recipes

### lazy loading

- proper lazy loading with [lazy.nvim]

```lua
local leet_arg = "leetcode.nvim"

return {
    "kawre/leetcode.nvim",
    ...
    lazy = leet_arg ~= vim.fn.argv()[1],
    opts = {
        arg = leet_arg,
    },
    ...
}
```

## ✅ Todo

- \[ \] CN version
- \[ \] SQL support
- \[x\] Statistics menu page
- \[ \] Docs
- \[x\] Hints pop-up

## 🙌 Credits

- [Leetbuddy.nvim](https://github.com/Dhanus3133/Leetbuddy.nvim)

- [alpha-nvim](https://github.com/goolord/alpha-nvim)

[image.nvim]: https://github.com/3rd/image.nvim
[lazy.nvim]: https://github.com/folke/lazy.nvim
[leetcode]: https://leetcode.com
[leetcode.nvim]: https://github.com/kawre/leetcode.nvim
[neovim]: https://github.com/neovim/neovim
[nerd-font]: https://www.nerdfonts.com
[nui.nvim]: https://github.com/MunifTanjim/nui.nvim
[nvim-notify]: https://github.com/rcarriga/nvim-notify
[nvim-treesitter]: https://github.com/nvim-treesitter/nvim-treesitter
[nvim-web-devicons]: https://github.com/nvim-tree/nvim-web-devicons
[telescope.nvim]: https://github.com/nvim-telescope/telescope.nvim
