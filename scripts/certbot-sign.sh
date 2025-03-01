#!/bin/bash
set -e

# 等待Nginx启动
sleep 10

DOMAINS="${MAIN_DOMAIN} ${N8N_DOMAIN} ${NTFY_DOMAIN} ${FRPS_DOMAIN}"
EMAIL=${EMAIL:-"admin@example.com"}
SELF_SIGNED_KEY_SIZE=${SELF_SIGNED_KEY_SIZE:-4096}
STAGING=${STAGING:-0}

# 选择合适的参数
staging_arg=""
if [ $STAGING -eq 1 ]; then
    staging_arg="--staging"
fi

CERT_UPDATE_STATUS=0
for domain in $DOMAINS; do
    if [ ! -d "/etc/letsencrypt/live/$domain" ] || [ ! -f "/etc/letsencrypt/live/$domain/fullchain.pem" ]; then
        echo "$domain 证书尝试获取中 ..."
        # 获取证书
        certbot certonly --webroot -w /var/www/certbot \
            $staging_arg \
            -d $domain \
            --email $EMAIL \
            --rsa-key-size $SELF_SIGNED_KEY_SIZE \
            --agree-tos \
            --force-renewal \
            --non-interactive
        if [ $? -eq 0 ]; then
            echo "$domain 证书获取成功"
            CERT_UPDATE_STATUS=1
        else
            echo "$domain 证书获取失败"
        fi
    else
        echo "$domain 证书已存在，跳过获取"
    fi
done

if [ $CERT_UPDATE_STATUS -eq 1 ]; then
    # 重新加载Nginx以应用新证书
    nginx -s reload
fi
