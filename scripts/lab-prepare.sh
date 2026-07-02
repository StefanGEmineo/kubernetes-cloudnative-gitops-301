#!/usr/bin/env bash
# Restaura el estado inicial de un laboratorio (punto de partida del alumno).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LAB="${1:-}"

usage() {
  cat <<'EOF'
Uso: ./scripts/lab-prepare.sh <lab>

Labs disponibles:
  m02-01   api.py en estado M01 (config embebida, sin /ready)
  m02-02   api M02-01 + Dockerfile monolítico (antes de multistage)
  m03-01   estado completo post-M02 (para Kubernetes)

El repo en main arranca en estado M01. Ejecuta lab-prepare si repites un lab
o tu fork ya tenía cambios aplicados.
EOF
}

copy_file() {
  local src="$1" dst="$2"
  cp "$src" "$dst"
  echo "  → $(realpath --relative-to="$ROOT" "$dst")"
}

case "$LAB" in
  m02-01)
    echo "== Preparando M02-01 =="
    copy_file "$ROOT/infra/starters/api.m01.py" "$ROOT/infra/app/api/api.py"
    echo "OK: api.py restaurado a estado M01."
    ;;
  m02-02)
    echo "== Preparando M02-02 =="
    copy_file "$ROOT/infra/solutions/api.m02-01.py" "$ROOT/infra/app/api/api.py"
    copy_file "$ROOT/infra/starters/Dockerfile.m01" "$ROOT/infra/app/api/Dockerfile"
    echo "OK: api M02-01 + Dockerfile monolítico. Implementa multistage en M02-02."
    ;;
  m03-01)
    echo "== Preparando M03-01 =="
    copy_file "$ROOT/infra/solutions/api.m02-01.py" "$ROOT/infra/app/api/api.py"
    copy_file "$ROOT/infra/solutions/Dockerfile.m02-02" "$ROOT/infra/app/api/Dockerfile"
    echo "OK: estado post-M02 listo para Kubernetes."
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
