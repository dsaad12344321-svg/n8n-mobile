#!/bin/bash

set -u

echo ""
echo "======================================"
echo "        🚀 Starting n8n Mobile"
echo "======================================"
echo ""

# --------------------------------------
# 1. Check Docker
# --------------------------------------

echo "🔍 Checking Docker..."

if ! command -v docker >/dev/null 2>&1; then
    echo "❌ Docker is not installed or not available."
    exit 1
fi

if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is installed but the Docker daemon is not running."
    exit 1
fi

echo "✅ Docker is ready"
echo "   $(docker --version)"
echo ""

# --------------------------------------
# 2. Check Docker Compose
# --------------------------------------

echo "🔍 Checking Docker Compose..."

if ! docker compose version >/dev/null 2>&1; then
    echo "❌ Docker Compose is not available."
    exit 1
fi

echo "✅ Docker Compose is ready"
echo "   $(docker compose version)"
echo ""

# --------------------------------------
# 3. Check docker-compose.yml
# --------------------------------------

echo "🔍 Checking docker-compose.yml..."

if [ ! -f "docker-compose.yml" ]; then
    echo "❌ docker-compose.yml was not found."
    echo ""
    echo "Current directory:"
    pwd
    echo ""
    exit 1
fi

echo "✅ docker-compose.yml found"
echo ""

# --------------------------------------
# 4. Validate Compose configuration
# --------------------------------------

echo "🔍 Validating Docker Compose configuration..."

if ! docker compose config >/dev/null 2>&1; then
    echo "❌ docker-compose.yml contains an error."
    echo ""
    docker compose config
    exit 1
fi

echo "✅ Docker Compose configuration is valid"
echo ""

# --------------------------------------
# 5. Start n8n
# --------------------------------------

echo "🐳 Starting n8n..."

if ! docker compose up -d; then
    echo ""
    echo "❌ Failed to start n8n."
    exit 1
fi

echo ""
echo "✅ n8n container started"
echo ""

# --------------------------------------
# 6. Wait for n8n
# --------------------------------------

echo "⏳ Waiting for n8n to become ready..."

MAX_ATTEMPTS=60
ATTEMPT=0

while [ "$ATTEMPT" -lt "$MAX_ATTEMPTS" ]; do

    if curl -fsS http://localhost:5678/healthz >/dev/null 2>&1; then
        echo "✅ n8n is ready!"
        break
    fi

    ATTEMPT=$((ATTEMPT + 1))

    printf "   Waiting... %s/%s\r" "$ATTEMPT" "$MAX_ATTEMPTS"

    sleep 2
done

echo ""

if [ "$ATTEMPT" -ge "$MAX_ATTEMPTS" ]; then
    echo "❌ n8n did not become ready within 120 seconds."
    echo ""
    echo "Container status:"
    docker compose ps
    echo ""
    echo "Recent n8n logs:"
    docker compose logs --tail=30 n8n
    exit 1
fi

# --------------------------------------
# 7. Get Codespace URL
# --------------------------------------

echo ""
echo "======================================"
echo "          🎉 n8n IS READY"
echo "======================================"
echo ""

CODESPACE_URL=""

if [ -n "${CODESPACE_NAME:-}" ] && [ -n "${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-}" ]; then
    CODESPACE_URL="https://${CODESPACE_NAME}-5678.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
fi

if [ -n "$CODESPACE_URL" ]; then

    echo "🌐 n8n URL:"
    echo ""
    echo "   $CODESPACE_URL"
    echo ""

else

    echo "🌐 n8n is running on:"
    echo ""
    echo "   http://localhost:5678"
    echo ""
    echo "Open GitHub Codespaces → PORTS → 5678 → Open in Browser."

fi

echo "======================================"
echo ""

# --------------------------------------
# 8. Final status
# --------------------------------------

echo "📊 Container status:"
echo ""

docker compose ps

echo ""
echo "======================================"
echo "       🚀 Ready to publish!"
echo "======================================"
echo ""