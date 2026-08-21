#!/usr/bin/env bash
# dsh-base: базовая установка DeepSeek Harness (Linux/macOS)
# Запуск:  ./install.sh
set -euo pipefail

echo "=== dsh-base: установка DeepSeek Harness ==="

# 1. Node.js
if ! command -v node >/dev/null 2>&1; then
  echo "[1/5] Node.js не найден. Установите вручную: https://nodejs.org"
  exit 1
fi
echo "[1/5] Node.js: $(node --version)"

# 2. Каталоги DSH
DSH_HOME="${DSH_HOME:-$HOME/.dsh}"
PROFILE_DIR="$DSH_HOME/profiles/web"
MCP_DIR="${DSH_MCP_DIR:-$HOME/Documents/DSH-work/_dsh_mcp}"
mkdir -p "$PROFILE_DIR" "$MCP_DIR"
echo "[2/5] Профиль DSH: $PROFILE_DIR"

# 3. Конфигурация
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "$SRC_DIR/cordis.patch.yml" "$PROFILE_DIR/cordis.patch.yml"
echo "[3/5] cordis.patch.yml установлен (MCP + vision-модель)"

# 4. GitHub-лаунчер
cp "$SRC_DIR/github-launcher.js" "$MCP_DIR/github-launcher.js"
echo "[4/5] github-launcher.js установлен в $MCP_DIR"

# 5. Запуск DSH
echo "[5/5] Запускаю: npx @deepseek-ai/dsh web"
npx @deepseek-ai/dsh web
