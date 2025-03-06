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

# 3️⃣ 安装 Node.js 和 npm（从 Nodesource 官方源安装）
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# 4️⃣ 确保 npm 可用（如果 `apt` 安装的 `npm` 不能用，就用 `npm` 官方脚本安装）
if ! command -v npm &> /dev/null
then
    echo "⚠️ npm 未正确安装，尝试手动安装..."
    curl -L https://www.npmjs.com/install.sh | sudo bash
fi

# 5️⃣ 解决 `npm` 权限问题，确保全局安装时不会报 `EACCES`
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
export PATH=~/.npm-global/bin:$PATH
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc

# 6️⃣ 确保 npm 是最新版本
npm install -g npm@latest

# 7️⃣ 安装 pm2（⚠️ 用 `sudo` 确保不会有权限错误）
sudo npm install -g pm2

# 8️⃣ 进入应用目录
cd ~/ExampleApplication

# 9️⃣ 安装 npm 依赖
npm install --legacy-peer-deps

# 🔟 解决 npm 安全漏洞（⚠️ 避免影响 CircleCI 执行）
if [ -z "$CI" ]; then
  npm audit fix --force || true
fi

# 1️⃣1️⃣ 重新创建 HTTPS 证书文件
echo "$PRIVATE_KEY" | sed 's/\\n/\n/g' > privatekey.pem
echo "$SERVER" | sed 's/\\n/\n/g' > server.crt

# 1️⃣2️⃣ 停止旧进程，启动新的进程
pm2 stop example_app || true
pm2 restart example_app || pm2 start ./bin/www --name example_app

# 1️⃣3️⃣ 持久化 PM2（防止服务器重启后丢失进程）
pm2 save
pm2 startup

echo "✅ 部署完成！"
