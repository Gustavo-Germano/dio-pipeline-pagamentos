#!/usr/bin/env bash
set -euo pipefail
docker compose down
echo "Containers encerrados. O volume de dados foi preservado."
echo "Para apagar também os dados locais: docker compose down -v"
