# Nginx与Certbot集成Docker镜像

这个项目提供了一个Docker镜像，集成了Nginx和Certbot功能，可以自动获取和更新Let's Encrypt SSL证书。

## 功能特点

- 基于Alpine Linux的轻量级镜像
- 自动获取和更新Let's Encrypt SSL证书
- 自动将HTTP请求重定向到HTTPS
- 支持自定义域名和邮箱地址
- 支持Let's Encrypt的测试环境
- 支持通过环境变量动态配置Nginx配置文件
- 使用crontab定时更新证书

## 使用方法

### 1. 准备工作

首先，克隆此仓库到本地：

```bash
git clone <repository-url>
cd nginx-certbot
```

### 2. 配置域名

编辑`conf.d/default.conf`文件，将所有域名替换为您自己的域名。

### 3. 配置环境变量

编辑`.env`文件（可从`.env.example`复制），设置以下环境变量：

主要环境变量说明：

#### 基本设置
- `EMAIL`: 您的邮箱地址，用于Let's Encrypt通知
- `STAGING`: 设置为1可使用Let's Encrypt的测试环境，设置为0使用生产环境
- `SELF_SIGNED_KEY_SIZE`: 自签名证书密钥大小，默认为4096位
- `COMPOSE`: 在docker-compose.yml中已设置为1，表示在Docker Compose环境中运行
- `TZ`: 时区配置

#### 域名设置
- `MAIN_DOMAIN`: 主域名
- `N8N_DOMAIN`: N8N服务域名
- `NTFY_DOMAIN`: NTFY服务域名
- `FRPS_DOMAIN`: FRPS服务域名

#### 端口设置
- `N8N_PORT`: N8N服务端口
- `NTFY_PORT`: NTFY服务端口
- `FRPS_ADMIN_PORT`: FRPS管理端口
- `FRPS_HTTP_PORT`: FRPS HTTP端口
- `FRPS_HTTPS_PORT`: FRPS HTTPS端口

#### n8n设置
- `N8N_AUTH_USER`: n8n管理员用户名
- `N8N_AUTH_PASSWORD`: n8n管理员密码
- `N8N_ENCRYPTION_KEY`: 用于加密工作流中的凭据

#### PostgreSQL设置
- `POSTGRES_DB`: PostgreSQL数据库名称
- `POSTGRES_USER`: PostgreSQL用户名
- `POSTGRES_PASSWORD`: PostgreSQL密码

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
- `docker-compose.yml`: Docker Compose配置文件
- `.env`: 环境变量配置文件
- `.env.example`: 环境变量示例文件
- `nginx.conf`: Nginx主配置文件
- `nginx/env.conf.template`: Nginx环境变量配置模板
- `conf.d/`: Nginx站点配置目录
- `scripts/`: 脚本文件目录
  - `entrypoint.sh`: 容器入口脚本
  - `certbot-sign.sh`: 证书首次获取脚本
  - `certbot-renew.sh`: 证书更新脚本
  - `certbot-clean.sh`: 证书清空脚本（调试开发用）
- `data/`: 数据持久化目录
  - `certbot/conf/`: Let's Encrypt证书和配置
  - `certbot/www/`: Certbot验证文件
  - `nginx/html/`: 网站文件

## 环境变量替换功能

本项目支持通过环境变量动态配置Nginx。工作原理如下：

1. 在`nginx/env.conf.template`文件中使用`__VARIABLE__`格式的占位符
2. 容器启动时，`entrypoint.sh`脚本会自动将这些占位符替换为对应的环境变量值
3. 生成的配置文件保存为`nginx/env.conf`，被Nginx加载

例如，`env.conf.template`中的`__MAIN_DOMAIN__`会被替换为环境变量`MAIN_DOMAIN`的值。

## 证书自动更新

证书更新采用crontab定时任务方式，每12小时检查一次证书是否需要更新。工作流程如下：

1. 容器首次启动时会立即尝试获取证书
2. 之后每12小时自动检查证书是否需要更新
3. 如果证书更新成功，会自动重新加载Nginx配置

## 开发与生产环境

本项目支持在开发和生产环境中使用不同的配置：

1. **开发环境**：
   - 不设置`COMPOSE`环境变量或设置为空
   - 会自动添加本地域名解析（127.0.0.1 n8n frps ntfy）到/etc/hosts
   - 适合本地开发和测试
   - 使用`docker run`命令启动时的默认模式

2. **生产环境**：
   - 设置`COMPOSE=1`环境变量（在docker-compose.yml中已默认设置）
   - 不会修改/etc/hosts文件
   - 适合在Docker Compose或生产环境中运行
   - 使用`docker-compose up`命令启动时的默认模式

## 注意事项

1. 确保您的服务器80和443端口可以从互联网访问
2. 首次运行时，容器会创建自签名证书，然后尝试获取Let's Encrypt证书
3. 如果您使用的是测试环境，浏览器会显示证书不受信任的警告
4. 证书会每12小时自动检查更新一次
5. 在生产环境中，建议将`STAGING`设置为0，以获取真实的Let's Encrypt证书
6. 请确保所有密码和加密密钥在生产环境中使用强密码，并妥善保管
7. 时区默认设置为`Asia/Shanghai`，如需修改请直接编辑.env文件

## 自定义网站内容

修改`docker-compose.yml`文件中的卷映射至`/var/www/html`。将您的网站文件放在映射的目录中。

## 许可证

MIT