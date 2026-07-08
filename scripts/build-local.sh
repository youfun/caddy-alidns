#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${OUT_DIR:-$ROOT/dist}"
CADDY_VERSION="${CADDY_VERSION:-}"

mkdir -p "$OUT_DIR"

if ! command -v go >/dev/null 2>&1; then
  echo "需要 Go 1.22+，见 https://go.dev/dl/" >&2
  exit 1
fi

export PATH="${PATH}:$(go env GOPATH)/bin"

if ! command -v xcaddy >/dev/null 2>&1; then
  echo ">>> 安装 xcaddy..."
  go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest
fi

OUTPUT="$OUT_DIR/caddy"
rm -f "$OUTPUT"

echo ">>> 编译 Caddy + alidns ..."
if [[ -n "$CADDY_VERSION" ]]; then
  xcaddy build "$CADDY_VERSION" --with github.com/caddy-dns/alidns --output "$OUTPUT"
else
  xcaddy build --with github.com/caddy-dns/alidns --output "$OUTPUT"
fi

chmod +x "$OUTPUT"
"$OUTPUT" version
echo ">>> 完成: $OUTPUT"