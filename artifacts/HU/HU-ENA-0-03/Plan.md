---
tipo: plan_implementacion
version: "5.0"
generado_por: ">planificar_hu"
actualizado_por: ">ejecutar_plan"
validado_por: ">validar_ca"
---

# Plan de Implementación: HU-ENA-0-03 - Pipeline Patrón CI/CD

## Metadata

| Campo | Valor |
|-------|-------|
| **HU** | HU-ENA-0-03 |
| **Título** | Pipeline Patrón CI/CD |
| **Refinamiento** | HU-ENA-0-03/Refinamiento.md (Iteración 3) |
| **Arquitectura** | Capas (Infra → Pipeline → Deploy) |
| **Generado por** | ArchDev Pro |
| **Fecha creación** | 2026-09-28 |
| **Última actualización** | 2026-09-29 |
| **Estimación total** | 14 horas |
| **Estado** | COMPLETADO |
| **Modo** | Plano |
| **Tasks** | — |

## Progreso General

| Fase | Estado | Progreso |
|------|--------|----------|
| Fase 1: Infraestructura (Terraform) | ✅ Completada | 3/3 tareas |
| Fase 2: Workflow base | ✅ Completada | 3/3 tareas |
| Fase 3: Seguridad | ✅ Completada | 2/2 tareas |
| Fase 4: Deploy | ✅ Completada | 2/2 tareas |
| Fase 5: Testing / Validación de pipeline | ✅ Completada | 1/1 tareas |
| Fase Final: Validación CA | ✅ Completada | 4/9 CUMPLIDO · 5/9 `[~]` delegados a ENA-0-04 (Q3-A) |

---

## Fase 1: Infraestructura (Terraform)

> **Contexto Q1-A:** ECS + ECR + OIDC no existen en `infra/`; ENA-0-02 delegó "ECS en ENA-0-03".

### Módulos de despliegue

#### EJEC-01: Módulo Terraform ECR [EJECUTADA]
- [X] Crear `infra/modules/ecr` (repo por servicio, naming `sillalibre/<servicio>`, image tag = git SHA)
- [X] Declarar output `ecr_repo_urls` consumible por el workflow
- [X] `terraform plan` sin errores en workspace `dev`
- **Estimación:** 1h | **Dependencia:** -

#### EJEC-02: Módulo Terraform ECS Fargate [EJECUTADA]
- [X] Crear `infra/modules/ecs` (cluster, service, task definition con health check HTTP)
- [X] Habilitar **deployment circuit breaker con rollback** (CA-09)
- [X] IAM task role mínimo (CloudWatch Logs + X-Ray según ADR-007)
- [X] `terraform apply` en workspace `dev` con servicio placeholder
- **Estimación:** 2h | **Dependencia:** EJEC-01

#### EJEC-03: Rol IAM OIDC para GitHub Actions [EJECUTADA]
- [X] Crear `infra/modules/oidc-role` (provider `token.actions.githubusercontent.com`, repo app-barber)
- [X] Permisos mínimos: ECR push, ECS update-service/describe, CloudWatch logs
- [X] Sin claves estáticas — solo role assumption (CA-07)
- **Estimación:** 1h | **Dependencia:** EJEC-02

---

## Fase 2: Workflow base

### Workflow reutilizable

#### EJEC-04: Workflow `service-ci.yml` [EJECUTADA]
- [X] Crear `.github/workflows/service-ci.yml` reusable (`workflow_call` con inputs: `servicio`, `lenguaje`)
- [X] Pipeline: checkout → tests → build (imagen Docker) → push ECR → Trivy → SBOM → deploy dev (CA-01) *(Trivy/SBOM/deploy: fases 3-4)*
- [X] Trigger: PR + push a `main` + `workflow_dispatch` *(PR/push vía callers en ENA-0-04)*
- **Estimación:** 2h | **Dependencia:** EJEC-03

#### EJEC-05: Configurar OIDC en el workflow [EJECUTADA]
- [X] `permissions: id-token: write` + `aws-actions/configure-aws-credentials` con `role-to-assume`
- [X] Verificar role assumption sin Access Keys (CA-07) *(verificación: EJEC-11)*
- **Estimación:** 1.5h | **Dependencia:** EJEC-03, EJEC-04

#### EJEC-06: Cache de dependencias (Gradle + Go) [EJECUTADA]
- [X] Cache Gradle (`actions/setup-java` con `cache: gradle` o `gradle/actions/setup-gradle`) — CA-04
- [X] Cache Go modules (`actions/setup-go` con `cache: true`) — CA-05
- **Estimación:** 1h | **Dependencia:** EJEC-04

