#!/usr/bin/env bash
# Comprueba que el alumno completó un laboratorio (sin revelar la solución línea a línea).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LAB="${1:-}"
API="$ROOT/infra/app/api/api.py"
DOCKERFILE="$ROOT/infra/app/api/Dockerfile"

usage() {
  cat <<'EOF'
Uso: ./scripts/lab-verify.sh <lab>

Labs disponibles:
  m02-01   config externalizada + endpoint /ready
  m02-02   Dockerfile multistage + usuario no-root
EOF
}

ok()   { echo "OK: $*"; }
fail() { echo "FALTA: $*" >&2; errors=$((errors + 1)); }

errors=0

case "$LAB" in
  m02-01)
    echo "== Verificando M02-01 =="
    grep -q 'os\.environ' "$API" || fail "api.py no usa os.environ"
    grep -q 'def ready' "$API" || fail "falta endpoint /ready"
    grep -q 'postgres://lab:lab@postgres' "$API" && fail "DATABASE_URL sigue hardcodeada en api.py"
    grep -q '@app.get("/ready")' "$API" || fail "falta decorador @app.get(\"/ready\")"
    if [[ "$errors" -eq 0 ]]; then
      ok "api.py cumple los requisitos de M02-01"
    fi
    ;;
  m02-02)
    echo "== Verificando M02-02 =="
    grep -q 'AS builder' "$DOCKERFILE" || fail "Dockerfile sin stage builder"
    grep -q 'AS runtime' "$DOCKERFILE" || fail "Dockerfile sin stage runtime"
    grep -q 'COPY --from=builder' "$DOCKERFILE" || fail "falta COPY --from=builder"
    grep -q 'USER app' "$DOCKERFILE" || fail "falta USER app (no-root)"
    grep -q 'FROM python:3.12-slim AS builder' "$DOCKERFILE" || fail "revisa estructura multistage"
    if [[ "$errors" -eq 0 ]]; then
      ok "Dockerfile cumple los requisitos de M02-02"
    fi
    ;;
  -h|--help|"")
    usage
    exit "${1:+0}"
    ;;
  *)
    echo "Lab desconocido: $LAB" >&2
    usage
    exit 1
    ;;
esac

exit "$errors"
