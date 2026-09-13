# Refinamiento: HU-ENA-0-09 - Scaffold Base de los 8 Microservicios

## Metadata

| Campo | Valor |
|-------|-------|
| **ID** | HU-ENA-0-09 |
| **Título** | Scaffold Base de los 8 Microservicios |
| **Complejidad** | 🔴 ALTO |
| **Story Points** | 13 SP |
| **Estimación Horas** | 12-16 horas |
| **Fecha refinamiento** | 2026-09-12 |
| **Iteración** | 1 |
| **Modo** | Plano |
| **Tasks** | — |

---

## 1. Historia de Usuario

**Como** equipo de desarrollo,
**Quiero** tener esqueletos template-driven para los 8 microservicios,
**Para** que cada servicio esté listo para implementar lógica de negocio.

---

## 2. Criterios de Aceptación

- [ ] **CA-01:** Dado que reviso la estructura de cada servicio, cuando inspecciono, entonces tiene: domain/, application/, adapters/, Dockerfile, openapi.yaml stub, healthcheck endpoint
- [ ] **CA-02:** Dado que el servicio es Java (6 servicios), cuando compilo, entonces pasa CI con JaCoCo configurado
- [ ] **CA-03:** Dado que el servicio es Go (2 servicios: notificacion, descubrimiento), cuando compilo, entonces pasa CI con cobertura configurada
- [ ] **CA-04:** Dado que el servicio tiene patrón asignado, cuando reviso el código stub, entonces declara: Outbox (reserva), CQRS (descubrimiento), Kafka idempotente (fidelizacion, resena), bridge Kafka→RabbitMQ (notificacion), OIDC/JWT (identidad)
- [ ] **CA-05:** Dado que el servicio está desplegado en dev, cuando accedo a `/health`, entonces responde 200 OK
- [ ] **CA-06:** Dado que Spring + notificacion (Go) están desplegados, cuando verifico X-Ray, entonces el trace cruzado es visible
- [ ] **CA-07:** Dado que los 8 servicios compilan, cuando el pipeline corre, entonces todos pasan CI (aunque no estén desplegados)

---

## 3. Preguntas de Clarificación

### Resueltas ✅

| # | Pregunta | Respuesta | Impacto |
|---|----------|-----------|---------|
| 1 | ¿Desplegamos los 8 en dev? | No, solo Spring + notificacion (representativos) | Alto |
| 2 | ¿Los 6 restantes solo compilan? | Sí, compilan + CI pass | Medio |

### Pendientes ❓

| # | Pregunta | Prioridad |
|---|----------|-----------|
| 1 | ¿Usamos Cookiecutter o template manual? | Media |

---

## 4. Desglose Técnico (Vertical)

### MODO PLANO

#### Slice 1: Template base

| ID Tarea | Descripción | Capa | Estimación |
|----------|-------------|------|------------|
| HU-ENA-0-09-TPL-01 | Crear template hexagonal (domain/application/adapters) | Template | 2h |
| HU-ENA-0-09-TPL-02 | Crear Dockerfile multi-stage (JRE 21 / Go) con healthchecks | Template | 1.5h |
| HU-ENA-0-09-TPL-03 | Crear stub openapi.yaml por servicio | Template | 1h |
| HU-ENA-0-09-TPL-04 | Cablear X-Ray SDK en template Java | Template | 1h |
| HU-ENA-0-09-TPL-05 | Cablear X-Ray SDK en template Go | Template | 1h |

#### Slice 2: Servicios Java (6)

| ID Tarea | Descripción | Capa | Estimación |
|----------|-------------|------|------------|
| HU-ENA-0-09-JAVA-01 | Crear scaffold identidad (OIDC/JWT) | Servicio | 1h |
| HU-ENA-0-09-JAVA-02 | Crear scaffold establecimiento | Servicio | 0.5h |
| HU-ENA-0-09-JAVA-03 | Crear scaffold personal | Servicio | 0.5h |
| HU-ENA-0-09-JAVA-04 | Crear scaffold reserva (Outbox) | Servicio | 1h |
| HU-ENA-0-09-JAVA-05 | Crear scaffold fidelizacion (Kafka idempotente) | Servicio | 0.5h |
| HU-ENA-0-09-JAVA-06 | Crear scaffold resena (Kafka idempotente) | Servicio | 0.5h |

#### Slice 3: Servicios Go (2)

| ID Tarea | Descripción | Capa | Estimación |
|----------|-------------|------|------------|
| HU-ENA-0-09-GO-01 | Crear scaffold notificacion (bridge Kafka→RabbitMQ) | Servicio | 1h |
| HU-ENA-0-09-GO-02 | Crear scaffold descubrimiento (CQRS read-model) | Servicio | 1h |

#### Slice 4: Validación

| ID Tarea | Descripción | Capa | Estimación |
|----------|-------------|------|------------|
| HU-ENA-0-09-VAL-01 | Verificar que los 8 servicios compilan y pasan CI | Test | 1h |
| HU-ENA-0-09-VAL-02 | Desplegar Spring + notificacion en dev y verificar /health | Test | 0.5h |
| HU-ENA-0-09-VAL-03 | Verificar trace X-Ray cruzado en los 2 desplegados | Test | 0.5h |

---

## 5. Estimación

### Desglose

| Factor | Valor | Justificación |
|--------|-------|---------------|
| Complejidad base | 8 SP | 8 servicios + templates + patrones |
| Incertidumbre | +3 SP | Patrones como Outbox/CQRS pueden variar |
| Riesgo | +2 SP | Validación de 8 servicios en CI |
| **Total SP** | **13 SP** | — |

### Estrategia Recomendada

- **Enfoque:** Template-driven (crear template → generar 8 servicios → validar CI)
- **Razón:** El template unifica estructura, los patrones son la variación

---

## 6. Riesgos y Dependencias

### Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| 8 servicios sobrecargan ECS en dev | Media | Medio | Solo desplegar 2 representativos |
| Patrones no son correctos desde el inicio | Baja | Alto | Usar stubs simples, refactorizar en S1+ |

### Dependencias

| Tipo | Referencia | Estado |
|------|------------|--------|
| HU previa | HU-ENA-0-03 (Pipeline CI/CD) | ⏳ Pendiente |
| HU previa | HU-ENA-0-04 (Monorepo + patrón) | ⏳ Pendiente |
| HU previa | HU-ENA-0-07 (Reglas arquitectónicas) | ✅ Completado |
| HU previa | HU-ENA-0-08 (Estándares ingeniería) | ✅ Completado |
| HU previa | HU-ENA-0-10 (Cobertura tests) | ⏳ Pendiente |

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

> **Archivo:** `artifacts/HU/HU-ENA-0-09/Refinamiento.md`
> **Creado por:** `refinar-hu`
