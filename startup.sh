#!/bin/sh

if [ -z "$UUID" ]; then
    UUID=$(cat /proc/sys/kernel/random/uuid)
    echo "=== Generated new UUID: $UUID ==="
fi
export UUID

echo "Generating config.json..."
envsubst < /root/config.json.tp > /root/config.json

# 生成簡單首頁
if [ ! -f "/root/html/index.html" ]; then
    cat > /root/html/index.html << EOF
<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="UTF-8"><title>Xray WS</title></head>
<body>
    <h1>Xray + WS 代理運行正常</h1>
    <p>端口: ${PORT}</p>
    <p>UUID: ${UUID}</p>
</body>
</html>
EOF
fi

echo "=== Starting Xray + Caddy ==="

/usr/local/bin/xray-core run -c /root/config.json &

sleep 4

exec /usr/local/bin/caddy run --config /root/Caddyfile --adapter caddyfile
