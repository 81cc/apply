#!/bin/sh

echo "=== [Apply.Build] Starting Xray + Caddy ==="

# ====================== UUID 處理 ======================
if [ -z "$UUID" ]; then
    UUID=$(cat /proc/sys/kernel/random/uuid)
    echo "=== Generated new UUID: $UUID ==="
fi
export UUID

# ====================== 生成 Xray 配置 ======================
echo "Generating config.json from template..."
envsubst < /root/config.json.tp > /root/config.json

# 檢查 config.json 是否成功生成
echo "=== Config check ==="
if [ ! -s "/root/config.json" ]; then
    echo "ERROR: config.json is empty! Creating fallback config..."
    cat > /root/config.json << EOF
{
  "inbounds": [
    {
      "port": 8081,
      "protocol": "vless",
      "settings": {
        "clients": [{"id": "${UUID}", "level": 0}],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none"
      }
    }
  ],
  "outbounds": [{"protocol": "freedom"}]
}
EOF
else
    echo "config.json generated successfully. Size: $(wc -c < /root/config.json) bytes"
fi

# ====================== 生成首頁 ======================
mkdir -p /root/html
cat > /root/html/index.html << EOF
<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="UTF-8"><title>Xray WS Proxy</title></head>
<body>
    <h1>Xray + WS 代理運行正常 ✅</h1>
    <p>服務端口: ${PORT}</p>
    <p>UUID: ${UUID}</p>
    <p>WebSocket 路徑: /ws</p>
    <hr>
    <p>適用於 Apply.Build 部署</p>
</body>
</html>
EOF

echo "=== Starting services ==="

# 啟動 Xray
echo "Starting Xray (WS on 8081)..."
/usr/local/bin/xray-core run -c /root/config.json &

# 等待 Xray 完全啟動
sleep 6

# 啟動 Caddy（作為主進程）
echo "Starting Caddy on port ${PORT} with /ws path..."
exec /usr/local/bin/caddy run --config /root/Caddyfile --adapter caddyfile
