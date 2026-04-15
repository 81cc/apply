#!/bin/sh

# ====================== UUID 處理 ======================
if [ -z "$UUID" ]; then
    UUID=$(cat /proc/sys/kernel/random/uuid)
    echo "=== Generated new UUID: $UUID ==="
fi
export UUID

# 生成 Xray config
echo "Generating config.json..."
envsubst < /root/config.json.tp > /root/config.json

# 生成簡單首頁
if [ ! -f "/root/html/index.html" ]; then
    echo "Generating index.html..."
    cat > /root/html/index.html << EOF
<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="UTF-8"><title>Xray WS Proxy</title></head>
<body>
    <h1>Xray + WS 代理運行正常</h1>
    <p>服務端口: ${PORT}</p>
    <p>UUID: ${UUID}</p>
    <hr>
    <p>適用於 Apply.Build 部署</p>
</body>
</html>
EOF
fi

echo "=== Starting Xray + Caddy ==="

# 啟動 Xray (內部 WS 端口 8081)
echo "Starting Xray on 8081 (WS)..."
/usr/local/bin/xray-core run -c /root/config.json &

# 等待 Xray 啟動
sleep 4

# 以 foreground 方式啟動 Caddy（這是主進程）
echo "Starting Caddy on external port ${PORT}..."
exec caddy run --config /root/Caddyfile --adapter caddyfile
