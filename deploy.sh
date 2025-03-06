#!/usr/bin/env bash
set -e  # 让脚本遇到错误立即退出

echo "🚀 开始部署应用..."

# 1️⃣ 彻底删除旧版本 nodejs 和 npm，防止依赖冲突
sudo apt-get remove --purge -y nodejs npm || true
sudo apt-get autoremove -y
sudo apt-get autoclean
sudo rm -rf /usr/lib/node_modules ~/.npm ~/.node-gyp /usr/local/lib/node_modules /usr/local/bin/npm /usr/local/bin/node /usr/bin/node

# 2️⃣ 确保系统更新
sudo apt-get update -y

# 3️⃣ 安装 Node.js 和 npm（从 Nodesource 官方源安装，避免 Ubuntu 旧版本）
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# 4️⃣ 确保 npm 可用（如果 `apt` 安装的 `npm` 不可用，使用 `npm` 官方安装）
if ! command -v npm &> /dev/null
then
    echo "⚠️ npm 未正确安装，尝试手动安装..."
    curl -L https://www.npmjs.com/install.sh | sudo bash
fi

# 5️⃣ 确保 pm2 可用
npm install -g pm2

# 6️⃣ 进入应用目录
cd ~/ExampleApplication

# 7️⃣ 安装 npm 依赖
npm install --legacy-peer-deps

# 8️⃣ 解决 npm 安全漏洞（⚠️ 避免影响 CircleCI 执行）
if [ -z "$CI" ]; then
  npm audit fix --force || true
fi

# 9️⃣ 重新创建 HTTPS 证书文件
echo "$PRIVATE_KEY" | sed 's/\\n/\n/g' > privatekey.pem
echo "$SERVER" | sed 's/\\n/\n/g' > server.crt

# 🔟 停止旧进程，启动新的进程
pm2 stop example_app || true
pm2 restart example_app || pm2 start ./bin/www --name example_app

# ✅ 持久化 PM2（防止服务器重启后丢失进程）
pm2 save
pm2 startup

echo "✅ 部署完成！"
