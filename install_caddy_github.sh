#!/usr/bin/env bash
# 安装 Caddy（含 alidns 插件）：优先 xcaddy 本地编译，否则从 GitHub Release 下载。
set -euo pipefail

# 改成你的公开仓库，例如 youfun/caddy-alidns
GITHUB_REPO="${GITHUB_REPO:-youfun/caddy-alidns}"
INSTALL_BIN="${INSTALL_BIN:-/usr/local/bin/caddy}"

echo ">>> 步骤 1: 安装依赖 curl、jq..."
if command -v apt-get &>/dev/null; then
  apt-get update -qq
  apt-get install -y curl jq
elif command -v dnf &>/dev/null; then
  dnf install -y curl jq
elif command -v yum &>/dev/null; then
  yum install -y curl jq
elif command -v pacman &>/dev/null; then
  pacman -S --noconfirm curl jq
else
  command -v curl >/dev/null && command -v jq >/dev/null || {
    echo "请手动安装 curl 与 jq" >&2
    exit 1
  }
fi

case "$(uname -m)" in
  x86_64) ARCH="amd64" ;;
  aarch64) ARCH="arm64" ;;
  armv7l) ARCH="armv7" ;;
  armv6l) ARCH="armv6" ;;
  *)
    echo "不支持的架构: $(uname -m)" >&2
    exit 1
    ;;
esac

GO_AVAILABLE=false
if command -v go &>/dev/null; then
  GO_AVAILABLE=true
fi

install_via_xcaddy() {
  export PATH="${PATH}:$(go env GOPATH)/bin"
  if ! command -v xcaddy &>/dev/null; then
    echo ">>> 安装 xcaddy..."
    go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest
  fi
  TMP_DIR="$(mktemp -d)"
  trap 'rm -rf "$TMP_DIR"' EXIT
  (
    cd "$TMP_DIR"
    xcaddy build --with github.com/caddy-dns/alidns
    install -m 0755 caddy "$INSTALL_BIN"
  )
  echo "✅ 已通过 xcaddy 安装（含 alidns）"
}

install_via_release() {
  if [[ -z "$GITHUB_REPO" ]]; then
    echo "错误: 请设置 GITHUB_REPO，或安装 Go 后重试以使用 xcaddy。" >&2
    exit 1
  fi

  API="https://api.github.com/repos/${GITHUB_REPO}/releases/latest"
  echo ">>> 从 ${GITHUB_REPO} 获取最新 Release..."
  TAG="$(curl -fsSL "$API" | jq -r '.tag_name')"
  [[ -n "$TAG" && "$TAG" != "null" ]] || {
    echo "未找到 Release，请先跑 GitHub Actions 或打 tag。" >&2
    exit 1
  }

  ASSET="caddy-alidns-linux-${ARCH}.tar.gz"
  URL="https://github.com/${GITHUB_REPO}/releases/download/${TAG}/${ASSET}"
  TMP_DIR="$(mktemp -d)"
  trap 'rm -rf "$TMP_DIR"' EXIT

  curl -fsSL "$URL" -o "$TMP_DIR/$ASSET"
  tar -xzf "$TMP_DIR/$ASSET" -C "$TMP_DIR"
  install -m 0755 "$TMP_DIR/caddy-linux-${ARCH}" "$INSTALL_BIN"
  echo "✅ 已从 Release ${TAG} 安装 ${ASSET}"
}

echo ">>> 步骤 2: 安装 Caddy 二进制..."
if [[ "$GO_AVAILABLE" == true ]]; then
  install_via_xcaddy
else
  echo "未检测到 Go，尝试 Release 下载..."
  install_via_release
fi

echo ">>> 步骤 3: 创建 caddy 用户与目录..."
if ! getent group caddy &>/dev/null; then
  groupadd --system caddy
fi
if ! id caddy &>/dev/null; then
  useradd --system --gid caddy --shell /usr/sbin/nologin --home-dir /var/lib/caddy caddy
fi

mkdir -p /etc/caddy /var/lib/caddy
chown -R root:caddy /etc/caddy
chmod 775 /etc/caddy
chown -R caddy:caddy /var/lib/caddy

if [[ ! -f /etc/caddy/Caddyfile ]]; then
  cat >/etc/caddy/Caddyfile <<'EOF'
{
	email admin@example.com
	# acme_dns alidns {
	# 	access_key_id {env.ALIYUN_ACCESS_KEY_ID}
	# 	access_key_secret {env.ALIYUN_ACCESS_KEY_SECRET}
	# }
}

:80 {
	respond "Caddy + alidns is installed."
}
EOF
  chown root:caddy /etc/caddy/Caddyfile
  chmod 664 /etc/caddy/Caddyfile
fi

echo ">>> 步骤 4: systemd 服务..."
cat >/etc/systemd/system/caddy.service <<EOF
[Unit]
Description=Caddy
Documentation=https://caddyserver.com/docs/
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
User=caddy
Group=caddy
EnvironmentFile=-/etc/caddy/caddy.env
ExecStart=${INSTALL_BIN} run --environ --config /etc/caddy/Caddyfile
ExecReload=${INSTALL_BIN} reload --config /etc/caddy/Caddyfile
TimeoutStopSec=5s
LimitNOFILE=1048576
AmbientCapabilities=CAP_NET_BIND_SERVICE
ProtectSystem=full
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now caddy

sleep 2
"$INSTALL_BIN" version
systemctl status caddy --no-pager || true

echo ""
echo "安装完成。配置 AliDNS 环境变量见 /etc/caddy/caddy.env 与 EXAMPLES.md。"