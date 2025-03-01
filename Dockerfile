FROM alpine:3.18

ENV TZ=Asia/Shanghai
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV EMAIL=admin@example.com
ENV STAGING=1
ENV SELF_SIGNED_KEY_SIZE=4096

# 安装必要的软件包
RUN apk add --no-cache \
    nginx \
    certbot \
    certbot-nginx \
    openssl \
    bash \
    curl \
    python3 \
    py3-pip \
    logrotate

# 创建必要的目录
RUN mkdir -p /var/www/certbot \
    && mkdir -p /etc/nginx/conf.d \
    && mkdir -p /etc/letsencrypt \
    && mkdir -p /var/lib/letsencrypt \
    && mkdir -p /var/www/html \
    && mkdir -p /var/www/favicon

# 设置日志轮询配置
COPY ./scripts/logrotate-nginx.conf /etc/logrotate.d/nginx

# 复制html文件
COPY ./html/ /var/www/html/

# 复制favicon文件
COPY ./nginx/favicon/ /var/www/favicon/

# 复制配置文件
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./nginx/env.conf.template /etc/nginx/env.conf.template
COPY ./nginx/conf.d/ /etc/nginx/conf.d/


# 复制脚本
COPY ./scripts/ /scripts/

# 设置权限
RUN chmod +x /scripts/*.sh

# 暴露端口
EXPOSE 80 443

# 启动脚本
CMD ["/scripts/entrypoint.sh"]