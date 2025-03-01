#!/bin/bash

# 检查证书更新
echo "检查证书更新..."
certbot renew --non-interactive

# 如果证书已更新，重新加载Nginx
if [ $? -eq 0 ]; then
    echo "证书已更新，重新加载Nginx..."
    nginx -s reload
else
    echo "证书未更新或更新失败"
fi