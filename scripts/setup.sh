#!/usr/bin/env bash
set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker não encontrado. Instale Docker Desktop ou Docker Engine."
  exit 1
fi

docker compose up -d postgres
echo "Aguardando PostgreSQL..."
for attempt in $(seq 1 30); do
  if docker compose exec -T postgres pg_isready -U "${POSTGRES_USER:-pipeline}" -d "${POSTGRES_DB:-pagamentos}" >/dev/null 2>&1; then
    echo "PostgreSQL pronto."
    exit 0
  fi
  sleep 2
done

echo "PostgreSQL não ficou pronto a tempo." >&2
exit 1
