FROM alpine:3.23

RUN apk update && apk add --no-cache \
    curl jq unzip ca-certificates \
    caddy \
    && rm -rf /var/cache/apk/*

# 安裝 Xray（推薦比 v2ray 更穩定）
RUN curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip \
    && unzip /tmp/xray.zip -d /usr/local/bin/ \
    && mv /usr/local/bin/xray /usr/local/bin/xray-core \
    && chmod +x /usr/local/bin/xray-core \
    && rm -f /tmp/xray.zip

ENV PORT=8080

WORKDIR /root

# 複製檔案
COPY startup.sh config.json.tp Caddyfile ./

RUN chmod +x startup.sh \
    && mkdir -p /root/html

# 非 root 用戶
RUN adduser -D -u 1000 appuser && chown -R appuser /root
USER appuser

EXPOSE 8080

CMD ["/root/startup.sh"]
