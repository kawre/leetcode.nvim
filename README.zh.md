<div align="center">

# leetcode.nvim

🔥 在 [Neovim] 中解决 [LeetCode] 问题 🔥

🇺🇸 <a href="README.md">English</a>, 🇨🇳 简体中文

</div>

https://github.com/kawre/leetcode.nvim/assets/69250723/aee6584c-e099-4409-b114-123cb32b7563

> [!CAUTION]
> 此插件仅与`Java`进行了专门测试。
> 如果您在使用其他语言时遇到任何错误，请打开一个问题报告它们。

## ✨ 特性

- 📌 直观的仪表板，轻松导航 [leetcode.nvim] 内

- 😍 更好的可读性的问题描述格式

- 📈 在 [Neovim] 中显示 [LeetCode] 个人统计信息

- 🔀 支持每日和随机问题

- 💾 缓存以优化性能

## 📬 环境要求

- [Neovim] >= 0.9.0

- [telescope.nvim]

- [nui.nvim]

- [nvim-treesitter] _**(可选，但强烈推荐)**_
  用于格式化问题描述。
  确保安装 `html` 解析器。

- [nvim-notify] _**(可选)**_

- [Nerd Font][nerd-font] & [nvim-web-devicons] _**(可选)**_

## 📦 安装

- [lazy.nvim]

```lua
{
    "kawre/leetcode.nvim",
    build = ":TSUpdate html",
    dependencies = {
        "nvim-telescope/telescope.nvim",
        "nvim-lua/plenary.nvim", -- telescope 所需
        "MunifTanjim/nui.nvim",

        -- 可选
        "nvim-treesitter/nvim-treesitter",
        "rcarriga/nvim-notify",
        "nvim-tree/nvim-web-devicons",
    },
    opts = {
        -- 配置放在这里
        cn = {
            enabled = true,
        },
    },
}
```

## 🛠️ 配置

要查看完整的配置类型，请参见 [template.lua](./lua/leetcode/config/template.lua)

### ⚙️ 默认配置

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

[Neovim] 的参数

```lua
---@type string
arg = "leetcode.nvim"
```

