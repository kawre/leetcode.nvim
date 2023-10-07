<div align="center">

# leetcode.nvim

Solve LeetCode problems within Neovim

</div>

https://github.com/kawre/leetcode.nvim/assets/69250723/4647761c-609c-4b85-9396-535ae6baf3ba

[leetcode.nvim]: https://github.com/kawre/leetcode.nvim

## ✨ Features

- 🔥 Question description formatting

- 📈 LeetCode statistics withing neovim (Soon)

- 🔀 Support for daily and random questions

- 💾 Caching

## 📬 Requirements

- [nvim-treesitter][nvim-treesitter]

- [telescope.nvim][telescope.nvim]

- [nui.nvim][nui.nvim]

[nvim-treesitter]: https://github.com/nvim-treesitter/nvim-treesitter
[telescope.nvim]: https://github.com/nvim-telescope/telescope.nvim
[nui.nvim]: https://github.com/MunifTanjim/nui.nvim
[nvim-notify]: https://github.com/rcarriga/nvim-notify

## 📦 Installation

- [lazy.nvim][lazy.nvim]

  ```lua
  {
    "kawre/leetcode.nvim",
    build = ":TSUpdate html",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim",
      "MunifTanjim/nui.nvim",

      -- optional dependencies
      "rcarriga/nvim-notify",
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

### arg

Argument to pass to Neovim 

```lua
---@type string
arg = "leetcode.nvim"
```

### lang

Language to start your [leetcode.nvim][leetcode.nvim] session with

```lua
---@type lc.lang
lang = "cpp"

---@type lc.sql_lang
sql = "mysql"
```

### domain

LeetCode domain.

```lua
---@type lc.domain
domain = "com" -- For now "com" is only supported
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

## 🚀 Usage

This plugin is meant to be used within a fresh neovim instance.
Meaning that to lauch [leetcode.nvim][leetcode.nvim] you have to pass [`arg`](#arg) as the neovim argument

```
nvim leetcode.nvim
```

### Sign In

It is required to be signed-in to use [leetcode.nvim][leetcode.nvim]

https://github-production-user-asset-6210df.s3.amazonaws.com/69250723/273407175-6a972621-7782-42eb-b7f7-02c0e6c05a59.mp4?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20231007%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20231007T201135Z&X-Amz-Expires=300&X-Amz-Signature=c33a2877a4c44f51419a579efa5973161205606ab12874d0225d0fc514fe7897&X-Amz-SignedHeaders=host&actor_id=69250723&key_id=0&repo_id=692404712

## 📋 Commands

| command   | triggers    |
|--------------- | --------------- |
| LcMenu | opens menu dashboard |
| LcConsole | opens console for currently opened question |
| LcQuestionList | opens a picker with all currently opened questions |
| LcLanguage | opens a prompt to select a new language for the current session |

## ✅ Todo

- [ ] CN version
- [ ] full sql support
