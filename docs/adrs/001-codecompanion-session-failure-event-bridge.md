# CodeCompanion Session Failure Event Bridge

日期: 2026-06-07

相关背景:

- [README.md](../../README.md)
- `leetcode-qa` 中 submission service 的 session-bound companion memory 设计

## 背景

这个 fork 里的 `CodeCompanion` 集成不是一个独立 agent runtime。

它的目标是:

- `leetcode.nvim` 提供题目上下文和 UI bridge
- 真正的 LLM provider / model / prompt / session memory 由 submission service 持有

当用户在 companion chat 打开之后又触发了一次失败测试，如果 chat 里看不到这次 failure event，就会出现:

- 当前 companion chat 不知道刚刚失败了什么
- 用户只能手动再描述一遍
- chat buffer 和 submission service 的 active session lifecycle 脱节

## 决策

### 1. `leetcode.nvim` 只做 bridge，不做 LLM ownership

`lua/leetcode/integrations/codecompanion.lua` 的职责是:

- 从当前题目页收集 LeetCode context
- 打开 CodeCompanion chat
- 以隐藏 context 形式注入题面、testcase、当前代码
- 把 chat 绑定到当前 `title_slug`

它不拥有:

- provider 选择
- model 选择
- companion system prompt
- solve session truth

这些都由 submission service 决定。

### 2. 当前 companion chat 按 `title_slug` 绑定

bridge 需要记住“这道题当前对应哪个 CodeCompanion chat”。

当前实现用 `title_slug -> chat instance` 的内存映射来做这件事。

这样 submission-related hook 收到 failure event 时，才能把 event 投到正确的 chat，而不是任意最后一个 chat。

### 3. failure event 由 submission service 生成，nvim 负责渲染

submission service 在 `analyze_failure` 成功后返回稳定的 `event_id`。

`leetcode.nvim` 不自己发明 failure id，也不自己推导“哪次 failure 才算最新”。

客户端只做两件事:

1. 把 `<leetcode_failure:<event_id>>` 作为隐藏 context 加到当前 chat
2. 在 chat buffer 里追加一条可见提示，说明这次 failure event 已经挂进当前会话

### 4. failure event 通过现有 analyze_failure 客户端链路自动投递

当前自动投递入口放在 `leetcode-qa/lua/submission_db_saver.lua` 的 `analyze_failure()` 回调里。

也就是说，只要某次 test / submit failure 最终走到了这条分析路径，并且服务端返回了 `event_id`，bridge 就会自动尝试把它注入当前 companion chat。

### 5. 失败事件默认作为隐藏 context，而不是普通聊天正文

因为这条信息本质上是 solve lifecycle 里的结构化上下文，不是用户输入的自由文本。

把它作为隐藏 context 的好处:

- 不污染用户正在看的可见聊天正文
- 可以被 submission service 的 companion endpoint 稳定识别
- 可以避免它被误当成普通 user question

## 结果

现在 `leetcode.nvim` 里的 companion 行为分成两段:

1. 打开 chat 时注入 `LeetCode Problem Context`
2. failure 发生并分析成功后，再注入 `LeetCode Failure Event`

这让单个 CodeCompanion chat 能跟上同一道题在 solve lifecycle 里的最新 failure state。

## 当前边界

- 这个 bridge 只保证“同题目当前 chat”会收到 event
- 它不负责跨题会话恢复
- 它不负责 failure event 的长期持久化
- 它不自己请求 LLM 来解释 failure，解释仍由 submission service 返回

## 后续约束

- 新增 companion 相关功能时，优先沿用 `title_slug` 绑定，而不是退回“last chat”这种弱绑定
- 新增 session-aware context 时，优先走隐藏 context 注入
- 如果 submission service 扩展了更多 session event，客户端优先复用服务端给的 stable ids / payloads，而不是本地重建语义
