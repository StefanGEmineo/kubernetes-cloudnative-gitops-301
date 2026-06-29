# M07-01 — Despliegue en AKS — comparativa y checklist

[← Página anterior](README.md) · [Siguiente página →](../M08-observabilidad/README.md)

> **Lectura de referencia.** No ejecutas comandos Azure en este curso; comparas conceptos con tu entorno **kind**.

## Objetivo

Entender qué implica desplegar la misma aplicación del curso en **AKS** frente a **kind**, y qué decisiones ya resolviste en M02 al diseñar la imagen.

## En qué consiste

Repaso conceptual del LAB 14 del temario: mismos artefactos (imagen, variables, Helm), distinta plataforma de ejecución.

## Misma app, distinta plataforma

| Paso | En kind (curso) | Equivalente en AKS |
|------|-----------------|---------------------|
| Clúster | `kind-up.sh` | `az aks create` o portal |
| Imagen | Build local / GHCR | Misma imagen en ACR o GHCR |
| Config | Variables de entorno | App settings, Key Vault refs, Secrets |
| Despliegue | `kubectl` / Helm | Mismos manifiestos Helm del curso |
| Exposición | Service NodePort / ingress kind | Service LoadBalancer / Ingress + AGIC |
| Observabilidad | Stack en kind (M08) | Azure Monitor, Managed Prometheus (opcional) |

## Checklist: imagen lista para AKS

Gracias a M02, tu imagen ya cumple buena parte de lo que AKS espera:

| Requisito | Cómo lo cubriste |
|-----------|------------------|
| Config externa | Variables de entorno, no hardcode |
| Puerto configurable | `PORT` / 8081 |
| Health probes | `/health` y `/ready` |
| No-root | `USER app` en Dockerfile multistage |
| Imagen en registry | Pipeline M05 → GHCR (aplicable a ACR) |

## Diferencias que suelen sorprender

| Tema | kind | AKS |
|------|------|-----|
| Tiempo de provisión | Segundos–minutos | Minutos–decenas de minutos |
| Alta disponibilidad | Un nodo (lab) | Node pools, zonas, SLA |
| Red | Aislada al Codespace | VNet, subnets, NSG |
| Secretos | Fichero local (lab) | Key Vault + CSI driver |

## Comprueba tu entendimiento

**Portabilidad**

¿Tendrías que recompilar la imagen para pasar de kind a AKS?

→ No, si la config va por entorno (M02).

**Control plane**

¿Quién parchea la versión de Kubernetes en AKS?

→ Microsoft (servicio gestionado); en kind eres tú vía imagen kindest/node.

## Siguiente módulo

→ **[M08 — Observabilidad](../M08-observabilidad/README.md)**
