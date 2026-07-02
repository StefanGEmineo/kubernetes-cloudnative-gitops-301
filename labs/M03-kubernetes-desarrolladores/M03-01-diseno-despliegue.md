# M03-01 — Diseño de despliegue en Kubernetes

[← Página anterior](README.md) · [Siguiente página →](M03-02-estrategias-despliegue.md)

> Práctica del módulo. Lee el [README](README.md) (teoría).

## Objetivo

Desplegar la **API Flask** y el **frontend nginx estático** en kind con Deployments, Services, ConfigMap y Secret.

## Prerrequisitos

- M02 completado (`./scripts/lab-verify.sh m02-01` y `m02-02` OK).
- Clúster kind operativo (`./scripts/kind-up.sh`).

## Antes de empezar

```bash
./scripts/lab-prepare.sh m03-01
./scripts/lab-up.sh    # valida imágenes locales
```

Crea la carpeta de trabajo vacía:

```bash
mkdir -p infra/k8s/base
```

Consulta la solución de referencia solo al final: `infra/k8s/solutions/m03-01/`.

## Mapa del ejercicio

```text
Paso 1   Namespace cloudnative-lab
Paso 2   ConfigMap + Secret (config Flask)
Paso 3   Deployment + Service demo-api (probes /health y /ready)
Paso 4   Deployment + Service demo-web (NodePort)
Paso 5   Redis en el clúster
Paso 6   Cargar imágenes y aplicar
```

---

### 1 — Namespace

**Acción:** Crea `infra/k8s/base/namespace.yaml`:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: cloudnative-lab
```

**Por qué:** Aísla recursos del curso y simplifica `kubectl -n cloudnative-lab`.

---

### 2 — ConfigMap y Secret para Flask

**Acción:** Crea `api-configmap.yaml` y `api-secret.yaml`.

ConfigMap (no secretos):

```yaml
data:
  REDIS_URL: redis://redis:6379/0
  SERVICE_NAME: cloudnative-demo-api
  PORT: "8081"
```

Secret (`stringData`):

```yaml
DATABASE_URL: postgres://lab:lab@postgres:5432/lab
```

**Por qué:** Misma separación que en M02 — Flask lee `${DATABASE_URL}` del entorno; en K8s lo inyectas con `envFrom`.

---

### 3 — Deployment API Flask

**Acción:** `api-deployment.yaml` con:

| Campo | Valor |
|-------|-------|
| `image` | `cloudnative-demo-api:local` |
| `imagePullPolicy` | `IfNotPresent` |
| `replicas` | `2` |
| `livenessProbe` | `GET /health:8081` |
| `readinessProbe` | `GET /ready:8081` |
| `envFrom` | configMapRef + secretRef |

**Por qué:** Los probes de /health y /ready son el contrato estándar en Flask — igual que usarías en AKS o EKS.

Crea `api-service.yaml` (ClusterIP, puerto 8081).

---

### 4 — Frontend nginx estático

**Acción:** `web-deployment.yaml` + `web-service.yaml` (NodePort 30080 → 8080).

La imagen `cloudnative-demo-web:local` sirve el build nginx estático con nginx y proxy `/api/` hacia la API.

---

### 5 — Redis

**Acción:** `redis.yaml` — Deployment + Service puerto 6379.

---

### 6 — Desplegar en kind

```bash
docker compose -f infra/docker-compose.yml build demo-api demo-web
kind load docker-image cloudnative-demo-api:local --name cloudnative-lab
kind load docker-image cloudnative-demo-web:local --name cloudnative-lab
kubectl apply -f infra/k8s/base/namespace.yaml
kubectl apply -f infra/k8s/base/ -n cloudnative-lab
kubectl -n cloudnative-lab get pods -w
```

**Resultado esperado:** Pods `demo-api` en `Running` y readiness OK (Postgres lo añades en M03-03; hasta entonces `/ready` puede fallar si falta DB — puedes desplegar postgres de la solución m03-03 temporalmente o aceptar AVISO en readiness).

> [!TIP]
> Para este lab, incluye también el `postgres-statefulset.yaml` de `infra/k8s/solutions/m03-03/` si quieres readiness completo, o continúa en M03-03.

---

### 7 — Verificar

```bash
./scripts/lab-verify.sh m03-01
kubectl -n cloudnative-lab port-forward svc/demo-api 8081:8081 &
curl -s http://127.0.0.1:8081/health | jq .
curl -s http://127.0.0.1:8081/work | jq .
```

## Comprueba tu entendimiento

**¿Por qué ConfigMap y Secret separados?**

→ Rotación y permisos distintos; los secretos no van en texto plano en Git en producción.

**¿Qué probe usa Flask para Kubernetes?**

→ Liveness/readiness en `/health/*` tras M02-01.

## Errores frecuentes

| Síntoma | Causa | Arreglo |
|---------|-------|---------|
| `ImagePullBackOff` | Imagen no cargada en kind | `kind load docker-image ...` |
| CrashLoop `KeyError` JDBC | Falta Secret | Revisa `envFrom` y secret |
| Readiness 503 | Postgres ausente | M03-03 o postgres temporal |

→ **[M03-02 — Estrategias de despliegue](M03-02-estrategias-despliegue.md)**
