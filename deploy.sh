#!/usr/bin/env bash

# 更新系统 & 安装 Node.js 和 npm（避免 nodejs 和 npm 依赖冲突）
sudo apt update
sudo apt install -y nodejs npm --fix-broken

# 安装 pm2（强制重新安装，防止损坏）
sudo npm install -g pm2

# 确保旧的 pm2 进程被正确停止
pm2 stop example_app || true

# 进入应用目录
cd ExampleApplication

# 确保 npm 依赖安装成功（避免 `peer dependencies` 失败）
npm install --legacy-peer-deps
# 写入 HTTPS 证书（确保环境变量正确解析）
echo $PRIVATE_KEY > privatekey.pem
echo $SERVER > server.crt

# 启动或重启 pm2 进程
pm2 restart example_app || pm2 start ./bin/www --name example_app

# 持久化 PM2（防止服务器重启后应用丢失）
pm2 save
pm2 startup
