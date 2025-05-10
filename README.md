# upargo

## 📦 项目简介

本项目是甬哥 [yonggekkk](https://github.com/yonggekkk) 的 ArgoSB 项目的后续增强工具。

在执行甬哥的脚本后，可使用本项目脚本将订阅信息自动上传至 GitLab，实现通过 GitLab 的订阅链接进行更新。

若使用过程中 **Token 与项目名保持不变**，则 **无需手动复制订阅内容**，只需刷新订阅链接即可完成更新。

> 🔁 当前仅支持上传并覆盖 `jh.txt`文件，Clash\_meta 与 sing-box 的适配功能尚在开发中，暂不可用。

---

## 🛠 项目配置提醒

* 请确保在 GitLab 项目设置中：

  * <b><span style="color:red;">Settings → Repository → Protected branches 中启用 Allowed to force push</span></b>
  * <b><span style="color:red;">使用 GitLab Token 时，请如实保存生成记录，脚本中不会存储或上传该信息</span></b>

---

## 🚀 一行命令快速上传

你可以通过设置环境变量的方式，快速执行上传命令：

```bash
TOKEN="your-token" GIT_USER="your-name" GIT_EMAIL="your-email" PROJECT="your-project" bash <(curl -Ls https://raw.githubusercontent.com/guangwit9/upargo/main/upargo.sh)
```

将以上命令中的 `your-token`、`your-name`、`your-email`、`your-project` 替换为你自己的 GitLab 信息。

---

## 🧪 交互方式（备用）

如果你未设置环境变量，也可以直接执行以下命令，脚本将引导你手动输入相关信息：

```bash
bash <(curl -Ls https://raw.githubusercontent.com/guangwit9/upargo/main/upargo.sh)
```

---

## 🔐 安全与隐私说明

本脚本为公开上传工具，仅在用户本地运行，不会收集或上传任何用户信息。
使用者输入的 GitLab Token、用户名、邮箱、项目名等仅用于本地 Git 操作。
脚本不会将任何数据发送至第三方服务器（包括脚本发布者本人）。

运行本脚本的用户，完全无需担心会被上传订阅链接，与你其他用户互不交，订阅链接不会被其他人看到或传送给脚本编写者。

如有安全须要，可以使用 curl 查看脚本源码：

```bash
curl -Ls https://raw.githubusercontent.com/guangwit9/upargo/main/upargo.sh | less
```

建议使用具有最小权限的 GitLab Token，并在使用后立即撤销。

---

## 📚 技术来源与参考

此项目参考了登取兄（yonggekkk）关于 GitLab 订阅链接的相关资料，
并结合 ChatGPT 自动化脚本生成技术，开发出本地自动上传工具，支持用户更高效地管理订阅文件。
