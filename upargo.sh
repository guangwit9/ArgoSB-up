#!/bin/bash

echo "=============================================================="
echo " 本脚本为公开上传工具，仅在用户本地运行，不会收集或上传任何用户信息。"
echo " 使用者输入的 GitLab Token、用户名、邮箱、项目名等仅用于本地 Git 操作。"
echo " 本脚本不会将任何数据发送至第三方服务器（包括脚本发布者本人）。"
echo " 如有安全顾虑，可通过 curl 查看源码："
echo "     curl -Ls https://raw.githubusercontent.com/guangwit9/upargo/main/upargo.sh | less"
echo " 建议使用具有最小权限的 GitLab Token，使用后可随时撤销。"
echo "=============================================================="
echo
echo "按任意键继续..."
read -n1 -s
clear

# === 用户交互输入 ===
read -p "请输入 GitLab Token: " TOKEN
read -p "请输入 Git 用户名: " GIT_USER
read -p "请输入 Git 邮箱: " GIT_EMAIL
read -p "请输入 GitLab 项目名: " PROJECT

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

# === 给文件添加时间戳（确保 Git 有变更）===
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
