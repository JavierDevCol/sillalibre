# Refinamiento: HU-ENA-0-06 - Contratos OpenAPI desde el Día 1

## Metadata

| Campo | Valor |
|-------|-------|
| **ID** | HU-ENA-0-06 |
| **Título** | Contratos OpenAPI desde el Día 1 |
| **Complejidad** | 🟢 BAJO |
| **Story Points** | 3 SP |
| **Estimación Horas** | 3-4 horas |
| **Fecha refinamiento** | 2026-09-12 |
| **Iteración** | 1 |
| **Modo** | Plano |
| **Tasks** | — |

---

## 1. Historia de Usuario

**Como** equipo de desarrollo,
**Quiero** tener specs OpenAPI 3 versionadas por servicio con lint y backward-compat,
**Para** que el pipeline rechace cambios rompientes.

---

## 2. Criterios de Aceptación

- [ ] **CA-01:** Dado que un servicio tiene API, cuando reviso su spec, entonces existe `openapi.yaml` versionado (v1, v2, etc.) en la raíz del servicio
- [ ] **CA-02:** Dado que el pipeline se ejecuta, cuando corre spectral lint, entonces la spec pasa sin errores de estilo
- [ ] **CA-03:** Dado que hago un cambio rompiente en la spec, cuando el pipeline lo detecta, entonces falla con error de backward-compat (requiere bump de versión mayor)
- [ ] **CA-04:** Dado que la spec es válida, cuando la proceso, entonces puedo generar stubs de cliente/servidor (codegen)

---

## 3. Preguntas de Clarificación

### Resueltas ✅

| # | Pregunta | Respuesta | Impacto |
|---|----------|-----------|---------|
| 1 | ¿Spectral o otra herramienta? | Spectral (estándar de la industria) | Bajo |

### Pendientes ❓

| # | Pregunta | Prioridad |
|---|----------|-----------|
| 1 | ¿Usamos Rego (OPA) para backward-compat o spectral plugin? | Baja |

---

## 4. Desglose Técnico (Vertical)

### MODO PLANO

#### Slice 1: Configuración OpenAPI

| ID Tarea | Descripción | Capa | Estimación |
|----------|-------------|------|------------|
| HU-ENA-0-06-OAS-01 | Crear plantilla `openapi.yaml` base para servicios | Configuración | 1h |
| HU-ENA-0-06-OAS-02 | Configurar `.spectral.yml` con reglas de estilo | Configuración | 1h |

#### Slice 2: Integración Pipeline

| ID Tarea | Descripción | Capa | Estimación |
|----------|-------------|------|------------|
| HU-ENA-0-06-CI-01 | Agregar step de spectral lint al pipeline patrón | CI/CD | 0.5h |
| HU-ENA-0-06-CI-02 | Agregar chequeo backward-compat (breaking change detection) | CI/CD | 1h |

---

## 5. Estimación

### Desglose

| Factor | Valor | Justificación |
|--------|-------|---------------|
| Complejidad base | 2 SP | Configuración estándar |
| Incertidumbre | +1 SP | Backward-compat puede requerir herramienta adicional |
| Riesgo | +0 SP | Bajo riesgo |
| **Total SP** | **3 SP** | — |

### Estrategia Recomendada

- **Enfoque:** Configuración directa (spectral + pipeline)
- **Razón:** Es configuración, no código complejo

---

## 6. Riesgos y Dependencias

### Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Spectral genera falsos positivos | Baja | Bajo | Ajustar reglas |

### Dependencias

| Tipo | Referencia | Estado |
|------|------------|--------|
| HU previa | HU-ENA-0-03 (Pipeline CI/CD) | ⏳ Pendiente |
| Decisión | ADR-002 | ✅ Aprobado |

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

> **Archivo:** `artifacts/HU/HU-ENA-0-06/Refinamiento.md`
> **Creado por:** `refinar-hu`
