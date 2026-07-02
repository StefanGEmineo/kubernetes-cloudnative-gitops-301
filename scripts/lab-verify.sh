#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LAB="${1:-}"
API="$ROOT/infra/app/api/api.py"
DOCKERFILE="$ROOT/infra/app/api/Dockerfile"

usage() {
  cat <<'EOF'
Uso: ./scripts/lab-verify.sh <lab>

  m02-01   os.environ + /ready en api.py
  m02-02   Dockerfile multistage Python
  m03-01   manifests en infra/k8s/base/
  m04-01   chart Helm cloudnative-demo
EOF
}

ok()   { echo "OK: $*"; }
fail() { echo "FALTA: $*" >&2; errors=$((errors + 1)); }

errors=0

case "$LAB" in
  m02-01)
    echo "== Verificando M02-01 =="
    grep -q 'os\.environ' "$API" || fail "api.py no usa os.environ"
    grep -q 'def ready' "$API" || fail "falta /ready"
    grep -q 'postgres://lab:lab@postgres' "$API" && fail "DATABASE_URL hardcodeada"
    [[ "$errors" -eq 0 ]] && ok "api.py cumple M02-01"
    ;;
  m02-02)
    echo "== Verificando M02-02 =="
    grep -q 'AS builder' "$DOCKERFILE" || fail "sin stage builder"
    grep -q 'USER app' "$DOCKERFILE" || fail "sin USER app"
    [[ "$errors" -eq 0 ]] && ok "Dockerfile cumple M02-02"
    ;;
  m03-01)
    echo "== Verificando M03-01 =="
    for f in namespace.yaml api-deployment.yaml api-service.yaml web-deployment.yaml web-service.yaml; do
      [[ -f "$ROOT/infra/k8s/base/$f" ]] || fail "falta $f"
    done
    [[ "$errors" -eq 0 ]] && ok "manifests M03-01 presentes"
    ;;
  m04-01)
    echo "== Verificando M04-01 =="
    [[ -f "$ROOT/infra/helm/cloudnative-demo/Chart.yaml" ]] || fail "falta Chart.yaml"
    [[ "$errors" -eq 0 ]] && ok "chart Helm presente"
    ;;
  *)
    usage
    exit 1
    ;;
esac
exit "$errors"
