#!/bin/bash

set -e

echo "======================================"
echo "        Starting n8n Mobile"
echo "======================================"

cd "${CODESPACE_VSCODE_FOLDER:-$PWD}"

echo ""
echo "Starting Docker..."
echo ""

docker compose up -d

echo ""
echo "======================================"
echo "        n8n is starting..."
echo "======================================"

echo ""
echo "Container status:"
docker compose ps

echo ""
echo "n8n should be available on:"
echo "http://localhost:5678"

echo ""
echo "Open the PORTS tab and select port 5678."
echo "======================================"