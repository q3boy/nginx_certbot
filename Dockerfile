FROM alpine:3.18

ENV TZ=Asia/Shanghai
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV DOMAINS=www.example.com
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
    && mkdir -p /var/www/html

# 复制配置文件
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./conf.d/ /etc/nginx/conf.d/
COPY ./scripts/ /scripts/
COPY ./html/ /var/www/html/

# 设置日志轮询配置
COPY ./scripts/logrotate-nginx.conf /etc/logrotate.d/nginx

# 设置权限
RUN chmod +x /scripts/*.sh

# 暴露端口
EXPOSE 80 443

# 启动脚本
CMD ["/scripts/entrypoint.sh"] 