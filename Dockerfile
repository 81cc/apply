# ==================== 第一階段：下載二進位檔案 ====================
FROM alpine:3.23 AS builder

RUN apk add --no-cache curl unzip ca-certificates

# 下載最新 Xray
RUN curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip \
    && unzip /tmp/xray.zip -d /tmp/xray \
    && chmod +x /tmp/xray/xray \
    && mv /tmp/xray/xray /usr/local/bin/xray-core

# 下載官方 Caddy (alpine 版，已經靜態編譯)
RUN curl -L -o /usr/local/bin/caddy https://caddyserver.com/api/download?os=linux&arch=amd64 \
    && chmod +x /usr/local/bin/caddy

# ==================== 第二階段：極簡運行環境 ====================
FROM alpine:3.23

# 只安裝極少必要依賴（主要是 ca-certificates）
RUN apk add --no-cache ca-certificates \
    && rm -rf /var/cache/apk/*

ENV PORT=8080
WORKDIR /root

# 複製 Xray 和 Caddy
COPY --from=builder /usr/local/bin/xray-core /usr/local/bin/xray-core
COPY --from=builder /usr/local/bin/caddy /usr/local/bin/caddy

# 複製你的配置檔案
COPY startup.sh config.json.tp Caddyfile ./

RUN chmod +x startup.sh \
    && mkdir -p /root/html \
    && adduser -D -u 1000 appuser \
    && chown -R appuser:appuser /root

USER appuser

EXPOSE 8080

CMD ["/root/startup.sh"]
