# Contributing to Safari Web Agent

欢迎贡献！无论是修 bug、加文档、提新功能，流程都很简单。

## 怎么贡献

### 提 Issue

- 🐛 **Bug**：描述你做了什么、期望什么、实际发生了什么
- 💡 **功能建议**：描述你的使用场景，为什么这个功能有用
- 📝 **文档改进**：哪里不清楚、缺少什么

### 提 PR

1. Fork 这个仓库
2. 创建分支：`git checkout -b feature/你的功能`
3. 改代码/文档
4. 确保 `python3 scripts/validate-skill.py` 通过
5. 提交 PR，描述你改了什么、为什么

### 项目结构

```
safari-web-agent/
├── SKILL.md              ← 核心 Skill 文件（Hermes 加载这个）
├── README.md             ← GitHub 首页
├── references/           ← 详细参考文档（Skill 按需加载）
├── templates/            ← 可复用的工作流模板
├── examples/             ← 真实场景示例
├── scripts/              ← 安装和验证脚本
└── assets/               ← 图片等静态资源
```

### 加新内容

- **新工作流模板** → `templates/` 目录
- **新示例** → `examples/` 目录
- **新参考文档** → `references/` 目录，并在 SKILL.md 末尾加链接
- **改核心 Skill** → 直接编辑 SKILL.md，CI 会自动验证格式

### 风格

- 中文优先，英文辅助
- 用具体示例代替抽象描述
- 代码块标明语言