---

## Fase 3: Seguridad

### Trancha de seguridad del pipeline

#### EJEC-07: Trivy scan con fail-gate [EJECUTADA]
- [X] Integrar `aquasecurity/trivy-action` sobre la imagen construida
- [X] Fail-gate: `exit-code: '1'` solo para CRITICAL/HIGH (CA-02)
- **Estimación:** 1.5h | **Dependencia:** EJEC-04

#### EJEC-08: SBOM como artifact [EJECUTADA]
- [X] Generar SBOM con CycloneDX (trivy o syft) tras el build
- [X] Subir con `actions/upload-artifact` con `retention-days: 90` (CA-03)
- **Estimación:** 1h | **Dependencia:** EJEC-04

---

## Fase 4: Deploy

### Despliegue a ambientes

#### EJEC-09: Deploy automático a dev (ECS rolling) [EJECUTADA]
- [X] Job `deploy-dev` tras Trivy verde: register task definition + `aws ecs update-service --force-new-deployment`
- [X] Automático en ref `main` (push o dispatch); **no corre en PR** (corrección: desplegar PRs al ambiente compartido dev sería inseguro)
- **Estimación:** 1.5h | **Dependencia:** EJEC-01, EJEC-02, EJEC-05, EJEC-07

#### EJEC-10: Deploy manual a prod (approval gate) [EJECUTADA]
- [X] Job `deploy-prod` con `environment: prod` — aprobación manual (CA-06)
- [X] **Mecanismo:** input `deploy_prod=true` en `workflow_dispatch` — *required reviewers* no disponible en plan Free (límite detectado en ejecución; alternativa a la decisión #3)
- **Estimación:** 0.5h | **Dependencia:** EJEC-09

---

## Fase 5: Testing / Validación de pipeline (TDD de pipeline)

### Pruebas E2E del workflow

#### EJEC-11: Validación del fail-gate y del OIDC [EJECUTADA]
- [X] Pipeline corre completo vía `workflow_dispatch` (checkout → scan → SBOM → deploy) — Run 4
- [X] Imagen vulnerable (`nginx:alpine`) → pipeline **falla** en Trivy (CA-02) — Runs 1-2
- [X] Log de `configure-aws-credentials` muestra role assumption sin keys (CA-07) — Run 3+
- [X] Artifact SBOM visible con retención 90 días (CA-03) — `sbom-patron-<sha>` (8.7 KB)
- **Estimación:** 1h | **Dependencia:** EJEC-06, EJEC-08, EJEC-10

**Evidencia de corridas (runner self-hosted `floci-runner`):**

| Run | Imagen | `deploy_prod` | Resultado | Evidencia |
|-----|--------|:---:|-----------|-----------|
| 1 | `nginx:alpine` | true | security ❌ | tag inválido trivy-action → corregido a `v0.36.0` |
| 2 | `nginx:alpine` | true | security ❌ | **CA-02:** `Total: 1 (HIGH: 1)` (CVE expat) → fail-gate exit 1 |
| 3 | `nginx:alpine-slim` | true | deploy-dev ✅ / deploy-prod ❌ | family prod no existía aún → se aplicó workspace `prod` |
| 4 | `nginx:alpine-slim` | true | **✅ verde total** | security + deploy-dev + deploy-prod success (**CA-06 positivo**) |
| 5 | `nginx:alpine-slim` | false | deploy-prod **skipped** | **CA-06 negativo:** sin input no hay deploy a prod |

**Estado final en floci:** cluster `sillalibre-dev` y `sillalibre-prod` → servicio `patron` **ACTIVE 1/1**, task-def `:4` con imagen `nginx:alpine-slim`, contenedores `floci-ecs-*` corriendo.

> ⚠️ **Drift conocido (floci, no del código):** `terraform plan` en ambos workspaces **ejecuta sin errores**, pero propone reemplazar la task definition porque floci **no persiste `containerDefinitions[].healthCheck`** (y normaliza campos de RDS/S3). No aplicar desde TF después de un deploy del pipeline: revierte la imagen al baseline `var.image`.

---

## Fase Final: Validar Criterios de Aceptación

> 📌 **Los CAs viven en el refinamiento** (fuente de verdad). Esta sección trackea ESTADO de verificación.

### Estado de Verificación de CAs

| CA | Resumen | Verificado |
|----|---------|:----------:|
| CA-01 | Pipeline completo PR → deploy dev | [~] Parcial — cierre con servicio patrón en **ENA-0-04** (decisión Q3-A) |
| CA-02 | Trivy CRITICAL/HIGH → check failed | [X] — Runs 1-2 (HIGH real en `nginx:alpine` → exit 1) |
| CA-03 | SBOM artifact retención 90 días | [X] — artifact `sbom-patron-<sha>` subido ANTES del gate |
| CA-04 | Build Java con Gradle + cache | [~] Parcial — cierre en **ENA-0-04** (sin código Java aún) |
| CA-05 | Build Go con cache de modules | [~] Parcial — cierre en **ENA-0-04** (Q3-A; sin código Go aún) |
| CA-06 | dev automático / prod aprobación manual | [X] — Runs 4-5 (gate por input `deploy_prod`; CA enmendado por Q4, ver Refinamiento) |
| CA-07 | OIDC sin claves estáticas | [X] — `configure-aws-credentials` + role assumption OK contra floci |
| CA-08 | tests/build fallan → check failed | [~] Parcial — cierre con servicio en **ENA-0-04** |
| CA-09 | Health check falla → rollback ECS | [~] Parcial — revert real requiere servicio en **ENA-0-04** |

> `[~]` = marcador de dependencia futura, no de incumplimiento — trazabilidad registrada en Refinamiento §Preguntas #8.

### Validación Final

- [X] `terraform plan` sin errores (workspaces `dev` y `prod`)*
- [X] Workflow verde con `workflow_dispatch` (Run 4)
- [X] Prueba de fail-gate con imagen vulnerable (Runs 1-2, requisito ADR-009)
- [X] Sin Access Keys en logs ni en variables del repo (OIDC exclusivo)
- [X] Revisión de código completada (analizar-calidad-codigo scope `commits`: 0 críticos; 10 hallazgos corregidos en `fd0fe56`, smoke run 36536412133 ✅)

> \* Plan ejecuta sin errores; drift residual de floci documentado en EJEC-11.

---

## Notas de Implementación

### Configuración manual requerida (GitHub)

| Dónde | Qué | Valor |
|-------|-----|-------|
| Repo → Actions → Variables | `AWS_ROLE_ARN` | `arn:aws:iam::<cuenta>:role/sillalibre-dev-github-actions` |
| Repo → Actions → Variables | `AWS_REGION` | `us-east-1` |
| Environments → `dev` | Variables: `ECS_CLUSTER` | `sillalibre-dev` |
| Environments → `dev` | Variables: `ECS_TASK_FAMILY` | `sillalibre-dev-patron` |
| Environments → `dev` | Variables: `AWS_ROLE_ARN`, `AWS_REGION` | igual que repo (precedencia de environment) |
| Environments → `prod` | ~~Required reviewers~~ **no disponible en plan Free** → gate = input `deploy_prod=true` al hacer `workflow_dispatch` + variables `ECS_CLUSTER`/`ECS_TASK_FAMILY` con valores `sillalibre-prod*` | — |
| Runner | `floci-runner` (self-hosted, systemd user service) — floci vive en localhost, los runners de GitHub no lo alcanzan | — |
| ⚠️ Transitorio | `AWS_ROLE_ARN` del environment `prod` apunta al rol **dev** — la infra del workspace `prod` todavía no se aplica (ENA-0-03 solo corrió `dev`) | — |

### Decisiones Técnicas

| # | Decisión | Origen |
|---|----------|--------|
| Q1-A | Slice 0 infra (ECR + ECS + OIDC) dentro de esta HU | Planificación 2026-09-28 |
| Q2-B | Build tool Java = **Gradle** | Planificación 2026-09-28 |
| Q3-A | Validación parcial; CA-01/04/05/08/09 se cierran en ENA-0-04 | Planificación 2026-09-28 |
| #3 | GitHub Environments con required reviewers para prod | Refinamiento Iteración 1 |
| Q4 | Approval gate prod = input `deploy_prod` en dispatch | Plan Free no soporta required reviewers (detectado en EJEC-10, 2026-09-28) |

### Riesgos

- OIDC con permisos AWS (prob. media, impacto alto) → referencia: [Configuring OIDC in AWS](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)
- Trivy falsos positivos (baja/medio) → severity gates configurados en EJEC-07

---

## Historial de Ejecución

| Fecha | Acción | Tarea | Resultado |
|-------|--------|-------|-----------|
| 2026-09-28 | Inicio | — | Plan creado (Iteración 3 del refinamiento) |

---

> **Archivo:** `artifacts/HU/HU-ENA-0-03/Plan.md`
> **Creado por:** `>planificar_hu`
> **Actualizado por:** `>ejecutar_plan`
