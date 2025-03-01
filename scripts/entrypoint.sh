#!/bin/bash
set -e

# 处理env.conf.template文件，替换环境变量
echo "处理env.conf.template文件..."
if [ -f "/etc/nginx/env.conf.template" ]; then
    # 创建临时文件
    cp /etc/nginx/env.conf.template /tmp/env.conf.tmp

    # 查找所有__VARIABLE__格式的变量并替换
    for var in $(grep -o "__[A-Z0-9_]*__" /etc/nginx/env.conf.template | sort | uniq); do
        # 提取变量名（去掉前后的__）
        env_var=$(echo "$var" | sed 's/__//g')
        # 获取环境变量的值
        env_value=${!env_var}

        # 如果环境变量存在，则替换
        if [ ! -z "$env_value" ]; then
            echo "替换 $var 为 $env_value"
            sed -i "s|$var|$env_value|g" /tmp/env.conf.tmp
        else
            echo "警告: 环境变量 $env_var 未定义，保持原样"
        fi
    done

    # 将处理后的文件移动到最终位置
    mv /tmp/env.conf.tmp /etc/nginx/env.conf
    echo "env.conf文件已更新"
else
    echo "警告: env.conf.template文件不存在"
fi

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

# 确保Nginx SSL目录存在，并创建符号链接
mkdir -p /etc/nginx/ssl
if [ ! -f "/etc/nginx/ssl/dhparam.pem" ]; then
    echo "创建DH参数文件符号链接..."
    ln -sf /etc/letsencrypt/ssl-dhparams.pem /etc/nginx/ssl/dhparam.pem
fi

# 设置日志轮询的定时任务
echo "设置日志轮询定时任务..."
echo "0 0 * * * /usr/sbin/logrotate /etc/logrotate.d/nginx" > /etc/crontabs/root

# 设置证书更新的定时任务（每12小时执行一次）
echo "设置证书更新定时任务..."
echo "0 */12 * * * /scripts/certbot-renew.sh" >> /etc/crontabs/root

# 启动cron服务
crond


# 仅在没有COMPOSE环境变量时执行
if [ -z "$COMPOSE" ]; then
    # 通过docker run 启动时，添加本地域名解析，方便本地测试
    echo "添加本地域名解析（仅在非COMPOSE环境下执行）..."
    echo "127.0.0.1 n8n frps ntfy" >> /etc/hosts
fi

# 首次运行证书获取脚本
echo "首次运行证书获取脚本..."
/scripts/certbot-sign.sh &

# 启动Nginx
echo "启动Nginx..."
nginx -g "daemon off;"