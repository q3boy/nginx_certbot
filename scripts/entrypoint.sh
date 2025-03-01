#!/bin/bash
set -e

# 创建初始自签名证书（如果不存在）
if [ ! -d "/etc/letsencrypt/live" ]; then
    echo "初始化自签名证书..."
    mkdir -p /etc/letsencrypt/live/example.com
    
    # 生成自签名证书
    openssl req -x509 -nodes -newkey rsa:4096 -days 1 \
        -keyout /etc/letsencrypt/live/example.com/privkey.pem \
        -out /etc/letsencrypt/live/example.com/fullchain.pem \
        -subj "/CN=example.com" \
        -addext "subjectAltName = DNS:example.com,DNS:www.example.com"
    
    # 创建SSL参数文件
    curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > /etc/letsencrypt/options-ssl-nginx.conf
    curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > /etc/letsencrypt/ssl-dhparams.pem
fi

# 设置日志轮询的定时任务
echo "设置日志轮询定时任务..."
echo "0 0 * * * /usr/sbin/logrotate /etc/logrotate.d/nginx" > /etc/crontabs/root
crond

# 启动证书更新脚本
echo "启动证书自动更新..."
/scripts/certbot-renew.sh &

# 启动Nginx
echo "启动Nginx..."
nginx -g "daemon off;" 