<small>有关更多信息，请参见 [usage](#-usage)</small>

### lang

会话开始时使用的语言

```lua
---@type lc.lang
lang = "cpp"
```

<details>
  <summary>可用编程语言</summary>

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

将 [leetcode.com][leetcode] 替换为 [leetcode.cn]

```lua
cn = { -- leetcode.cn
    enabled = false, ---@type boolean
    translator = true, ---@type boolean
    translate_problems = true, ---@type boolean
},
```

### storage

存储目录

```lua
---@type lc.storage
storage = {
    home = vim.fn.stdpath("data") .. "/leetcode",
    cache = vim.fn.stdpath("cache") .. "/leetcode",
},
```

### plugins

[插件列表](#-plugins)

```lua
---@type table<string, boolean>
plugins = {
    non_standalone = false,
},
```

### logging

是否记录 [leetcode.nvim] 状态通知

```lua
---@type boolean
logging = true
```

### injector

在你的答案前后注入额外代码，注入的代码不会被提交或测试。

#### 默认导入

您还可以传递 `before = true` 以注入语言的默认导入。
支持的语言为 `python`、`python3`、`java`

通过 `require("leetcode.config.imports")` 访问默认导入

```lua
injector = { ---@type table<lc.lang, lc.inject>
    ["cpp"] = {
        before = { "#include <bits/stdc++.h>", "using namespace std;" },
        after = "int main() {}",
    },
    ["java"] = {
        before = "import java.util.*;",
    },
}
```

### hooks

在指定事件上执行的函数列表

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

覆盖[默认主题](./lua/leetcode/theme/default.lua)

每个值都与 `:help nvim_set_hl` 中的val参数相同类型

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

是否使用 [image.nvim] 渲染问题描述中的图片

> [!WARNING]
> 启用此选项将禁用问题描述的换行，因为
> https://github.com/3rd/image.nvim/issues/62#issuecomment-1778082534

```lua
---@type boolean
image_support = false, -- 将此设置为 `true` 将禁用问题描述的换行
```

## 📋 命令

### `Leet` 打开菜单仪表板

- `menu` 与 `Leet` 相同

- `exit` 关闭 [leetcode.nvim]

- `console` 打开当前打开问题的控制台弹出窗口

- `info` 打开包含当前打开问题信息的弹出窗口

- `tabs` 打开所有当前打开问题选项卡的选择器

- `yank` 复制当前问题的解决方案

- `lang` 打开更改当前问题语言的选择器

- `run` 运行当前打开的问题

- `test` 与 `Leet run` 相同

- `submit` 提交当前打开的问题

- `random` 打开一个随机问题

- `daily` 打开今天的问题

- `list` 打开问题列表选择器

- `open` 在默认浏览器中打开当前问题

- `reset` 还原到默认的代码模版

- `last_submit` 检索上次提交的代码，用于当前问题

- `restore` 尝试恢复默认问题布局

- `inject` 重新注入当前问题的代码

- `session`

  - `create` 创建一个新的会话

  - `change` 更改当前会话

  - `update` 更新当前会话，以防它失去同步

- `desc` 切换问题描述

  - `toggle` 与 `Leet desc` 相同

  - `stats` 切换描述统计可见性

- `cookie`

  - `update` 打开提示输入新 cookie

  - `delete` 注销

- `cache`

  - `update` 更新缓存

#### 可以带有可选参数。要堆叠参数值，请使用 `,` 将它们分隔开

- `Leet list`

  ```
  Leet list status=<status> difficulty=<difficulty>
  ```

- `Leet random`

  ```
  Leet random status=<status> difficulty=<difficulty> tags=<tags>
  ```

## 🚀 使用方法

该插件可以通过两种方式启动：

- 要启动 [leetcode.nvim]，只需将 [`arg`](#arg)
  作为 第一个且唯一 [Neovim] 参数传递

  ```
  nvim leetcode.nvim
  ```

- _**(实验性)**_ 另外，您可以使用 `:Leet` 命令在您喜欢的仪表板插件中打开
  [leetcode.nvim]。唯一的要求是 [Neovim] 不能有任何列出的缓冲区打开。

### 切换问题

要在问题之间切换，请使用 `Leet tabs`。

### 登录

使用 [leetcode.nvim] 必须 **登录**

https://github.com/kawre/leetcode.nvim/assets/69250723/b7be8b95-5e2c-4153-8845-4ad3abeda5c3

## 🍴 示例

### 💤 使用 [lazy.nvim] 进行延迟加载

> [!WARNING]
> 选择其中任一选项将由于延迟加载而使另一启动方法不可用。

- 使用 [`arg`](#arg)

  ```lua
  local leet_arg = "leetcode.nvim"
  ```

  ```lua
  {
      "kawre/leetcode.nvim",
      lazy = leet_arg ~= vim.fn.argv()[1],
      opts = { arg = leet_arg },
  }
  ```

- 使用 `:Leet`

  ```lua
  {
      "kawre/leetcode.nvim",
      cmd = "Leet",
  }
  ```

## 🧩 Plugins

### Non-Standalone mode

要在非独立模式下运行 [leetcode.nvim]（即不带参数或在空的 Neovim 会话中运行），
请在您的配置中启用 `non_standalone` 插件：

```lua
plugins = {
    non_standalone = true,
}
```

你可以使用 `:Leet exit` 命令退出 [leetcode.nvim]

## 🙌 鸣谢

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
[nvim-notify]: https://github.com/rcarriga/nvim-notify
[nvim-treesitter]: https://github.com/nvim-treesitter/nvim-treesitter
[nvim-web-devicons]: https://github.com/nvim-tree/nvim-web-devicons
[telescope.nvim]: https://github.com/nvim-telescope/telescope.nvim
