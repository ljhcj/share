#!/bin/bash

yum install epel-release vim git nodejs net-tools -y
wget https://raw.githubusercontent.com/ljhcj/share/master/lottery.tar.gz 
tar -xvf lottery.tar.gz

# 添加执行权限
chmod  -R +x lottery
cd lottery

# 安装插件
cd server
npm install

# 安装插件
cd ../product 
npm install

# 打包
npm start
cd dist

rm -rf index.html 
wget https://raw.githubusercontent.com/ljhcj/share/master/index.html

# 运行
node ../../server/index.js 80
