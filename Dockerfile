# ==================== 第一階段：下載二進位檔案 ====================
FROM alpine:3.23 AS builder

RUN apk add --no-cache curl unzip ca-certificates

# 下載最新 Xray
RUN curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip \
    && unzip /tmp/xray.zip -d /tmp \
    && mv /tmp/xray /usr/local/bin/xray-core \
    && chmod +x /usr/local/bin/xray-core

# === 修正後的下載 Caddy（使用 GitHub Releases，最穩定）===
RUN curl -L -o /tmp/caddy.tar.gz https://github.com/caddyserver/caddy/releases/latest/download/caddy_2.11.2_linux_amd64.tar.gz \
    && tar -xzf /tmp/caddy.tar.gz -C /tmp \
    && mv /tmp/caddy /usr/local/bin/caddy \
    && chmod +x /usr/local/bin/caddy

# ==================== 第二階段：極簡運行環境 ====================
FROM alpine:3.23

RUN apk add --no-cache ca-certificates \
    && rm -rf /var/cache/apk/*

ENV PORT=8080
WORKDIR /root

# 複製 Xray 和 Caddy
COPY --from=builder /usr/local/bin/xray-core /usr/local/bin/xray-core
COPY --from=builder /usr/local/bin/caddy /usr/local/bin/caddy

COPY startup.sh config.json.tp Caddyfile ./

RUN chmod +x startup.sh \
    && mkdir -p /root/html \
    && adduser -D -u 1000 appuser \
    && chown -R appuser:appuser /root

USER appuser

EXPOSE 8080

CMD ["/root/startup.sh"]
