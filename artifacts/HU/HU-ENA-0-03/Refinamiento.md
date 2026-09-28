# Refinamiento: HU-ENA-0-03 - Pipeline Patrón CI/CD

## Metadata

| Campo | Valor |
|-------|-------|
| **ID** | HU-ENA-0-03 |
| **Título** | Pipeline Patrón CI/CD |
| **Complejidad** | 🔴 ALTO |
| **Story Points** | 13 SP |
| **Estimación Horas** | 12-14 horas |
| **Fecha refinamiento** | 2026-09-12 |
| **Iteración** | 3 |
| **Modo** | Plano |
| **Tasks** | — |

---

## 1. Historia de Usuario

**Como** equipo de desarrollo,
**Quiero** tener un workflow reutilizable de CI/CD,
**Para** que cada servicio despliegue de forma segura y automatizada.

---

## 2. Criterios de Aceptación

- [ ] **CA-01:** Dado que creo un PR, cuando el pipeline se ejecuta, entonces pasa por: checkout → tests → build (imagen Docker) → push a ECR → Trivy scan → SBOM → deploy (dev)
- [ ] **CA-02:** Dado que Trivy detecta un hallazgo CRITICAL o HIGH, cuando el pipeline termina, entonces el check del PR queda en `failed` (merge bloqueado por convención — sin branch protection en plan Free, ADR-009)
- [ ] **CA-03:** Dado que el build es exitoso, cuando se genera el SBOM (CycloneDX), entonces se guarda como artifact del workflow con retención de **90 días**
- [ ] **CA-04:** Dado que el servicio es Java, cuando se ejecuta el build, entonces usa **Gradle** con cache de dependencias
- [ ] **CA-05:** Dado que el servicio es Go, cuando se ejecuta el build, entonces usa `go build` con cache de modules
- [ ] **CA-06:** Dado que el deploy es a dev, cuando se ejecuta, entonces es automático; si es a prod, entonces requiere aprobación manual vía **GitHub Environments (required reviewers)**
- [ ] **CA-07:** Dado que el pipeline usa OIDC, cuando accede a AWS, entonces no hay claves estáticas (role assumption)
- [ ] **CA-08:** Dado que los tests o el build fallan, cuando termina el pipeline, entonces el check del PR queda en `failed` (fail-gate)
- [ ] **CA-09:** Dado que el health check de la task ECS falla, cuando se detecta en el deploy rolling, entonces **ECS deployment circuit breaker revierte automáticamente** a la revisión anterior

---

## 3. Preguntas de Clarificación

### Resueltas ✅

| # | Pregunta | Respuesta | Impacto |
|---|----------|-----------|---------|
| 1 | ¿OIDC o claves estáticas? | OIDC (zero static keys) | Alto |
| 2 | ¿Deploy automático en prod? | No, aprobación manual | Alto |
| 3 | ¿Usamos GitHub Environments para proteger prod? | **Sí** — usar environments de GitHub (prod con *required reviewers*); es la implementación nativa del CA-06, sin código adicional | Alta |
| 4 | ¿CA para tests/build fallan y rollback en health check? | **Sí** — añadidos CA-08 (fail-gate) y CA-09 (ECS circuit breaker, feature nativa) | Alta |
| 5 | ¿Umbral de duración del pipeline? | Objetivo informativo **≤ 10 min con cache caliente**, sin fail-gate (sin gate en ADR-009) | Media |
| 6 | ¿Build tool Java: Maven o Gradle? | **Gradle** (decisión en planificación, Q2 — más rápido en CI, curva aceptable para el equipo) | Media |
| 7 | ¿Dónde va la infra ECS/ECR/OIDC? | **Slice 0 en esta HU** (Q1-A) — módulos Terraform `ecr`, `ecs`, `oidc-role`; coherente con nota de ENA-0-02 "ECS en ENA-0-03" | Alta |
| 8 | ¿Cómo verificar CAs sin código en services/? | **Validación parcial** (Q3-A): workflow/OIDC/Trivy/SBOM verificables aquí; CA-01/04/05/08/09 se cierran con el servicio patrón en HU-ENA-0-04 | Alta |

