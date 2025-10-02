#!/bin/bash
set -e

echo "Starting Docker Compose services..."
docker compose up -dchmod +x .devcontainer/scripts/startup.sh