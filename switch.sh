#!/usr/bin/env sh
# author: trudbot
# Description: invalid cdn switch script

echo "---------------- Invalid CDN switch local path file ----------------"
# 遍历指定目录及其子目录下的所有HTML文件
find ./public -type f -name "*.html" | while read -r file; do
    # 使用sed命令替换文件中的字符串
    sed -i 's#https://cdn.jsdelivr.net/#/#g' "$file"
    sed -i 's#//cdn.jsdelivr.net/#/#g' "$file"
    echo "替换文件：$file"
done
echo 'ok !'