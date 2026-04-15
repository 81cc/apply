#!/bin/sh

echo "=== [Apply.Build] Starting Xray + Caddy ==="

# UUID 處理
if [ -z "$UUID" ]; then
    UUID=$(cat /proc/sys/kernel/random/uuid)
    echo "=== Generated new UUID: $UUID ==="
fi
export UUID

# 生成 config.json
echo "=== Generating config.json ==="
envsubst < /root/config.json.tp > /root/config.json

echo "=== Config file check ==="
ls -l /root/config.json
if [ -s "/root/config.json" ]; then
    echo "config.json size: $(wc -c < /root/config.json) bytes"
    echo "First 10 lines:"
    head -n 10 /root/config.json
else
    echo "ERROR: config.json is empty!"
fi

# 生成首頁
mkdir -p /root/html
cat > /root/html/index.html << EOF
<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="UTF-8"><title>Xray WS</title></head>
<body>
    <h1>Xray + WS 代理運行正常 ✅</h1>
    <p>端口: ${PORT}</p>
    <p>UUID: ${UUID}</p>
    <p>WS 路徑: /ws</p>
</body>
</html>
EOF

echo "=== Starting Xray (port 8081) ==="
/usr/local/bin/xray-core run -c /root/config.json &
XRAY_PID=$!
sleep 8
echo "Xray process PID: $XRAY_PID"

# 檢查 Xray 是否還在運行
if ps -p $XRAY_PID > /dev/null; then
    echo "✅ Xray is running"
else
    echo "❌ Xray process exited unexpectedly!"
fi

echo "=== Starting Caddy on port ${PORT} ==="
exec /usr/local/bin/caddy run --config /root/Caddyfile --adapter caddyfile
