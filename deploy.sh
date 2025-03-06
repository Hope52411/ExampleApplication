#!/usr/bin/env bash
set -e  # 让脚本遇到错误立即退出

echo "🚀 开始部署应用..."

# 1️⃣ 彻底删除旧版本 nodejs 和 npm，防止依赖冲突
sudo apt-get remove --purge -y nodejs npm
sudo rm -rf /usr/lib/node_modules ~/.npm ~/.node-gyp /usr/local/lib/node_modules /usr/local/bin/npm /usr/local/bin/node /usr/bin/node

# 2️⃣ 安装 NVM 并使用 Node.js 20
curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 20
nvm use 20
nvm alias default 20

# 3️⃣ 确保 npm 可用
npm install -g npm

# 4️⃣ 确保 pm2 可用
npm install -g pm2

# 5️⃣ 进入应用目录
cd ~/ExampleApplication

# 6️⃣ 安装 npm 依赖
npm install --legacy-peer-deps

# 7️⃣ 解决 npm 安全漏洞（可选）
npm audit fix --force

# 8️⃣ 重新创建 HTTPS 证书文件
echo "$PRIVATE_KEY" | sed 's/\\n/\n/g' > privatekey.pem
echo "$SERVER" | sed 's/\\n/\n/g' > server.crt

# 9️⃣ 停止旧进程，启动新的进程
pm2 stop example_app || true
pm2 restart example_app || pm2 start ./bin/www --name example_app

# 🔟 持久化 PM2（防止服务器重启后丢失进程）
pm2 save
pm2 startup

echo "✅ 部署完成！"
