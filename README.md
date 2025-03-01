# Nginx与Certbot集成Docker镜像

这个项目提供了一个Docker镜像，集成了Nginx和Certbot功能，可以自动获取和更新Let's Encrypt SSL证书。

## 功能特点

- 基于Alpine Linux的轻量级镜像
- 自动获取和更新Let's Encrypt SSL证书
- 自动将HTTP请求重定向到HTTPS
- 支持自定义域名和邮箱地址
- 支持Let's Encrypt的测试环境

## 使用方法

### 1. 准备工作

首先，克隆此仓库到本地：

```bash
git clone <repository-url>
cd nginx-certbot
```

### 2. 配置域名

编辑`conf.d/default.conf`文件，将`example.com`和`www.example.com`替换为您自己的域名。

### 3. 配置环境变量

编辑`docker-compose.yml`文件，修改以下环境变量：

- `DOMAINS`: 您的域名，多个域名用空格分隔
- `EMAIL`: 您的邮箱地址，用于Let's Encrypt通知
- `STAGING`: 设置为1可使用Let's Encrypt的测试环境，设置为0使用生产环境

### 4. 启动容器

```bash
docker-compose up -d
```

### 5. 查看日志

```bash
docker-compose logs -f
```

## 目录结构

- `Dockerfile`: Docker镜像构建文件
- `nginx.conf`: Nginx主配置文件
- `conf.d/`: Nginx站点配置目录
- `scripts/`: 脚本文件目录
  - `entrypoint.sh`: 容器入口脚本
  - `certbot-renew.sh`: 证书自动更新脚本
- `data/`: 数据持久化目录
  - `certbot/conf/`: Let's Encrypt证书和配置
  - `certbot/www/`: Certbot验证文件
  - `nginx/html/`: 网站文件

## 注意事项

1. 确保您的服务器80和443端口可以从互联网访问
2. 首次运行时，容器会创建自签名证书，然后尝试获取Let's Encrypt证书
3. 如果您使用的是测试环境，浏览器会显示证书不受信任的警告
4. 证书会每12小时自动检查更新一次

## 自定义网站内容

将您的网站文件放在`data/nginx/html/`目录中，或者修改`docker-compose.yml`文件中的卷映射。

## 许可证

MIT 