#!/bin/sh

echo "🚀 Starting services on Apply.Build..."

# 替換 config.json 中的 $UUID（如果還有）
if grep -q "\$UUID" /root/config.json; then
    UUID=${UUID:-$(cat /proc/sys/kernel/random/uuid)}
    sed -i "s|\$UUID|${UUID}|g" /root/config.json
    echo "Generated UUID: ${UUID}"
fi

# 啟動 Xray（VLESS + WS） - 後台運行
xray -c /root/config.json &
XRAY_PID=$!
echo "Xray started (PID: ${XRAY_PID})"

# 啟動 Caddy（反向代理 + 靜態文件）
caddy run --config /root/Caddyfile --adapter caddyfile &
CADDY_PID=$!
echo "Caddy started (PID: ${CADDY_PID})"

# 啟動 Node.js Hello World（可選，如果你想保留首頁）
node /root/app.js &

# 保持容器運行
wait
