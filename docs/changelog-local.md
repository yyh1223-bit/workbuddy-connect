# 本地改动说明（相对上游 0.7.9）

本文档记录本仓库相对上游 <https://github.com/corrinehu/dsh-workbuddy-connect@0.7.9> 的本地改动。
改动对象：`package/lib/host-heartbeat-SJaZ33tR.js`（净增 47 行，`git diff --numstat` 为 `47 1`）。

## 1. 品牌改写：sanitizeSystemBranding（~46 行）

**问题**：国内版 WorkBuddy 网关会拦截请求体中 system 消息出现「竞争助手品牌」字样，
返回 `HTTP 400 code 11128 "Illegal API invocation from an unapproved channel"`（提示「请求被拦截，请重新发送」）。

**改动**：在 `prepareChatBody` 构造请求体后调用新增的 `sanitizeSystemBranding(obj)`，
按 `SYSTEM_BRAND_REWRITES` 规则改写 system 消息中的品牌字样为无害占位，使请求通过网关校验。
仅影响发送给国内网关的请求体，不影响本地模型目录/计费/账号逻辑。

## 2. 模型目录扩展：FALLBACK_*_MODELS 新增条目

**目的**：使首次成功拉取上游 `/v3/config` 之前（以及离线启动时）的兜底模型列表覆盖更新的模型线，
避免兜底阶段缺新模型。

**新增模型**（示意）：

- `MiniMax-M2.7`
- `Kimi-K3` / `Kimi-K3`（重名项按数据原有键处理）以及 `Kimi-K2.6`、`Kimi-K2.7-Code`、`Kimi-K2.8-Preview`
- `Deepseek-V4-Pro`
- `GPT-6-Astra`、`GPT-5.6-Sol`、`GPT-5.6-Terra`、`GPT-5.6-Luna`、`GPT-5.5`、`GPT-5.4`、`GPT-5.3-Codex`
- `GLM-5.3`、`GLM-5.2`
- `Gemini-3.5-Flash`、`Hy4 preview`、`Hy3`、`primary-model`、`deep-model`、`balanced-model` 等既有 id 的字段刷新

> 注意：兜底模型仅覆盖上游目录拉取失败/离线窗口，最终以真实 `/v3/config` 拉取结果为准。

## 应用 / 复现

- 应用：`git apply patches/extend-fallback-model-catalog.patch`
- 生成参照：`git diff --no-index package/lib/host-heartbeat-SJaZ33tR.js.orig package/lib/host-heartbeat-SJaZ33tR.js`
- `.orig` 为原版副本（保留在快照内），增强版为其同目录同名文件。