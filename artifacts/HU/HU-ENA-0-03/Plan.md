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
| **Última actualización** | 2026-09-28 |
| **Estimación total** | 14 horas |
| **Estado** | EN_PROGRESO |
| **Modo** | Plano |
| **Tasks** | — |

## Progreso General

| Fase | Estado | Progreso |
|------|--------|----------|
| Fase 1: Infraestructura (Terraform) | ✅ Completada | 3/3 tareas |
| Fase 2: Workflow base | ✅ Completada | 3/3 tareas |
| Fase 3: Seguridad | ✅ Completada | 2/2 tareas |
| Fase 4: Deploy | ⬜ Pendiente | 0/2 tareas |
| Fase 5: Testing / Validación de pipeline | ⬜ Pendiente | 0/1 tareas |
| Fase Final: Validación CA | ⬜ Pendiente | 0/9 criterios |

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

#### EJEC-09: Deploy automático a dev (ECS rolling) [PENDIENTE]
- [ ] Job `deploy-dev` tras Trivy verde: `aws ecs update-service --force-new-deployment`
- [ ] Auto en push a `main`; elegible en PR (CA-06)
- **Estimación:** 1.5h | **Dependencia:** EJEC-01, EJEC-02, EJEC-05, EJEC-07

#### EJEC-10: Deploy manual a prod (approval gate) [PENDIENTE]
- [ ] Crear GitHub Environment `prod` con **required reviewers** (decisión #3)
- [ ] Job `deploy-prod` con `environment: prod` — aprobación manual (CA-06)
- **Estimación:** 0.5h | **Dependencia:** EJEC-09

---

## Fase 5: Testing / Validación de pipeline (TDD de pipeline)

### Pruebas E2E del workflow

#### EJEC-11: Validación del fail-gate y del OIDC [PENDIENTE]
- [ ] PR de prueba → pipeline corre completo (checkout → tests → build → scan → SBOM)
- [ ] PR con imagen vulnerable intencional → pipeline **falla** en Trivy (CA-02, requisito de ADR-009)
- [ ] Log de `configure-aws-credentials` muestra role assumption sin keys (CA-07)
- [ ] Artifact SBOM visible con retención 90 días (CA-03)
- **Estimación:** 1h | **Dependencia:** EJEC-06, EJEC-08, EJEC-10

---

## Fase Final: Validar Criterios de Aceptación

> 📌 **Los CAs viven en el refinamiento** (fuente de verdad). Esta sección trackea ESTADO de verificación.

### Estado de Verificación de CAs

| CA | Resumen | Verificado |
|----|---------|:----------:|
| CA-01 | Pipeline completo PR → deploy dev | [~] Parcial — cierre con servicio patrón en **ENA-0-04** (decisión Q3-A) |
| CA-02 | Trivy CRITICAL/HIGH → check failed | [ ] |
| CA-03 | SBOM artifact retención 90 días | [ ] |
| CA-04 | Build Java con Gradle + cache | [~] Parcial — cierre en **ENA-0-04/ENA-0-09** (sin código Java aún) |
| CA-05 | Build Go con cache de modules | [~] Parcial — cierre en **ENA-0-09** (servicio `notificacion`) |
| CA-06 | dev automático / prod aprobación manual | [ ] |
| CA-07 | OIDC sin claves estáticas | [ ] |
| CA-08 | tests/build fallan → check failed | [~] Parcial — cierre con servicio en **ENA-0-04** |
| CA-09 | Health check falla → rollback ECS | [~] Parcial — revert real requiere servicio en **ENA-0-04** |

> `[~]` = marcador de dependencia futura, no de incumplimiento — trazabilidad registrada en Refinamiento §Preguntas #8.

### Validación Final

- [ ] `terraform plan` sin errores (workspaces `dev` y `prod`)
- [ ] Workflow verde con `workflow_dispatch`
- [ ] Prueba de fail-gate con imagen vulnerable (requisito ADR-009)
- [ ] Sin Access Keys en logs ni en variables del repo
- [ ] Revisión de código completada

---

## Notas de Implementación

### Decisiones Técnicas

| # | Decisión | Origen |
|---|----------|--------|
| Q1-A | Slice 0 infra (ECR + ECS + OIDC) dentro de esta HU | Planificación 2026-09-28 |
| Q2-B | Build tool Java = **Gradle** | Planificación 2026-09-28 |
| Q3-A | Validación parcial; CA-01/04/05/08/09 se cierran en ENA-0-04 | Planificación 2026-09-28 |
| #3 | GitHub Environments con required reviewers para prod | Refinamiento Iteración 1 |

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