### Pendientes ❓

| # | Pregunta | Prioridad |
|---|----------|-----------|
| — | Sin preguntas pendientes | — |

---

## 4. Desglose Técnico (Vertical)

### MODO PLANO

#### Slice 0: Infraestructura de deploy (decisión Q1-A)

| ID Tarea | Descripción | Capa | Estimación |
|----------|-------------|------|------------|
| HU-ENA-0-03-INF-01 | Módulo Terraform ECR (repo por servicio, naming pattern) | Infra | 1h |
| HU-ENA-0-03-INF-02 | Módulo Terraform ECS Fargate (cluster, service, task def con health check + circuit breaker, IAM task role) | Infra | 2h |
| HU-ENA-0-03-INF-03 | Rol IAM OIDC para GitHub Actions (role assumption, permisos ECR/ECS) | Infra | 1h |

#### Slice 1: Workflow base

| ID Tarea | Descripción | Capa | Estimación |
|----------|-------------|------|------------|
| HU-ENA-0-03-CI-01 | Crear workflow reutilizable `.github/workflows/service-ci.yml` | CI/CD | 2h |
| HU-ENA-0-03-CI-02 | Configurar OIDC con AWS (role assumption) | CI/CD | 1.5h |
| HU-ENA-0-03-CI-03 | Configurar cache de dependencias (Maven + Go modules) | CI/CD | 1h |

#### Slice 2: Seguridad

| ID Tarea | Descripción | Capa | Estimación |
|----------|-------------|------|------------|
| HU-ENA-0-03-SEC-01 | Integrar Trivy scan con fail-gate CRITICAL/HIGH | Seguridad | 1.5h |
| HU-ENA-0-03-SEC-02 | Generar SBOM como artifact del workflow | Seguridad | 1h |

#### Slice 3: Deploy

| ID Tarea | Descripción | Capa | Estimación |
|----------|-------------|------|------------|
| HU-ENA-0-03-DEP-01 | Configurar deploy automático a dev (ECS rolling + circuit breaker) | Deploy | 1.5h |
| HU-ENA-0-03-DEP-02 | Configurar deploy manual a prod (approval gate) | Deploy | 0.5h |

---

## 5. Estimación

### Desglose

| Factor | Valor | Justificación |
|--------|-------|---------------|
| Complejidad base | 5 SP | Workflow reutilizable + OIDC + Trivy |
| Incertidumbre | +2 SP | OIDC puede requerir troubleshooting |
| Riesgo | +1 SP | Integración con ECS |
| Infra deploy (Q1-A) | +5 SP | Módulos Terraform ECR + ECS + OIDC role |
| **Total SP** | **13 SP** | — |

### Estrategia Recomendada

- **Enfoque:** TDD de pipeline (crear workflow → probar con PR de prueba → validar fail-gate)
- **Razón:** El pipeline es la base de todo el CI/CD del proyecto

---

## 6. Riesgos y Dependencias

### Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| OIDC falla con permisos AWS | Media | Alto | Usar[AWS guide for GitHub OIDC](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services) como referencia |
| Trivy genera falsos positivos | Baja | Medio | Configurar severity gates |

### Dependencias

| Tipo | Referencia | Estado |
|------|------------|--------|
| HU previa | HU-ENA-0-02 (Terraform) | ✅ Completado |
| Decisión | ADR-003 | ✅ Aprobado |
| Decisión | ADR-009 (patrón pipeline) | ✅ Aprobado |

**Fuera de alcance de esta HU (trazabilidad ADR-009):** Lint (Checkstyle/PMD/golangci-lint) → HU-ENA-0-08 · Contract test (Spectral) → HU-ENA-0-06 · Gate de cobertura ≥80% → HU-ENA-0-10.

---

## Feedback de Validación

> ✅ **Iteración 1 → cerrada:** las 7 observaciones y 3 preguntas abiertas fueron resueltas en Iteración 2 (2026-09-28) — ver `## Aprobación`. Se conserva como histórico.

