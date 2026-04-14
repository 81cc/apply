#!/bin/sh

echo "🚀 [START] Starting VLESS + WS + Caddy on Apply.Build..."

# 生成 config.json
if [ -f "/root/config.json.tp" ]; then
    envsubst < /root/config.json.tp > /root/config.json
    echo "✅ config.json generated"
    echo "   UUID used: ${UUID:-NOT SET}"
else
    echo "❌ ERROR: config.json.tp not found!"
fi

# 準備首頁
mkdir -p /root/html
if [ ! -f "/root/html/index.html" ]; then
    echo '<h1>VLESS + WS + Caddy is running ✅</h1>' > /root/html/index.html
fi

echo "Starting Xray (VLESS + WS)..."
xray run -c /root/config.json 2>&1 | tee /var/log/xray.log &

echo "Starting Caddy..."
caddy run --config /root/Caddyfile --adapter caddyfile 2>&1 | tee /var/log/caddy.log &

echo "======================================"
echo "All services launched. Tailing logs..."
echo "======================================"

# 同時顯示兩個 log，讓 Apply.Build 能看到
tail -f /var/log/xray.log /var/log/caddy.log
