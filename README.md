# upargo

## 📦 项目简介

本项目是甬哥 [yonggekkk](https://github.com/yonggekkk) 的 ArgoSB 项目的后续增强工具。

在执行甬哥的脚本后，可使用本项目脚本将订阅信息自动上传至 GitLab，实现通过 GitLab 的订阅链接进行更新。

若使用过程中 **Token 与项目名保持不变**，则 **无需手动复制订阅内容**，只需刷新订阅链接即可完成更新。

> 🔁 当前仅支持上传并覆盖 `jh.txt` 文件，Clash_meta 与 sing-box 的适配功能尚在开发中，暂不可用。

---

## 🚀 一行命令快速上传

你可以通过设置环境变量的方式，快速执行上传命令：

```bash
TOKEN="your-token-here" GIT_USER="your-name" GIT_EMAIL="your-email" PROJECT="your-project" bash <(curl -Ls https://raw.githubusercontent.com/guangwit9/upargo/main/upargo.sh)
```

将以上命令中的 `your-token-here`、`your-name`、`your-email`、`your-project` 替换为你自己的 GitLab 信息。

---

## 🧪 交互方式（备用）

如果你未设置环境变量，也可以直接执行以下命令，脚本将引导你手动输入相关信息：

```bash
bash <(curl -Ls https://raw.githubusercontent.com/guangwit9/upargo/main/upargo.sh)
```

---

## 🛠 项目配置提醒

* 请确保在 GitLab 项目设置中：

  * Settings -> Repository -> Protected branches 中打开 `Allowed to force push`
  * 使用 GitLab Token 时，请妥善保存生成记录，脚本中不会存储或上传该信息

---

## 📚 技术来源与参考

此项目参考了甬哥（yonggekkk）关于 GitLab 订阅链接的相关资料，
并结合 ChatGPT 自动化脚本生成技术，开发出本地自动上传工具，支持用户更高效地管理订阅文件。
