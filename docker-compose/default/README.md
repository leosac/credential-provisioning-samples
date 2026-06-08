# Credential Provisioning Docker Compose Sample

This repository contains a Docker Compose sample for the Leosac credential provisioning stack.
It runs three services together:

- `cps` — Credential Provisioning Server
- `cpw` — Card Printing Worker
- `cew` — Card Encoding Worker

The stack is configured for local development and single production ready usage with persistent volumes and secrets.

## Contents

- `compose.yaml` — Docker Compose definition for all services
- `init.sh` — initialization script for generating secret files and copying default configs
- `cps/` — credential provisioning server build context and data folder
- `cpw/` — card printing worker repository and logs folders
- `cew/` — card encoding worker repository and logs folders
- `secrets/` — local secret files used by the Compose stack

## Prerequisites

- Docker Engine installed
- Docker Compose available (`docker compose`)
- Bash shell for `init.sh` (Linux/macOS/WSL/Git Bash on Windows)

> If you are on Windows, run `init.sh` from WSL or Git Bash, or use a compatible bash environment.

## Quick Start

```bash
./init.sh
docker compose up -d
```

To rebuild the CPS service after changes:

```bash
docker compose up --build -d
```

## Service Overview

### `cps` — Credential Provisioning Server

- Built from `cps/Dockerfile`
- Uses `cps/data` for database, import files, and certificates
- Configured by `cps/appsettings.Production.json`
- Exposes HTTP at port `5000`
- Uses secrets:
  - `secrets/cps_secret_key.txt`
  - `secrets/cpw_api_key.txt`
  - `secrets/cew_api_key.txt`

### `cpw` — Card Printing Worker

- Runs image `leosac/leosac-card-printing-worker:latest`
- Exposes HTTP at port `4000`
- Uses local volumes:
  - `cpw/repository`
  - `cpw/logs`
- Configured by environment variables only
- Uses secrets:
  - `secrets/cpw_api_key.txt`
  - `secrets/cpw_secret_key.txt`

### `cew` — Card Encoding Worker

- Runs image `leosac/leosac-card-encoding-worker:latest`
- Exposes HTTP at port `5100`
- Uses local volumes:
  - `cew/repository`
  - `cew/logs`
- Configured by `cew/appsettings.Production.json`
- Uses secrets:
  - `secrets/cew_api_key.txt`
  - `secrets/cew_secret_key.txt`

## Configuration

The `init.sh` script performs two actions:

1. Generates missing secret files under `secrets/`
2. Copies `*.example` config files into place for `cps` and `cew`

After run, if you want to customize the default settings, edit:

- `cps/appsettings.Production.json`
- `cew/appsettings.Production.json`

Then restart the stack:

```bash
docker compose restart
```

## Secrets

The Compose stack mounts the following secret files into containers:

- `secrets/cps_secret_key.txt`
- `secrets/cpw_api_key.txt`
- `secrets/cpw_secret_key.txt`
- `secrets/cew_api_key.txt`
- `secrets/cew_secret_key.txt`

Example files are also provided for reference:

- `secrets/*.example`

## Notes

- The Compose file binds services to `127.0.0.1` for local-only access.
  If you want to access it remotely you may have to change the default address binding, or use a reverse proxy.
