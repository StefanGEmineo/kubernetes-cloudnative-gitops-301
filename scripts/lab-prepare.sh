#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LAB="${1:-}"

API_PY="$ROOT/infra/app/api/api.py"
API_DOCKERFILE="$ROOT/infra/app/api/Dockerfile"
K8S_BASE="$ROOT/infra/k8s/base"

usage() {
  cat <<'EOF'
Uso: ./scripts/lab-prepare.sh <lab>

Labs disponibles:
  m02-01   api.py en estado M01 (config embebida, sin /ready)
  m02-02   api M02-01 + Dockerfile monolítico
  m03-01   estado post-M02 + carpeta K8s vacía
  m04-01   post-M03 + sin chart Helm del alumno
  m08-01   post-M02 listo para observabilidad

Rama main = stack Python (Flask). Rama springboot = Spring Boot + Angular.
EOF
}

copy_file() {
  cp "$1" "$2"
  echo "  → $(realpath --relative-to="$ROOT" "$2")"
}

reset_k8s_base() {
  rm -rf "$K8S_BASE"
  mkdir -p "$K8S_BASE"
  echo "  → infra/k8s/base/ (vacío)"
}

case "$LAB" in
  m02-01)
    echo "== Preparando M02-01 =="
    copy_file "$ROOT/infra/starters/api.m01.py" "$API_PY"
    ;;
  m02-02)
    echo "== Preparando M02-02 =="
    copy_file "$ROOT/infra/solutions/api.m02-01.py" "$API_PY"
    copy_file "$ROOT/infra/starters/Dockerfile.m01" "$API_DOCKERFILE"
    ;;
  m03-01)
    echo "== Preparando M03-01 =="
    copy_file "$ROOT/infra/solutions/api.m02-01.py" "$API_PY"
    copy_file "$ROOT/infra/solutions/Dockerfile.m02-02" "$API_DOCKERFILE"
    reset_k8s_base
    ;;
  m04-01)
    echo "== Preparando M04-01 =="
    copy_file "$ROOT/infra/solutions/api.m02-01.py" "$API_PY"
    copy_file "$ROOT/infra/solutions/Dockerfile.m02-02" "$API_DOCKERFILE"
    rm -rf "$ROOT/infra/helm/cloudnative-demo"
    ;;
  m08-01)
    echo "== Preparando M08-01 =="
    copy_file "$ROOT/infra/solutions/api.m02-01.py" "$API_PY"
    copy_file "$ROOT/infra/solutions/Dockerfile.m02-02" "$API_DOCKERFILE"
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
echo "OK."
