# Aplicación demo del curso

Stack mínima que evoluciona módulo a módulo:

| Componente | Ruta | Rol |
|------------|------|-----|
| **API** | `api/` | Flask: `/health`, `/ready`, `/work`, `/slow`, `/fail` |
| **Web** | `web/` | nginx estático en puerto 8080 |
| **Compose** | `../docker-compose.yml` | Orquestación local M01–M02 |
| **Config** | `../.env.example` | Variables runtime (copiar a `.env`) |

## Progresión del código (importante)

El repo en `main` arranca en **estado M01**. Los cambios de cada lab los haces **tú** en `api.py` y `Dockerfile`.

| Recurso | Rol |
|---------|-----|
| `infra/starters/` | Punto de partida por lab (`lab-prepare.sh`) |
| `infra/solutions/` | Referencia al terminar (comparar, no copiar sin intentar) |
| `scripts/lab-prepare.sh` | Restaura el estado inicial de un lab |
| `scripts/lab-verify.sh` | Comprueba que completaste el lab |

| Módulo | Tú implementas en el lab |
|--------|--------------------------|
| M01 | *(exploración)* — código ya en estado M01 |
| M02-01 | `os.environ`, `/ready`, `.env` |
| M02-02 | `Dockerfile` multistage |
| M03+ | Manifiestos K8s (`infra/k8s/`) — usar `lab-prepare.sh m03-01` si vienes de un fork antiguo |

## Dockerfiles API

| Fichero | Uso |
|---------|-----|
| `Dockerfile` | **Activo** — evoluciona con tus labs (M01: monolítico → M02-02: multistage) |
| `Dockerfile.legacy` | Referencia fija M02-02 — monolítico para comparar tamaño |

## Arranque

```bash
cp infra/.env.example infra/.env   # si no existe
./scripts/lab-up.sh
curl -s http://127.0.0.1:8081/ready | jq .
./scripts/image-size-compare.sh    # M02-02
```
