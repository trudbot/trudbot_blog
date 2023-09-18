#!/usr/bin/env sh
# author: trudbot
# Description: (debug | deploy git) script

if [ "$1" == "debug" ]; then
    echo "---------------- Debug Mode ----------------"
    hexo clean && hexo s
    exit
fi

hexo clean && hexo g

echo "------------------静态文件生成完毕， 开始替换jsdelivr cdn链接"
# 遍历指定目录及其子目录下的所有HTML文件
find ./public -type f -name "*.html" | while read -r file; do
    # 使用sed命令替换文件中的字符串
    sed -i 's#https://cdn.jsdelivr.net/#/#g' "$file"
    sed -i 's#//cdn.jsdelivr.net/#/#g' "$file"
    echo "替换文件：$file"
done
echo 'ok !'

hexo d
echo 'hexo deploy run is ok !'

git add *
time=$(date "+%Y-%m-%d")
git commit -m "${time}"
git push origin master