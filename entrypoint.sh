#!/bin/bash
set -e

APP_DIR="/app"
ENV_FILE="$APP_DIR/.env"
EXAMPLE_ENV="$APP_DIR/.env.example"
SQL_DIR="$APP_DIR/sqlite3"
REPORT_DIR="$APP_DIR/report"
LOG_FILE="$APP_DIR/bot.log"

echo "[entrypoint] Starting container initialization..."

# 1️⃣ Copy .env nếu chưa có
if [ ! -f "$ENV_FILE" ] && [ -f "$EXAMPLE_ENV" ]; then
  echo "[entrypoint] .env not found, copying from .env.example"
  cp "$EXAMPLE_ENV" "$ENV_FILE"
  chmod 600 "$ENV_FILE" || true
fi

# 2️⃣ Đảm bảo thư mục & file tồn tại
mkdir -p "$SQL_DIR" "$REPORT_DIR"
touch "$LOG_FILE"

# 3️⃣ Cấp quyền cho botuser truy cập các volume được mount
echo "[entrypoint] Fixing permissions for volumes..."
#chown -R botuser:botuser "$SQL_DIR" "$REPORT_DIR" "$LOG_FILE" 2>/dev/null || true
chmod 775 "$SQL_DIR" "$REPORT_DIR" || true
chmod 664 "$LOG_FILE" || true

# 4️⃣ Cảnh báo nếu BOT_TOKEN chưa set
if [ -z "${BOT_TOKEN:-}" ]; then
  echo "[entrypoint] ⚠️  WARNING: BOT_TOKEN is not set. Bot may fail to connect."
fi

# 5️⃣ Chạy app dưới quyền botuser
echo "[entrypoint] Running as botuser..."
# Prefer runuser or su; fall back to running as current user if neither exists.
if command -v runuser >/dev/null 2>&1; then
  echo "[entrypoint] Using runuser to drop privileges and start bot"
  exec runuser -u botuser -- python bot.py
elif command -v su >/dev/null 2>&1; then
  echo "[entrypoint] Using su to drop privileges and start bot"
  # Use -s to specify shell for su; this helps on some minimal images
  exec su -s /bin/bash botuser -c "python bot.py"
else
  echo "[entrypoint] Warning: neither runuser nor su available, starting as current user"
  exec python bot.py
fi
