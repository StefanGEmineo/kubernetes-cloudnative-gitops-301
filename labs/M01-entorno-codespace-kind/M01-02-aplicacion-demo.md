# M01-02 — Verificar aplicación demo

[← Página anterior](M01-01-bootstrap-entorno.md) · [Siguiente página →](../M02-docker-avanzado-cloudnative/README.md)

> Práctica del módulo. La teoría y los scripts están en el [README del módulo](README.md).

### Objetivo

Levantar la aplicación demo con los scripts de Compose, entender **qué automatiza cada uno**, y explorar el código que adaptarás en M02.

### Prerrequisitos

- M01-01 completado (Codespace + kind operativos).

### En qué consiste

Usas `lab-up.sh` para desplegar la stack, validas endpoints, revisas el código fuente y aprendes a apagar el entorno con `lab-down.sh`.

---

### 1 — Levantar la stack: `lab-up.sh`

**Acción:**

```bash
./scripts/lab-up.sh
```

**Qué hace el script (paso a paso):**

| Orden | Acción | Motivo |
|-------|--------|--------|
| 1 | Si no existe `infra/.env`, copia `infra/.env.example` | Variables de entorno listas sin editar a mano la primera vez |
| 2 | `docker compose -f infra/docker-compose.yml up -d --build` | Construye imágenes demo-api/demo-web y levanta Postgres, Redis, loadgen |
| 3 | Ejecuta `health-check.sh` | Confirma en el mismo comando que 8080/8081 responden |

**Por qué un script en lugar de `docker compose up` directo:**

- Ruta al compose siempre correcta (desde cualquier alumno, mismo path).
- Creación automática de `.env` → menos `KeyError` en M02.
- Verificación integrada → feedback inmediato OK/AVISO.

**Resultado esperado:** Salida de `health-check` con `OK: demo-web :8080` y `OK: demo-api :8081`.

---

### 2 — Probar la API manualmente

**Acción:**

```bash
curl -s http://127.0.0.1:8081/health | jq .
curl -s http://127.0.0.1:8081/ready | jq .
curl -s http://127.0.0.1:8081/work | jq .
```

**Por qué:** Los scripts comprueban HTTP; tú validas el **contenido JSON** que usarás en labs de observabilidad (M08).

**Resultado esperado:** `"status":"ok"`, `"status":"ready"`, y `/work` con `"hits"` creciente al repetir.

---

### 3 — Abrir la web

**Acción:** Pestaña **Ports** del Codespace → puerto **8080** → abrir en navegador.

**Resultado esperado:** Página «Kubernetes + Docker Avanzado — demo web».

---

### 4 — Explorar el código y la config

**Acción:** Abre `infra/app/api/api.py` y `infra/.env.example`.

**Por qué:** En M02 trabajarás cómo la app **lee configuración del entorno** (metodología [12-Factor](../../docs/12-factor-app.md)). Familiarízate con qué variables usa (`DATABASE_URL`, `REDIS_URL`, `PORT`, …).

**Resultado esperado:** Entiendes qué valores inyecta Compose vía `env_file` y cuáles lee la app con `os.environ`.

---

### 5 — Servicios en ejecución

**Acción:**

```bash
docker compose -f infra/docker-compose.yml ps
```

**Por qué:** Estos cinco servicios serán el modelo mental para Deployments y Services en M03.

**Resultado esperado:** `demo-web`, `demo-api`, `postgres`, `redis`, `loadgen` en estado `running`.

---

### 6 — Apagar la stack: `lab-down.sh`

**Acción:**

```bash
./scripts/lab-down.sh
docker compose -f infra/docker-compose.yml ps
```

**Qué hace `lab-down.sh`:** Ejecuta `docker compose down` — detiene y elimina contenedores y red de la stack demo. **No** borra volúmenes de Postgres por defecto ni imágenes construidas.

**Por qué:** Liberar CPU/RAM cuando no practicas con Compose; ciclo limpio `lab-down` → `lab-up` para rebuild.

**Resultado esperado:** Ningún contenedor de la stack en ejecución. Vuelve a levantar con `./scripts/lab-up.sh` antes de M02.

---

### 7 — `health-check.sh` tras apagar

**Acción:** Con la stack parada, ejecuta `./scripts/health-check.sh`.

**Por qué:** Verás AVISO en 8080/8081 pero OK en Docker/kind — aprendes a **interpretar** el informe por secciones.

**Resultado esperado:** Docker y kind siguen OK; endpoints demo en AVISO hasta nuevo `lab-up`.

---

## Comprueba tu entendimiento

**Cadena lab-up**

¿Qué script se ejecuta al final de `lab-up.sh`?

→ `health-check.sh`.

**Apagar vs borrar clúster**

¿`lab-down.sh` elimina el clúster kind?

→ No; solo contenedores Compose. kind lo gestiona `kind-down.sh`.

**Servicios activos**

Tras `lab-up.sh`, lista servicios con `docker compose -f infra/docker-compose.yml ps --format json | jq -r '.Service' | sort`.

→ Cinco servicios.

## Reto

### 1 — Cambios cloudnative para M02

Enumera tres mejoras que aplicarás en M02 (pista: [12-Factor](../../docs/12-factor-app.md), probes, secretos fuera del repo).

<details>
<summary>Ver orientación</summary>

Externalizar config, no commitear secretos, `/health` + `/ready`, imagen no-root (M02-02), etc.

</details>

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| `demo-api` AVISO en health-check | Postgres arrancando | Espera 30 s; repetir `./scripts/health-check.sh` |
| Puerto 8080 no visible | Forwarding Codespace | **Ports** → visibilidad Public |
| Build lento la primera vez | Descarga de capas base | Normal; siguientes builds usan caché |
| `.env` desactualizado | Cambios en `.env.example` | Comparar con example y recrear o merge manual |
