# caddy-alidns

带 **阿里云 DNS（alidns）** 插件的 Caddy，用于 **DNS-01** 自动申请 / 续期 HTTPS 证书（支持通配符）。

- 预编译包：[GitHub Releases](https://github.com/youfun/caddy-alidns/releases)
- 运行方式：**原生二进制 + systemd**（无需 Docker）

---

## 文档（请按角色阅读）

| 文档 | 读者 | 内容 |
|------|------|------|
| **[docs/使用说明.md](./docs/使用说明.md)** | 部署 / 运维 | 安装、下载、AccessKey、Caddyfile、日常命令、排错 |
| **[EXAMPLES.md](./EXAMPLES.md)** | 部署 / 运维 | Caddyfile 配置片段（反代、通配符、STS 等） |
| **[docs/编译与发布说明.md](./docs/编译与发布说明.md)** | 维护 / 开发 | 本地 xcaddy、GitHub Actions、打 Release、改 workflow |

**只想在服务器上用：** 看 [使用说明](./docs/使用说明.md) 即可。  
**想自己编译或发新版：** 看 [编译与发布说明](./docs/编译与发布说明.md)。

---

## 一分钟开始（Linux）

```bash
curl -fsSL https://raw.githubusercontent.com/youfun/caddy-alidns/main/install_caddy_github.sh | sudo bash
```

配置密钥与站点步骤见 [docs/使用说明.md](./docs/使用说明.md)。

---

## License

MIT — [LICENSE](./LICENSE)