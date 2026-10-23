# 推送交接说明 —— 由你在自己的终端完成最后一步

整合仓库已在你机器上**搭好并完成本地提交**，只差「推到你的 GitHub」。
这一步需要你的 GitHub 身份/仓库/凭据，本机没有配，所以交给你亲手跑。

## 仓库位置
```
D:\deepseek ha\workbuddy-connect
```

## 当前状态（我已替你完成）
- `git init` ✅（工作树干净，nothing to commit）
- 分支：`main`
- 本地提交：`1ec200d  workbuddy-connect: 整合 0.7.9 快照 + 本地模型目录/品牌改写补丁 + 桌面接入脚本`
- 内容：`package/`(0.7.9 npm 快照) + `patches/`(本地增强补丁) + `scripts/`(桌面接入/升级) + `docs/` + `README.md`

## 你要做的（在你的终端 / cmd 里逐条执行）

### ① 进目录
```bat
cd /d "D:\deepseek ha\workbuddy-connect"
```

### ② 改成你自己的 GitHub 身份（替换占位符）
```bat
git config user.name  "你的GitHub用户名"
git config user.email "你绑定的邮箱"
```

### ③ 关联远程仓库（替换占位符为你的仓库地址）
```bat
git remote add origin https://github.com/你的用户名/workbuddy-connect.git
```

> 若你想用自己的组织：`https://github.com/你的组织/workbuddy-connect.git`
> 仓库 `workbuddy-connect` 需先在 GitHub 网页上新建（可留空、不带 README，避免冲突）。

### ④ 推送（首次推会弹 GitHub 登录/授权窗口，或要求输入 Personal Access Token）
```bat
git push -u origin main
```

> **凭据说明**：本机 `git config --global credential.helper` 为空、无 `~/.ssh`、无 `~/.git-credentials`，
> 所以 push 时会让你登录。二选一：
> - HTTPS：在弹出的窗口用浏览器账号登录（推荐）；若命令行要求，则用 GitHub → Settings → Developer settings
>   → Personal access tokens 生成 `repo` 权限的 token 当密码。
> - 或先 `ssh-keygen` 并 `ssh-add`，把公钥加到 GitHub，再改用 SSH 地址 `git@github.com:你的用户名/workbuddy-connect.git`。

### ⑤（可选）确认远程分支
```bat
git remote -v
git branch -vv
```

## 完成后验证
浏览器打开 `https://github.com/你的用户名/workbuddy-connect`，应能看到 README、package 快照、patches、scripts。

## 遇到 `push rejected / fetch first`（远程已有历史）
说明远程仓库非空。用下面命令把本地历史强行覆盖为当前内容：
```bat
git push -u origin main --force
```
（仅限这是全新仓库、你确定要以上档历史为准时使用。）

## 本机确实无凭据（复核）
- `gh` CLI：未安装
- `git config user.name / user.email`：原为空（我已设仓库级占位，推前按②改）
- `credential.helper`：空
- `~/.ssh/*`：无
- `~/.git-credentials`：无

所以第④步的登录/授权是必经的，我不代跑，以免拿到/触碰你的凭据。