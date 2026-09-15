#!/bin/bash

set -e

echo "======================================"
echo "          Stopping n8n"
echo "======================================"

docker compose stop

echo ""
echo "n8n has been stopped."
echo ""
echo "Your n8n data remains stored in:"
echo "n8n_data"
echo ""
echo "You can start it again later."
echo "======================================"