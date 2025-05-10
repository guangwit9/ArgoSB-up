#!/bin/bash

echo -e "\033[1;31m==============================================================\033[0m"
echo -e "\033[1;33m请确保在 GitLab 项目设置中：\033[0m"
echo -e "\033[1;33m1. 将项目的 Settings -> Repository -> Protected branches 中的 'Allowed to force push' 打开。\033[0m"
echo -e "\033[1;33m2. 请务必记录下 GitLab Token 生成记录，以备后续使用。\033[0m"
echo -e "\033[1;31m==============================================================\033[0m"
echo
echo -e "\033[1;35m==============================================================\033[0m"
echo -e "\033[1;35m此项目参考了甬哥（yonggekkk）关于 GitLab 订阅链接的相关资料，\033[0m"
echo -e "\033[1;35m以及 ChatGPT 自动化脚本生成技术。\033[0m"
echo -e "\033[1;35m==============================================================\033[0m"
echo
echo -e "\033[1;31m==============================================================\033[0m"
echo -e "\033[1;32m本脚本为公开上传工具，仅在用户本地运行，不会收集或上传任何用户信息。\033[0m"
echo -e "\033[1;32m使用者输入的 GitLab Token、用户名、邮箱、项目名等仅用于本地 Git 操作。\033[0m"
echo -e "\033[1;32m本脚本不会将任何数据发送至第三方服务器（包括脚本发布者本人）。\033[0m"
echo -e "\033[1;32m如有安全顾虑，可通过 curl 查看源码：\033[0m"
echo -e "\033[1;32m    curl -Ls https://raw.githubusercontent.com/guangwit9/upargo/main/upargo.sh | less\033[0m"
echo -e "\033[1;31m==============================================================\033[0m"
echo "按任意键继续..."
read -n1 -s
clear

# === 用户交互输入（支持预设环境变量） ===
: "${TOKEN:=}"
: "${GIT_USER:=}"
: "${GIT_EMAIL:=}"
: "${PROJECT:=}"

[ -z "$TOKEN" ] && read -p "请输入 GitLab Token: " TOKEN
[ -z "$GIT_USER" ] && read -p "请输入 GitLab 用户名: " GIT_USER
[ -z "$GIT_EMAIL" ] && read -p "请输入 GitLab 邮箱: " GIT_EMAIL
[ -z "$PROJECT" ] && read -p "请输入 GitLab 项目名: " PROJECT

TMP_DIR="/tmp/idx_upload"
FILES=(
  "/etc/s-box-ag/sb.json"
  "/etc/s-box-ag/jh.txt"
)

# === 设置 Git 用户身份 ===
git config --global user.name "$GIT_USER"
git config --global user.email "$GIT_EMAIL"

# === 确保文件存在 ===
for FILE in "${FILES[@]}"; do
  if [ ! -f "$FILE" ]; then
    echo "错误：找不到文件 $FILE"
    exit 1
  fi
done

# === 给文件添加时间戳 ===
echo "// upload time: $(date '+%Y-%m-%d %H:%M:%S')" | sudo tee -a /etc/s-box-ag/sb.json > /dev/null
echo "# upload time: $(date '+%Y-%m-%d %H:%M:%S')" | sudo tee -a /etc/s-box-ag/jh.txt > /dev/null

# === 清理旧临时目录 ===
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"
cd "$TMP_DIR" || exit 1

# === 克隆 GitLab 仓库 ===
git clone https://oauth2:$TOKEN@gitlab.com/$GIT_USER/$PROJECT.git
cd "$PROJECT" || { echo "项目不存在或路径错误"; exit 1; }

# === 拷贝文件 ===
for FILE in "${FILES[@]}"; do
  BASENAME=$(basename "$FILE")
  sudo cp "$FILE" "./$BASENAME"
done

# === 添加、提交并推送 ===
git add sb.json jh.txt
git commit -m "自动更新 sb.json 与 jh.txt 文件 $(date '+%Y-%m-%d %H:%M:%S')" || echo "无变化可提交"
git push origin main 2>/dev/null || git push origin master
