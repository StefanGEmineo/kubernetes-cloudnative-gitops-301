# Puntos de partida de laboratorios (`infra/starters/`)

Copias de referencia del **estado inicial** de cada fase. Los scripts `lab-prepare.sh` las restauran sobre los ficheros activos en `infra/app/api/`.

| Fichero | Estado | Usado en |
|---------|--------|----------|
| `api.m01.py` | Config embebida, sin `/ready` | M02-01 |
| `Dockerfile.m01` | Monolítico, root | M02-02 |

No edites estos ficheros durante los labs: trabaja sobre `api.py` y `Dockerfile` en `infra/app/api/`.
