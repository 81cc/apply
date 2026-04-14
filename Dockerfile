FROM node:20-bullseye

# 安裝工具
RUN apt-get update && \
    apt-get install -y curl jq wget unzip && \
    rm -rf /var/lib/apt/lists/*

# 安裝 Caddy
RUN wget -O /usr/bin/caddy "https://github.com/caddyserver/caddy/releases/download/v2.8.5/caddy_2.8.5_linux_amd64" && \
    chmod +x /usr/bin/caddy

# 安裝 V2Ray
RUN mkdir -p /v2ray && \
    wget -O /tmp/v2ray.zip "https://github.com/v2fly/v2ray-core/releases/download/v5.4.1/v2ray-linux-64.zip" && \
    unzip /tmp/v2ray.zip -d /v2ray && \
    chmod +x /v2ray/v2ray /v2ray/v2ctl && \
    rm /tmp/v2ray.zip

WORKDIR /root

# 拷貝代碼
COPY . /root
RUN mkdir -p /root/html
RUN chmod +x /root/start.sh

# 暴露 Heroku 提供的端口
EXPOSE 8080

CMD ["/root/start.sh"]
