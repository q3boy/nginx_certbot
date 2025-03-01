#!/bin/bash
set -e

# 等待Nginx启动
sleep 5

# 定义域名变量（从环境变量获取，默认为example.com）
DOMAINS=${DOMAINS:-"example.com www.example.com"}
EMAIL=${EMAIL:-"admin@example.com"}
SELF_SIGNED_KEY_SIZE=${SELF_SIGNED_KEY_SIZE:-4096}
STAGING=${STAGING:-0}

# 首次运行时尝试获取证书
if [ ! -d "/etc/letsencrypt/live/$DOMAINS" ] || [ ! -f "/etc/letsencrypt/live/$DOMAINS/fullchain.pem" ]; then
    echo "尝试获取Let's Encrypt证书..."
    
    # 选择合适的参数
    staging_arg=""
    if [ $STAGING -eq 1 ]; then
        staging_arg="--staging"
    fi
    
    domain_args=""
    for domain in $DOMAINS; do
        domain_args="$domain_args -d $domain"
    done
    
    # 获取证书
    certbot certonly --webroot -w /var/www/certbot \
        $staging_arg \
        $domain_args \
        --email $EMAIL \
        --rsa-key-size $SELF_SIGNED_KEY_SIZE \
        --agree-tos \
        --force-renewal \
        --non-interactive
    
    # 重新加载Nginx以应用新证书
    nginx -s reload
fi

# 定期检查证书更新
while :; do
    echo "等待12小时后检查证书更新..."
    sleep 12h
    
    echo "检查证书更新..."
    certbot renew --non-interactive
    
    # 如果证书已更新，重新加载Nginx
    if [ $? -eq 0 ]; then
        echo "证书已更新，重新加载Nginx..."
        nginx -s reload
    fi
done 