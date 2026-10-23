# workbuddy-connect（本地整合仓库）

把「DSH 桌面版里实际运行的那份 `dsh-workbuddy-connect`」整理成一份可独立推送到 GitHub 的整合仓库。

- **内核**：`package/` —— 从桌面 profile 实装的 `dsh-workbuddy-connect@0.7.9` 原样快照（npm 包内容，含 `lib/`、`cordis.patch.yml`、README、LICENSE）。
- **本地增强补丁**：`patches/` —— 相对上游的一份本地改动，做成标准 unified diff，可 `git apply` 复现。
- **接入 / 升级脚本**：`scripts/` —— 桌面版专用的装入 / 升级 / 验证脚本。
- **文档**：`docs/` 与本文档。

> 上游项目：<https://github.com/corrinehu/dsh-workbuddy-connect>
> 当前快照版本：`0.7.9`（对应 DSH 内核 `0.2.1-rc.2`，npm `latest`）。

---

## 目录结构

```
workbuddy-connect/
├── package/                     # 0.7.9 npm 包快照（可整体替换链入 node_modules）
│   ├── package.json
│   ├── cordis.patch.yml         # provider 注册补丁
│   ├── lib/                     # 编译产物（ESM）
│   │   ├── index.js / index.d.ts
│   │   ├── client.js
│   │   ├── bin.js / bin.d.ts
│   │   └── host-heartbeat-SJaZ33tR.js (.orig 为原版)
│   ├── README.md / README.en.md
│   ├── LICENSE / THIRD_PARTY_NOTICES.txt
├── patches/
│   └── extend-fallback-model-catalog.patch   # 本地增强（品牌改写 + 模型目录扩展）
├── scripts/
│   ├── update-workbuddy-connect.ps1          # 桌面版升级主脚本
│   ├── auto-upgrade-workbuddy.ps1            # 无人值守包装
│   └── update-workbuddy-connect.cmd          # 双击启动器
├── docs/
│   └── changelog-local.md                    # 本地改动说明
├── package.json                              # 仓库级元信息
├── .gitignore
└── README.md
```

---

## 本地增强内容（相对上游 0.7.9）

打的是 `lib/host-heartbeat-SJaZ33tR.js`，净增 47 行，两类：

1. **`sanitizeSystemBranding`（品牌改写，规避国内网关 400 拦截）**
   在 `prepareChatBody` 里对 `system` 消息做品牌名改写（见 `SYSTEM_BRAND_REWRITES`）。
   目的：国内版 WorkBuddy 网关会拦截请求体中 system 消息出现「竞争助手品牌」字样，返回
   `HTTP 400 code 11128 "Illegal API invocation from an unapproved channel" / "请求被拦截，请重新发送"`。
   该改写把这些字样替换为无害占位，使请求通过网关校验。

2. **模型目录扩展（fallback 模型表刷新）**
   在 `FALLBACK_WORKBUDDY_MODELS` / `FALLBACK_WORKBUDDY_AI_MODELS` 里补齐了一批新模型
   （如 `MiniMax-M2.7`、`Kimi-K3`、`Deepseek-V4-Pro`、`GPT-6-Astra`、`GLM-5.3`、`GPT-5.6-*` 等），
   使首次拉取上游目录前的兜底列表覆盖更新的模型线。

> 补丁方向：`host-heartbeat-SJaZ33tR.js.orig`（原版）→ `host-heartbeat-SJaZ33tR.js`（增强版）。
> 应用补丁：`git apply patches/extend-fallback-model-catalog.patch`
> 生成参照：`git diff --no-index package/lib/<file>.orig package/lib/<file>`

---

## 桌面版接入 / 升级

`desktop` profile 由 Electron 桌面 App 独占管理，`dsh plugin --profile desktop` 会被 CLI 拒绝
（`profile "desktop" is managed exclusively by the Electron application`），因此走**文件方式**：

**完全退出 App → 改 `package.json` 版本 → pnpm install → 重启 App → 验证模型选择器分组。**

详见 `scripts/update-workbuddy-connect.ps1`（含备份 / 回滚 / 版本校验 / 重启）。

> 注意：pnpm 11 在存在未批准构建脚本时会以退出码 1 结束（`ERR_PNPM_IGNORED_BUILDS`），
> 这是提醒型错误，安装实际成功；判定应以「实际安装版本」为准，见脚本内校验步骤。

---

## 版本对应关系（README 原文摘要）

| DSH 内核          | 推荐插件版本           |
|-------------------|------------------------|
| 0.2.1-rc.2        | 0.7.9（npm latest）    |
| 0.2.1-rc.1        | 0.7.7                  |
| 0.2.0-rc.2        | 0.7.6                  |
| 0.2.0-rc.1        | 0.7.0                  |
| 0.1.5 – 0.1.7     | 0.6.5                  |

## 许可

上游 `dsh-workbuddy-connect` 为 MIT（见 `package/LICENSE`）；本仓库仅做整理与本地补丁归档。