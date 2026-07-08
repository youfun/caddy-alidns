# caddy-alidns

用 [xcaddy](https://github.com/caddyserver/xcaddy) 编译 **Caddy + 阿里云 DNS（alidns）** 插件，并通过 GitHub Actions 为多平台发布预编译二进制。

思路参考 [openmindw/caddy-cloudflare](https://github.com/openmindw/caddy-cloudflare)：定时/打 tag/手动触发构建 → Release 附件 → 一键安装脚本。

## 快速安装（Linux，需 root）

有 Go 时本地用 xcaddy 编译；无 Go 时从 GitHub Releases 下载对应架构包（需先把本仓库推到你的 GitHub 并跑通 workflow，或改脚本里的 `GITHUB_REPO`）。

```bash
curl -fsSL https://raw.githubusercontent.com/youfun/caddy-alidns/main/install_caddy_github.sh | sudo bash
```

安装前在脚本里或环境变量中配置：

- `GITHUB_REPO=youfun/caddy-alidns`（从 Release 下载时，默认已是此值）

## 预编译二进制

Release 命名示例：

- `caddy-alidns-linux-amd64.tar.gz`
- `caddy-alidns-linux-arm64.tar.gz`
- `caddy-alidns-macos-arm64.tar.gz`
- `caddy-alidns-windows-amd64.zip`

附 `.sha256` 校验文件。

## 本地编译

```bash
./scripts/build-local.sh
# 或指定版本
CADDY_VERSION=v2.10.0 ./scripts/build-local.sh
```

产物默认在 `dist/caddy`。

## 使用 alidns（ACME DNS-01）

1. 在阿里云 RAM 创建具备 DNS 解析权限的 AccessKey（勿提交到仓库）。
2. 设置环境变量：

```bash
export ALIYUN_ACCESS_KEY_ID="your-key-id"
export ALIYUN_ACCESS_KEY_SECRET="your-key-secret"
```

3. Caddyfile 全局或站点级配置见 [EXAMPLES.md](./EXAMPLES.md)。

## 自动构建

Workflow：`.github/workflows/build-caddy-alidns.yml`

| 触发方式 | 说明 |
|----------|------|
| `git tag v2.10.0 && git push origin v2.10.0` | 正式发布 |
| 每周日 02:00 UTC | `weekly-YYYYMMDD-HHMM` 定时 Release |
| Actions → Run workflow | 可填 Caddy 版本、是否发 Release |

## 手动 xcaddy

```bash
go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest
xcaddy build --with github.com/caddy-dns/alidns
```

## 链接

- [Caddy 文档](https://caddyserver.com/docs/)
- [caddy-dns/alidns](https://github.com/caddy-dns/alidns)
- [libdns/alidns 凭证说明](https://github.com/libdns/alidns)

## 发布为公开仓库

本目录可单独复制为新 git 仓库根目录：

```bash
cd infra/caddy-alidns
git init
git add .
git commit -m "feat: caddy with alidns plugin builds"
git remote add origin https://github.com/youfun/caddy-alidns.git
git push -u origin main
```

推送后打 tag 或手动跑一次 workflow 即可生成 Release。