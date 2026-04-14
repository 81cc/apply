#!/bin/sh

# 替換模板中的環境變量
envsubst < /root/config.json.tp > /root/config.json
envsubst < /root/Caddyfile.tp > /root/Caddyfile

# 生成首頁
if [ ! -f "/root/html/index.html" ]; then
    echo "Generating random Wikipedia page..."
    randomurl=$(curl -sL 'https://en.wikipedia.org/api/rest_v1/page/random/summary' | jq -r '.content_urls.desktop.page')
    curl -sL "$randomurl" -o /root/html/index.html
fi

# 啟動 V2Ray 與 Caddy
/v2ray/v2ray -config /root/config.json &

# 確保 V2Ray 啟動
sleep 2

# 啟動 Caddy
caddy run --config /root/Caddyfile
