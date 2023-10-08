<div align="center">

# leetcode.nvim

🔥 Solve [LeetCode] problems within [Neovim][neovim] 🔥

</div>

https://github.com/kawre/leetcode.nvim/assets/69250723/4647761c-609c-4b85-9396-535ae6baf3ba

[leetcode.nvim]: https://github.com/kawre/leetcode.nvim
[LeetCode]: https://leetcode.com
[neovim]: https://github.com/neovim/neovim

## ✨ Features

- 😍 Description formatting

- 📈 [LeetCode] statistics withing [Neovim][neovim] (Soon)

- 🔀 Support for daily and random questions

- 💾 Caching

## 📬 Requirements

- [Neovim][neovim]

- [nvim-treesitter][nvim-treesitter]

- [telescope.nvim][telescope.nvim]

- [nui.nvim][nui.nvim]

[nvim-treesitter]: https://github.com/nvim-treesitter/nvim-treesitter
[telescope.nvim]: https://github.com/nvim-telescope/telescope.nvim
[nui.nvim]: https://github.com/MunifTanjim/nui.nvim
[nvim-notify]: https://github.com/rcarriga/nvim-notify

## 📦 Installation

<!-- - [packer.nvim][packer.nvim] -->
<!---->
<!-- ```lua -->
<!-- use { -->
<!--   "kawre/leetcode.nvim", -->
<!--   run = ":TSUpdate html", -->
<!--   requires = { -->
<!--     "nvim-treesitter/nvim-treesitter", -->
<!--     "nvim-telescope/telescope.nvim", -->
<!--     "MunifTanjim/nui.nvim", -->
<!---->
<!--      - optional dependencies -->
<!--     "rcarriga/nvim-notify", -->
<!--     "nvim-tree/nvim-web-devicons", -->
<!--   }, -->
<!--   config = function() -->
<!--     require('leetcode').setup({ -->
<!--       -- configuration goes here -->
<!--     }) -->
<!--   end, -->
<!-- } -->
<!-- ``` -->

- [lazy.nvim][lazy.nvim]

```lua
{
  "kawre/leetcode.nvim",
  build = ":TSUpdate html",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim", -- required by telescope
    "MunifTanjim/nui.nvim",

    -- optional dependencies
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    -- configuration goes here
  },
}
```

[lazy.nvim]: https://github.com/folke/lazy.nvim
[packer.nvim]: https://github.com/wbthomason/packer.nvim

## 🛠️ Configuration

To see full configuration types see [template.lua](./lua/leetcode/config/template.lua)

### ⚙️ default configuration

<details>
  <summary>Click to see</summary>

```lua
{
    ---@type string
    arg = "leetcode.nvim",

    ---@type lc.lang
    lang = "cpp",

    ---@type lc.sql_lang
    sql = "mysql",

    ---@type lc.domain
    domain = "com",

    ---@type string
    directory = vim.fn.stdpath("data") .. "/leetcode/",

    ---@type boolean
    logging = true,

    console = {
        size = {
            width = "75%", ---@type string | integer
            height = "75%", ---@type string | integer
        },
        dir = "row", ---@type "col" | "row"

        result = {
            max_stdout_length = 200, ---@type integer
        },
    },

    description = {
        width = "40%", ---@type string | integer
    },
}
```

</details>

### arg

Argument for [Neovim][neovim] 


```lua
---@type string
arg = "leetcode.nvim"
```

<small>See [usage](#🚀-usage) for more info</small>

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

Where to store [leetcode.nvim][leetcode.nvim] data

```lua
---@type string
directory = vim.fn.stdpath("data") .. "/leetcode/"
```

### logging

Whether to log [leetcode.nvim][leetcode.nvim] status notifications

```lua
---@type boolean
logging = true
```

### console

Console appearance

```lua
console = {
    size = {
        width = "75%", ---@type string | integer
        height = "75%", ---@type string | integer
    },
    dir = "row", ---@type "col" | "row"

    result = {
        max_stdout_length = 200, ---@type integer
    },
}
```

### description

Question description appearance

```lua
description = {
    width = "40%", ---@type string | integer
}
```

## 🚀 Usage

This plugin is meant to be used within a <b>fresh</b> [Neovim][neovim] instance.
Meaning that to lauch [leetcode.nvim][leetcode.nvim] you <b>have</b> to pass [`arg`](#arg) as the <i>first and <b>only</b></i> [Neovim][neovim] argument

```
nvim leetcode.nvim
```

### Sign In

It is <b>required</b> to be <b>signed-in</b> to use [leetcode.nvim][leetcode.nvim]

https://github.com/kawre/leetcode.nvim/assets/69250723/13594f1d-fff6-444b-b128-29c8cf83e97f

<!-- ## 🍴 Recipes -->
<!---->
<!-- - Full lazy loading with [lazy.nvim] -->
<!---->
<!-- ```lua -->
<!-- local usr_arg = "leetcode.nvim" -->
<!---->
<!-- { -->
<!--     "kawre/leetcode.nvim", -->
<!--     ... -->
<!--     opts = { ..., arg = usr_arg, ... }, -->
<!--     cond = function() return usr_arg == vim.fn.argv()[1] end, -->
<!--     ... -->
<!-- } -->
<!-- ``` -->

### Switching between questions

When you open a new <b>question</b>, [leetcode.nvim] creates a new [tabpage] <i>containing
all of the <b>contents</b> related to it</i>.
To switch between these tabs, use [LcQuestionTabs](#📋-commands) command

https://github.com/kawre/leetcode.nvim/assets/69250723/b4407308-8c81-4b24-97e6-476f2da3b727

[tabpage]: https://neovim.io/doc/user/tabpage.html

## 📋 Commands

| command   | triggers    |
|--------------- | --------------- |
| LcMenu | opens menu dashboard |
| LcConsole | opens console for currently opened question |
| LcQuestionTabs | opens a picker with all currently opened question tabs |
| LcLanguage | opens a picker to select a language for the current session |

## ✅ Todo

- [ ] CN version
- [ ] SQL support
- [ ] Statistics menu page
