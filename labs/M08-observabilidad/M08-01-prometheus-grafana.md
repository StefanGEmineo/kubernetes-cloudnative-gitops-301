# M08-01 — Prometheus y Grafana

[← Página anterior](README.md) · [Siguiente página →](M08-02-logging-elk.md)

## Objetivo

Monitorizar la **API Flask** (logs + disponibilidad `/health`) con Prometheus y Grafana en kind.

## Prerrequisitos

- App desplegada con endpoint `/health` (solución M02-01).
- M06 completado o stack demo en `cloudnative-lab`.

## Antes de empezar

```bash
./scripts/lab-prepare.sh m08-01
```

---

### 1 — Desplegar stack

Implementa manifests en `infra/observability/` basándote en `infra/observability/solutions/`, o para validar:

```bash
./scripts/obs-up.sh
```

---

### 2 — Comprobar scrape

```bash
kubectl -n cloudnative-lab port-forward svc/demo-api 8081:8081 &
curl -s http://127.0.0.1:8081/health | head -20
```

Prometheus UI (NodePort 30090 o port-forward):

```bash
kubectl -n observability port-forward svc/prometheus 9090:9090
```

Busca targets `demo-api-flask` UP. En Flask el lab usa `/health` como señal básica; opcionalmente añade `prometheus_client` en M08 para métricas richer.

---

### 3 — Grafana

```bash
kubectl -n observability port-forward svc/grafana 3000:3000
```

Login `admin` / `lab`. Añade datasource Prometheus `http://prometheus:9090`.

---

### 4 — Dashboard

Importa un dashboard de disponibilidad HTTP o crea panel con `up{job="demo-api-flask"}`.

---

→ **[M08-02 — Logging](M08-02-logging-elk.md)**
