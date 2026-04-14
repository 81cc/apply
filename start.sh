#!/bin/sh

# 替換 V2Ray config 模板中的環境變量
envsubst < /root/config.json.tp > /root/config.json
# 如果需要，也可以替換 Caddyfile 中的 $PORT
envsubst < /root/Caddyfile.tp > /root/Caddyfile

# 自動生成首頁
if [ -e "/root/html/index.html" ]; then
    echo "index.html exists, skip generating index page"
else
    echo "Generating random Wikipedia page..."
    randomurl=$(curl -sL 'https://en.wikipedia.org/api/rest_v1/page/random/summary' | jq -r '.content_urls.desktop.page')
    curl -sL "$randomurl" -o /root/html/index.html
fi

# 啟動 V2Ray 和 Caddy
# V2Ray 使用內部端口 8080，Caddy 對外暴露 $PORT
/v2ray/v2ray -config /root/config.json &

# 等待 V2Ray 啟動
sleep 2

# 啟動 Caddy
caddy run --config /root/Caddyfile
