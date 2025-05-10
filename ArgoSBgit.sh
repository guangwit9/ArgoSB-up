#!/bin/bash

echo -e "\033[1;31m==============================================================\033[0m"
echo -e "\033[1;33m请确保在 GitLab 项目设置中：\033[0m"
echo -e "\033[1;33m1. 将项目的 \033[1;31mSettings -> Repository -> Protected branches\033[0m 中的 '\033[1;31mAllowed to force push\033[0m' 打开。\033[0m"
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
echo -e "\033[1;32m    curl -Ls https://raw.githubusercontent.com/guangwit9/ArgoSBgit/main/ArgoSBgit.sh | less\033[0m"
echo -e "\033[1;31m==============================================================\033[0m"
echo "按任意键继续..."
read -n1 -s
clear

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

git config --global user.name "$GIT_USER"
git config --global user.email "$GIT_EMAIL"

for FILE in "${FILES[@]}"; do
  if [ ! -f "$FILE" ]; then
    echo "错误：找不到文件 $FILE"
    exit 1
  fi
done

rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"
cd "$TMP_DIR" || exit 1

git clone https://oauth2:$TOKEN@gitlab.com/$GIT_USER/$PROJECT.git
cd "$PROJECT" || { echo "项目不存在或路径错误"; exit 1; }

for FILE in "${FILES[@]}"; do
  BASENAME=$(basename "$FILE")
  sudo cp "$FILE" "./$BASENAME"
  # 替换一下空格 -> 空格（骗 Git 认为内容变了）
  sed -i 's/ \{1,\}/ /g' "./$BASENAME"
done

git add sb.json jh.txt
git commit -m "更新 sb.json 与 jh.txt $(date '+%Y-%m-%d %H:%M:%S')" || echo "无变化可提交"
git push origin main --force 2>/dev/null || git push origin master --force

echo -e "\033[1;32m==============================================================\033[0m"
echo -e "\033[1;32m你的私人订阅链接：\033[0m"
echo -e "https://gitlab.com/api/v4/projects/$GIT_USER%2F$PROJECT/repository/files/jh.txt/raw?ref=main&private_token=$TOKEN"
echo -e "\033[1;32m==============================================================\033[0m"
