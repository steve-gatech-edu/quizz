#!/usr/bin/env bash
set -euo pipefail

PUBLIC_URL="https://${CODESPACE_NAME}-3000.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"

# Reuse existing JWT_SECRET & ADMIN_PASSWORD across restarts if .env already exists
if [ -f .env ]; then
  source .env
fi

ADMIN_USERNAME="${ADMIN_USERNAME:-admin}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-$(openssl rand -base64 16 | tr -dc 'a-zA-Z0-9' | head -c 16)}"
JWT_SECRET="${JWT_SECRET:-$(openssl rand -hex 32)}"

cat > .env <<EOF
ADMIN_USERNAME=${ADMIN_USERNAME}
ADMIN_PASSWORD=${ADMIN_PASSWORD}
JWT_SECRET=${JWT_SECRET}
PUBLIC_URL=${PUBLIC_URL}
ALLOWED_DOMAIN=
APP_BIND=0.0.0.0
APP_PORT=3000
UNSPLASH_ACCESS_KEY=
GIPHY_API_KEY=
EOF

mkdir -p data avatars

# Start Quizz without the Caddy profile (Codespaces handles HTTPS)
docker compose up -d

# Force port 3000 to public visibility so phones don't hit GitHub login
if [ -n "${CODESPACE_NAME:-}" ]; then
  gh codespace ports visibility 3000:public -c "$CODESPACE_NAME" || true
fi

echo "========================================================"
echo " Quizz is live!"
echo " Host / Admin URL : ${PUBLIC_URL}/admin"
echo " Player Join URL  : ${PUBLIC_URL}/play"
echo " Admin Username   : ${ADMIN_USERNAME}"
echo " Admin Password   : ${ADMIN_PASSWORD}"
echo "========================================================"
