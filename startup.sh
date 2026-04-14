#!/bin/sh

echo "🚀 Starting VLESS + WS + Caddy on Render..."

# 生成 config.json（從模板替換變數）
if [ -f "/root/config.json.tp" ]; then
    envsubst < /root/config.json.tp > /root/config.json
    echo "✅ config.json generated"
fi

# 生成簡單首頁（如果沒有）
if [ ! -f "/root/html/index.html" ]; then
    mkdir -p /root/html
    echo '<h1>VLESS + WS + Caddy is running</h1><p>Proxy service active.</p>' > /root/html/index.html
fi

# 啟動 Xray（VLESS WS）
xray run -c /root/config.json &
echo "Xray (VLESS) started"

# 啟動 Caddy（反代 + HTTPS）
caddy run --config /root/Caddyfile --adapter caddyfile &
echo "Caddy started"

wait
