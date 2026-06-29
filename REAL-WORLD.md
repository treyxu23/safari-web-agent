## 真实场景

这些是本工具在真实项目中用过的场景：

| 场景 | 网站 | 效果 |
|------|------|------|
| 🛒 电商后台数据导出 | 拼多多卖家中心（已登录） | 自动翻页抓取订单列表 → CSV，原来 2 小时 → 30 秒 |
| 🔍 AI 工具每日发现 | ProductHunt（Cloudflare 保护） | 每天自动抓取 AI 话题前 20 个工具，用于选题 |
| 📝 Notion 长文填写 | Notion（ProseMirror 编辑器） | `native_type` 填入 3000 字不丢内容，`fill()` 必丢 |
| 🎬 在线课程信息提取 | 之了课堂（腾讯云 VOD DRM） | 绕过 DRM 页面，提取课程列表和元数据 |
| 🧪 GitHub Token 创建自动化 | GitHub Settings（sudo 模式） | 自动填表、勾选 scope、生成 PAT |

> 你的场景是什么？[提 Issue](https://github.com/treyxu23/trey-safari-web-agent/issues/new) 告诉我们。
