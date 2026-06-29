# M07 — Kubernetes en Azure (AKS) — referencia

[← Página anterior](../M06-gitops-argocd/M06-03-promocion-entornos.md) · [Siguiente página →](M07-01-despliegue-aks.md)

> [!IMPORTANT]
> **Contenido de referencia.** No necesitas suscripción Azure ni ejecutar estos pasos en tu Codespace. Tu práctica del curso es sobre **kind**.

## Qué aprenderás

- Diferencias entre un clúster **kind** local y **AKS** gestionado en Azure.
- Qué cambia (y qué no) al pasar la misma imagen Docker a un servicio managed.
- Consideraciones de despliegue en cloud: identidad, networking, registries, add-ons.

## Teoría

| Aspecto | kind (lab del curso) | AKS (Azure) |
|---------|----------------------|-------------|
| Provisión | `./scripts/kind-up.sh` local | Servicio gestionado (portal, CLI, Terraform) |
| Control plane | Contenedor Docker en Codespace | Operado por Microsoft |
| Persistencia | Volúmenes locales al entorno | Azure Disk / Files (CSI) |
| Exposición | NodePort / mapeo kind | Azure Load Balancer, Application Gateway |
| Identidad | N/A en lab básico | Managed Identity, AAD integration |
| Registry | GHCR / Docker Hub | ACR integrado con AKS |
| Coste | Incluido en Codespace | Suscripción Azure |

**Lo que no cambia:** la imagen OCI, variables de entorno, endpoints `/health` y `/ready`, y el chart Helm que empaquetarás en M04 — diseñados en M02 precisamente para ser portables.

## Lectura recomendada

| Página | Contenido |
|--------|-----------|
| M07-01 | [Despliegue en AKS — comparativa y checklist](M07-01-despliegue-aks.md) | LAB 14 (referencia) |

→ Continúa con **[M08 — Observabilidad](../M08-observabilidad/README.md)**.
