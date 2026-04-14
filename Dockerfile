FROM alpine:3.23

RUN apk update && \
    apk add --no-cache \
        nodejs \
        npm \
        curl \
        wget \
        unzip \
        jq \
        ca-certificates && \
    # 下載最新 Xray
    XRAY_VERSION=$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases/latest | grep '"tag_name"' | cut -d '"' -f 4) && \
    wget -O /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}/Xray-linux-64.zip && \
    unzip /tmp/xray.zip -d /usr/local/bin && \
    mv /usr/local/bin/xray /usr/local/bin/xray && \
    chmod +x /usr/local/bin/xray && \
    rm /tmp/xray.zip && \
    # 下載最新 Caddy
    curl -L -o /usr/local/bin/caddy "https://caddyserver.com/api/download?os=linux&arch=amd64" && \
    chmod +x /usr/local/bin/caddy && \
    rm -rf /var/cache/apk/*

ENV PORT=8080

COPY app.js /root/app.js
COPY Caddyfile /root/Caddyfile
COPY config.json.tp /root/config.json.tp
COPY startup.sh /startup.sh

RUN chmod +x /startup.sh && \
    adduser -D -u 1000 appuser && \
    chown -R appuser /root /usr/local/bin

USER appuser

EXPOSE 8080

CMD ["/startup.sh"]
