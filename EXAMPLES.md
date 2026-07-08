# Caddy + AliDNS 配置示例

安装与运维：[docs/使用说明.md](./docs/使用说明.md)（编译发布见 [docs/编译与发布说明.md](./docs/编译与发布说明.md)）。

## 全局 ACME DNS（推荐）

```caddyfile
{
	email you@example.com

	acme_dns alidns {
		access_key_id {env.ALIYUN_ACCESS_KEY_ID}
		access_key_secret {env.ALIYUN_ACCESS_KEY_SECRET}
	}
}

example.com {
	reverse_proxy 127.0.0.1:4000
}
```

## 单站点 TLS

```caddyfile
example.com {
	tls {
		dns alidns {
			access_key_id {env.ALIYUN_ACCESS_KEY_ID}
			access_key_secret {env.ALIYUN_ACCESS_KEY_SECRET}
		}
	}

	file_server
}
```

## 通配符证书

```caddyfile
{
	email you@example.com
	acme_dns alidns {
		access_key_id {env.ALIYUN_ACCESS_KEY_ID}
		access_key_secret {env.ALIYUN_ACCESS_KEY_SECRET}
	}
}

*.example.com {
	reverse_proxy 127.0.0.1:8080
}
```

## STS 临时凭证（可选）

```caddyfile
{
	acme_dns alidns {
		access_key_id {env.ALIYUN_ACCESS_KEY_ID}
		access_key_secret {env.ALIYUN_ACCESS_KEY_SECRET}
		security_token {env.ALIYUN_SECURITY_TOKEN}
	}
}
```

## systemd 环境变量

`/etc/systemd/system/caddy.service` 的 `[Service]` 段：

```ini
Environment=ALIYUN_ACCESS_KEY_ID=your-id
Environment=ALIYUN_ACCESS_KEY_SECRET=your-secret
```

更稳妥做法：使用 `EnvironmentFile=/etc/caddy/caddy.env`，文件权限 `600`，属主 `caddy`。

## JSON 配置片段

```json
{
  "module": "acme",
  "challenges": {
    "dns": {
      "provider": {
        "name": "alidns",
        "access_key_id": "{env.ALIYUN_ACCESS_KEY_ID}",
        "access_key_secret": "{env.ALIYUN_ACCESS_KEY_SECRET}"
      }
    }
  }
}
```