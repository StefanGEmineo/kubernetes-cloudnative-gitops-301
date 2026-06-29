# M01-01 — Bootstrap del entorno

[← Página anterior](README.md) · [Siguiente página →](M01-02-aplicacion-demo.md)

> Práctica del módulo. La teoría y la tabla de scripts están en el [README del módulo](README.md).

### Objetivo

Dejar operativo tu fork, Codespace, clúster **kind** y herramientas del curso, entendiendo **qué hace cada script** que vas a usar.

### Prerrequisitos

- Cuenta GitHub personal.
- Navegador actualizado y acceso a GitHub Codespaces.

### En qué consiste

Fork del repositorio, arranque del Codespace, creación del clúster Kubernetes local y validación con los scripts de bootstrap y comprobación.

---

### 1 — Fork y Codespace

**Acción:** Haz fork de `my-it-labs/kubernetes-cloudnative-gitops-301` en tu cuenta GitHub. Desde tu fork, abre **Code → Codespaces → Create codespace on main**.

**Por qué:** Cada alumno trabaja en su copia y conserva el material al finalizar el curso.

**Resultado esperado:** Terminal en `/workspaces/kubernetes-cloudnative-gitops-301` (o el nombre de tu fork).

---

### 2 — Herramientas: `bootstrap-tools.sh`

**Acción:** Al crear el Codespace, el devcontainer ejecuta automáticamente:

```bash
chmod +x scripts/*.sh && bash scripts/bootstrap-tools.sh
```

Si dudas de que terminó, ejecuta manualmente:

```bash
bash scripts/bootstrap-tools.sh
command -v kind kustomize kubectl helm docker
```

**Qué hace el script:**

| Paso | Acción del script | Para qué sirve |
|------|-------------------|----------------|
| kind | Descarga e instala el binario kind si falta | kind no viene en todas las imágenes base; lo necesitas para el clúster local |
| kustomize | Instala kustomize si falta | Empaquetado de manifests (módulo M04) |

**Por qué no instalas tú a mano:** Misma versión y mismo PATH para todos los alumnos; menos tiempo perdido en el primer lab.

**Resultado esperado:** `docker info` sin error; `kind`, `kubectl`, `helm`, `kustomize` responden en terminal.

---

### 3 — Clúster local: `kind-up.sh`

**Acción:**

```bash
./scripts/kind-up.sh
```

**Qué hace el script:**

1. Localiza `infra/kind/cluster-config.yaml`.
2. Si no existe un clúster llamado **`cloudnative-lab`**, ejecuta `kind create cluster`.
3. Si ya existe, lo deja intacto (idempotente).
4. Muestra `kubectl cluster-info` del contexto `kind-cloudnative-lab`.

**Por qué usamos un script y no solo `kind create cluster`:**

- Nombre fijo del clúster → mismos comandos en todos los labs.
- Config del curso (mapeo de puertos ingress) aplicada siempre.
- Evitas crear clústers duplicados con nombres distintos.

**Resultado esperado:**

```bash
kubectl get nodes
# cloudnative-lab-control-plane   Ready   control-plane
```

---

### 4 — Diagnóstico: `health-check.sh`

**Acción:**

```bash
./scripts/health-check.sh
```

**Qué hace el script (por bloques):**

| Bloque | Comprueba | Mensaje si falla |
|--------|-----------|------------------|
| Docker | Daemon accesible | `FALTA: Docker no responde` |
| kind | Clúster `cloudnative-lab` existe | `AVISO: clúster no creado` |
| Herramientas | kubectl, helm, kustomize en PATH | `FALTA: <cmd>` |
| Stack demo | HTTP 8080 / 8081 (con reintentos) | `AVISO: no responde` *(normal hasta M01-02)* |

**Por qué:** Un único comando resume el estado del entorno antes de avanzar; en cursos largos ahorra depurar «¿está Docker? ¿está kind?».

**Resultado esperado:** `OK:` en Docker, kind y herramientas. La stack demo puede ser AVISO hasta el siguiente lab.

---

### 5 — Destruir y recrear (opcional): `kind-down.sh`

**Acción:** Solo si necesitas resetear Kubernetes:

```bash
./scripts/kind-down.sh
./scripts/kind-up.sh
```

**Qué hace:** Elimina el clúster `cloudnative-lab`. No toca imágenes Docker ni la stack Compose.

**Cuándo usarlo:** Nodo `NotReady`, pruebas destructivas en M03+, o liberar RAM.

---

### 6 — Contexto kubectl

**Acción:** `kubectl config current-context`

**Por qué:** Debes operar sobre `kind-cloudnative-lab`, no sobre otro contexto residual.

**Resultado esperado:** `kind-cloudnative-lab`.

---

## Comprueba tu entendimiento

**Clúster listo**

`kubectl get nodes -o wide`

→ Un nodo `control-plane` en estado `Ready`.

**Scripts idempotentes**

Ejecuta `./scripts/kind-up.sh` dos veces seguidas.

→ La segunda vez indica que el clúster ya existe (no error).

**Mapa mental**

Sin mirar el README, explica en una frase qué diferencia hay entre `kind-up.sh` y `health-check.sh`.

→ `kind-up` **crea** infraestructura; `health-check` **verifica** estado.

## Reto

### 1 — Inspecciona un script

Abre `scripts/kind-up.sh` y localiza la variable `CLUSTER_NAME`.

<details>
<summary>Ver orientación</summary>

Valor: `cloudnative-lab`. Debe coincidir con el nombre en `infra/kind/cluster-config.yaml` y con el contexto kubectl `kind-cloudnative-lab`.

</details>

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| `kind: command not found` | postCreate no terminó | `bash scripts/bootstrap-tools.sh` |
| Nodo `NotReady` | Docker sin recursos | Codespace 8 GB; `./scripts/kind-down.sh && ./scripts/kind-up.sh` |
| Contexto kubectl incorrecto | Otro cluster por defecto | `kubectl config use-context kind-cloudnative-lab` |
| `kind create cluster` timeout | Descarga lenta de imagen K8s | Repetir `kind-up` o `kind-down` + `kind-up` |
