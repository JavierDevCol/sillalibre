# Refinamiento: HU-ENA-0-03 - Pipeline Patrón CI/CD

## Metadata

| Campo | Valor |
|-------|-------|
| **ID** | HU-ENA-0-03 |
| **Título** | Pipeline Patrón CI/CD |
| **Complejidad** | 🟡 MEDIO |
| **Story Points** | 8 SP |
| **Estimación Horas** | 8-10 horas |
| **Fecha refinamiento** | 2026-09-12 |
| **Iteración** | 1 |
| **Modo** | Plano |
| **Tasks** | — |

---

## 1. Historia de Usuario

**Como** equipo de desarrollo,
**Quiero** tener un workflow reutilizable de CI/CD,
**Para** que cada servicio despliegue de forma segura y automatizada.

---

## 2. Criterios de Aceptación

- [ ] **CA-01:** Dado que creo un PR, cuando el pipeline se ejecuta, entonces pasa por: checkout → tests → build → Trivy scan → SBOM → deploy (dev)
- [ ] **CA-0-02:** Dado que Trivy detecta un hallazgo CRITICAL o HIGH, cuando el pipeline termina, entonces el PR queda bloqueado (fail-gate)
- [ ] **CA-03:** Dado que el build es exitoso, cuando se genera el SBOM, entonces se guarda como artifact del workflow
- [ ] **CA-04:** Dado que el servicio es Java, cuando se ejecuta el build, entonces usa Maven/Gradle con cache de dependencias
- [ ] **CA-05:** Dado que el servicio es Go, cuando se ejecuta el build, entonces usa `go build` con cache de modules
- [ ] **CA-06:** Dado que el deploy es a dev, cuando se ejecuta, entonces es automático; si es a prod, entonces requiere aprobación manual
- [ ] **CA-07:** Dado que el pipeline usa OIDC, cuando accede a AWS, entonces no hay claves estáticas (role assumption)

---

## 3. Preguntas de Clarificación

### Resueltas ✅

| # | Pregunta | Respuesta | Impacto |
|---|----------|-----------|---------|
| 1 | ¿OIDC o claves estáticas? | OIDC (zero static keys) | Alto |
| 2 | ¿Deploy automático en prod? | No, aprobación manual | Alto |

### Pendientes ❓

| # | Pregunta | Prioridad |
|---|----------|-----------|
| 1 | ¿Usamos GitHub Environments para proteger prod? | Alta |

---

## 4. Desglose Técnico (Vertical)

### MODO PLANO

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
| HU-ENA-0-03-DEP-01 | Configurar deploy automático a dev (ECS rolling) | Deploy | 1.5h |
| HU-ENA-0-03-DEP-02 | Configurar deploy manual a prod (approval gate) | Deploy | 0.5h |

---

## 5. Estimación

### Desglose

| Factor | Valor | Justificación |
|--------|-------|---------------|
| Complejidad base | 5 SP | Workflow reutilizable + OIDC + Trivy |
| Incertidumbre | +2 SP | OIDC puede requerir troubleshooting |
| Riesgo | +1 SP | Integración con ECS |
| **Total SP** | **8 SP** | — |

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
| HU previa | HU-ENA-0-02 (Terraform) | ⏳ Pendiente |
| Decisión | ADR-003 | ✅ Aprobado |

---

## Aprobación

| Campo | Valor |
|-------|-------|
| **Estado** | ⏳ Pendiente |
| **Aprobado por** | — |
| **Fecha aprobación** | — |

---

## Historial

| Fecha | Acción | Detalle |
|-------|--------|---------|
| 2026-09-12 | Refinamiento inicial | Iteración 1 |

---

> **Archivo:** `artifacts/HU/HU-ENA-0-03/Refinamiento.md`
> **Creado por:** `refinar-hu`
