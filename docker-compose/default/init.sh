#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

SECRETS_DIR="$ROOT_DIR/secrets"
CPS_DIR="$ROOT_DIR/cps"
CEW_DIR="$ROOT_DIR/cew"

echo "Generating secrets if missing..."

for secret in \
  cew_api_key.txt \
  cpw_api_key.txt
do
if [ ! -f "$SECRETS_DIR/$secret" ]; then
  openssl rand -base64 128 | tr -dc 'A-Za-z0-9' | head -c 64 > "$SECRETS_DIR/$secret"
fi
done

for secret in \
  cew_secret_key.txt \
  cpw_secret_key.txt \
  cps_secret_key.txt
do
if [ ! -f "$SECRETS_DIR/$secret" ]; then
  openssl rand -base64 192 | tr -dc 'A-Za-z0-9' | head -c 128 > "$SECRETS_DIR/$secret"
fi
done

echo "Copying default configuration files if missing..."

if [ ! -f "$CPS_DIR/appsettings.Production.json" ]; then
  cp "$CPS_DIR/appsettings.Production.json.example" "$CPS_DIR/appsettings.Production.json"
fi

if [ ! -f "$CEW_DIR/appsettings.Production.json" ]; then
  cp "$CEW_DIR/appsettings.Production.json.example" "$CEW_DIR/appsettings.Production.json"
fi

echo "Initialization completed."