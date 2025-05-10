#!/bin/bash

# === 收集用户输入 ===
read -p "请输入 GitLab Token: " TOKEN
read -p "请输入 Git 用户名: " GIT_USER
read -p "请输入 Git 邮箱: " GIT_EMAIL
read -p "请输入 GitLab 项目名: " PROJECT

TMP_DIR="/tmp/idx_upload"
FILES=(
  "/etc/s-box-ag/sb.json"
  "/etc/s-box-ag/jh.txt"
)

# === 设置 Git 用户信息 ===
git config --global user.name "$GIT_USER"
git config --global user.email "$GIT_EMAIL"

# === 给文件添加时间戳注释，确保内容变化 ===
echo "// upload time: $(date '+%Y-%m-%d %H:%M:%S')" | sudo tee -a /etc/s-box-ag/sb.json > /dev/null
echo "# upload time: $(date '+%Y-%m-%d %H:%M:%S')" | sudo tee -a /etc/s-box-ag/jh.txt > /dev/null

# === 清理并准备临时目录 ===
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"
cd "$TMP_DIR"

# === 克隆仓库 ===
git clone https://oauth2:$TOKEN@gitlab.com/$GIT_USER/$PROJECT.git
cd "$PROJECT" || { echo "项目不存在或路径错误"; exit 1; }

# === 拷贝并覆盖文件 ===
for FILE in "${FILES[@]}"; do
  BASENAME=$(basename "$FILE")
  sudo cp "$FILE" "./$BASENAME"
done

# === Git 提交并推送 ===
git add sb.json jh.txt
git commit -m "Force update sb.json and jh.txt"
git push origin main || git push origin master
