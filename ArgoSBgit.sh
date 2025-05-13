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
echo -e "\033[1;32m    curl -Ls https://raw.githubusercontent.com/guangwit9/ArgoSBgit/main/ArgoSBgit.sh | less\033[0m" # Indented for clarity
echo -e "\033[1;31m==============================================================\033[0m"

: "${TOKEN:=}"
: "${GIT_USER:=}"
: "${GIT_EMAIL:=}"
: "${PROJECT:=}"

[ -z "$TOKEN" ] && read -p "请输入 GitLab Token: " TOKEN
[ -z "$GIT_USER" ] && read -p "请输入 GitLab 用户名: " GIT_USER
[ -z "$GIT_EMAIL" ] && read -p "请输入 GitLab 邮箱: " GIT_EMAIL
[ -z "$PROJECT" ] && read -p "请输入 GitLab 项目名: " PROJECT

TMP_DIR="/tmp/idx_upload"
# Updated FILES array as per your request
FILES=(
  "/etc/s-box-ag/sb.json"
  "/etc/s-box-ag/jh.txt"
  "/etc/s-box-ag/list.txt"
  "/home/user/nixag/jh.txt"
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

# Clone the repository
echo "正在克隆仓库 https://gitlab.com/$GIT_USER/$PROJECT.git ..."
git clone "https://oauth2:$TOKEN@gitlab.com/$GIT_USER/$PROJECT.git"
cd "$PROJECT" || { echo "错误：项目不存在或路径错误，无法进入 $PROJECT 目录。请检查 GitLab 用户名、项目名和 Token。"; exit 1; }

declare -A unique_basenames # Associative array to store unique basenames
processed_files_basenames=() # Array to store basenames in processing order for the commit message

echo "正在处理和复制文件..."
for FILE_PATH in "${FILES[@]}"; do
  BASENAME=$(basename "$FILE_PATH")
  echo "处理: $FILE_PATH -> 将作为 $BASENAME 复制到仓库根目录"
  sudo cp "$FILE_PATH" "./$BASENAME"
  # Apply sed command to the copied file in the current directory
  sed -i 's/ \{1,\}/ /g' "./$BASENAME"
  # Store unique basenames for git add
  unique_basenames["$BASENAME"]=1
done

# Construct the list of files for git add and the commit message
GIT_ADD_TARGETS=""
COMMIT_MSG_FILES_LIST=""

# Get basenames from the unique_basenames associative array
# This ensures each distinct basename is added only once, reflecting the final state in the repo
for bn in "${!unique_basenames[@]}"; do
  GIT_ADD_TARGETS+="$bn "
  # For commit message, ensure consistent ordering if possible (bash associative array order is not guaranteed)
  # For simplicity, we'll list them. Sorting could be added if specific order is critical.
  if [ -z "$COMMIT_MSG_FILES_LIST" ]; then
    COMMIT_MSG_FILES_LIST="$bn"
  else
    COMMIT_MSG_FILES_LIST="$COMMIT_MSG_FILES_LIST, $bn"
  fi
done
GIT_ADD_TARGETS=${GIT_ADD_TARGETS% } # Remove trailing space

if [ -z "$GIT_ADD_TARGETS" ]; then
  echo "警告：没有唯一的文件名被处理以进行 git 操作。"
else
  echo "准备将以下文件添加到 Git: $GIT_ADD_TARGETS"
  git add $GIT_ADD_TARGETS
  COMMIT_MESSAGE="更新 $COMMIT_MSG_FILES_LIST $(date '+%Y-%m-%d %H:%M:%S')"
  echo "执行 Git 提交，消息: \"$COMMIT_MESSAGE\""
  git commit -m "$COMMIT_MESSAGE" || echo "无变化可提交（或者提交失败）。"
  echo "正在推送到远程仓库..."
  git push origin main --force 2>/dev/null || git push origin master --force
fi

echo -e "\033[1;32m==============================================================\033[0m"
echo -e "\033[1;32m你的私人订阅链接：\033[0m"

# Link for /etc/s-box-ag/list.txt (repo filename: list.txt)
echo -e "\033[1;33m链接 /etc/s-box-ag/list.txt (仓库中文件名: list.txt):\033[0m"
echo -e "https://gitlab.com/api/v4/projects/$GIT_USER%2F$PROJECT/repository/files/list.txt/raw?ref=main&private_token=$TOKEN"

# Link for /home/user/nixag/jh.txt (repo filename: jh.txt)
# Note: This will be the content from /home/user/nixag/jh.txt because it's processed last
# and will overwrite /etc/s-box-ag/jh.txt if both are copied as 'jh.txt'.
echo -e "\033[1;33m链接 /home/user/nixag/jh.txt (仓库中文件名: jh.txt):\033[0m"
echo -e "https://gitlab.com/api/v4/projects/$GIT_USER%2F$PROJECT/repository/files/jh.txt/raw?ref=main&private_token=$TOKEN"

echo -e "\033[1;32m==============================================================\033[0m"
echo "脚本执行完毕。"