**Veredicto Iteración 1:** ⚠️ **AJUSTES** — HU se mantuvo en `[R] Refinada`

**Base de validación:** ADR-003 (CI/CD) · `reglas_arquitectonicas.md` no existe → mejores prácticas generales.

### Observaciones

| # | CA / Área | Hallazgo | Tipo |
|---|-----------|----------|------|
| 1 | CA-01 | No define el resultado cuando **tests o build fallan** (¿PR bloqueado?) | Cobertura de error |
| 2 | CA-06 | No define **rollback** si el health check de ECS falla en el deploy rolling | Cobertura de error |
| 3 | CA-01 | Sin **umbral de performance** del pipeline (ej. duración < 10 min) | Performance |
| 4 | CA-03 | Retención del artifact **SBOM** indefinida | Ambigüedad |
| 5 | CA-04 | "Maven/Gradle" sin definir **cuál usa cada servicio Java** | Ambigüedad |
| 6 | CA-0-02 | ID rompe el patrón `CA-0N` (inconsistencia de trazabilidad) | Consistencia |
| 7 | CA-01 | No menciona **push de imagen a ECR** (paso implícito build→deploy según ADR-003 §CI/CD) | Trazabilidad ADR |

### Preguntas Abiertas

1. ¿Añadimos CA explícito para "tests/build fallan ⇒ PR bloqueado" y para "health check falla ⇒ rollback automático"?
2. ¿Definimos umbral de duración del pipeline (performance gate)?
3. ¿Cuál es el build tool Java del proyecto: Maven o Gradle?

### Sin hallazgos ✅

- SMART en CA-02, CA-05, CA-06, CA-07 · Dependencias resueltas (HU-ENA-0-02 ✅, ADR-003 ✅)
- Coherencia con ADR-003: GitHub Actions → ECR → rolling ECS ✅ · OIDC cero claves estáticas ✅
- Vertical slicing correcto (3 slices entregables end-to-end) · GitHub Environments resuelve CA-06

> **Validador:** Arquitecto - javier-garcia
> **Fecha:** 2026-09-28
> **Siguiente:** >refinar_hu HU-ENA-0-03

---

## Aprobación

| Campo | Valor |
|-------|-------|
| **Estado** | ✅ APROBADA (Iteración 2) |
| **Aprobado por** | javier-garcia |
| **Fecha aprobación** | 2026-09-28 |

**Veredicto revalidación:** ✅ Sin hallazgos — 7 observaciones de Iteración 1 resueltas; dependencias (HU-ENA-0-02, ADR-003, ADR-009) completadas; coherencia arquitectónica confirmada; 9 CAs SMART verificables; 3 slices verticales.

> **Validador:** Arquitecto - javier-garcia
> **Fecha:** 2026-09-28
> **Siguiente:** >planificar_hu HU-ENA-0-03

---

## Historial

| Fecha | Acción | Detalle |
|-------|--------|---------|
| 2026-09-12 | Refinamiento inicial | Iteración 1 |
| 2026-09-28 | Resolución pregunta #3 | GitHub Environments para prod (required reviewers) — sin preguntas pendientes |
| 2026-09-28 | Iteración 2 (ajustes de validación) | CA-01 + ECR · CA-0-02→CA-02 · CA-03 retención 90d · CA-04 Maven · CA-09 circuit breaker · CA-08 fail-gate tests/build · preguntas #4-#6 resueltas · alcance lint/contract/coverage externalizado |
| 2026-09-28 | Iteración 3 (ambigüedades de planificación) | Q1-A: Slice 0 infra (ECR/ECS/OIDC, +4h, 13 SP, 🔴 ALTO) · Q2-B: Gradle · Q3-A: validación parcial (CA-01/04/05/08/09 se cierran en ENA-0-04) |

---

> **Archivo:** `artifacts/HU/HU-ENA-0-03/Refinamiento.md`
> **Creado por:** `refinar-hu`
