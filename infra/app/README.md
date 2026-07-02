# Aplicación demo — Flask + nginx (rama `main`)

| Componente | Ruta | Tecnología |
|------------|------|------------|
| **API** | `api/` | Python 3, Flask, psycopg2, redis |
| **Web** | `web/` | nginx estático |
| **Compose** | `../docker-compose.yml` | M01–M02 local |
| **Config** | `../.env.example` | `DATABASE_URL`, `REDIS_URL`, `PORT`, … |

> Stack **Spring Boot + Angular** en la rama `springboot`.

## Endpoints API

| Ruta | Uso |
|------|-----|
| `/health` | Liveness |
| `/ready` | Readiness (M02+) |
| `/work`, `/slow`, `/fail` | Labs carga y diagnóstico |

## Progresión

Ver `docs/progresion-labs.md` — `main` arranca en M01; el alumno implementa M02 en `api.py` y `Dockerfile`.
