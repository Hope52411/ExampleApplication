#!/usr/bin/env bash
set -e  # 让脚本遇到错误立即退出

echo "🚀 开始部署应用..."

# 更新系统 & 解决 npm 依赖问题
sudo apt update
sudo apt remove -y nodejs npm
sudo apt install -y nodejs npm --fix-broken

# 重新安装 pm2（确保它没有损坏）
sudo npm install -g pm2

# 进入应用目录
cd ~/ExampleApplication

# 确保 npm 依赖能正确安装（避免 peer dependencies 问题）
npm install --legacy-peer-deps

# 解决 npm 安全漏洞（可选）
npm audit fix --force

# 重新创建 HTTPS 证书文件
echo "$PRIVATE_KEY" | sed 's/\\n/\n/g' > privatekey.pem
echo "$SERVER" | sed 's/\\n/\n/g' > server.crt

# 停止旧进程，启动新的进程
pm2 stop example_app || true
pm2 restart example_app || pm2 start ./bin/www --name example_app

# 持久化 PM2（防止服务器重启后丢失进程）
pm2 save
pm2 startup

echo "✅ 部署完成！"
