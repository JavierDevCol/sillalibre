# Refinamiento: HU-ENA-0-04 - Monorepo + Servicio Patrón Observado

## Metadata

| Campo | Valor |
|-------|-------|
| **ID** | HU-ENA-0-04 |
| **Título** | Monorepo + Servicio Patrón Observado |
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
**Quiero** tener un monorepo con estructura carpeta-por-servicio y un servicio patrón observado,
**Para** que la trazabilidad X-Ray cruce API Gateway → servicio → RDS.

---

## 2. Criterios de Aceptación

- [ ] **CA-01:** Dado que reviso la estructura del monorepo, cuando la inspecciono, entonces existe: `services/<nombre-servicio>/` con estructura hexagonal (domain/application/adapters)
- [ ] **CA-02:** Dado que el servicio patrón es Spring Boot, cuando reviso su configuración, entonces tiene: 0.5 vCPU / 1GB, `-XX:MaxRAMPercentage=75`, pool HikariCP ≤6
- [ ] **CA-03:** Dado que el servicio está desplegado, cuando envío una petición a través de API Gateway, entonces X-Ray muestra el trace completo: API Gateway → servicio → RDS
- [ ] **CA-04:** Dado que reviso los logs, cuando inspecciono el formato, entonces son JSON estructurados con timestamp, level, service, trace_id
- [ ] **CA-05:** Dado que configuro retención de logs, cuando verifico CloudWatch, entonces es 30 días en dev y 90 días en prod
- [ ] **CA-06:** Dado que configuro X-Ray sampling, cuando reviso las rules, entonces hay sampling rate configurable por endpoint

---

## 3. Preguntas de Clarificación

### Resueltas ✅

| # | Pregunta | Respuesta | Impacto |
|---|----------|-----------|---------|
| 1 | ¿Qué framework usa el servicio patrón? | Spring Boot (Java 21) | Alto |
| 2 | ¿Pool HikariCP máximo? | ≤6 conexiones (right-sizing) | Medio |

### Pendientes ❓

| # | Pregunta | Prioridad |
|---|----------|-----------|
| 1 | ¿Usamos Structured Logging con Logstash encoder? | Media |

---

## 4. Desglose Técnico (Vertical)

### MODO PLANO

#### Slice 1: Estructura Monorepo

| ID Tarea | Descripción | Capa | Estimación |
|----------|-------------|------|------------|
| HU-ENA-0-04-MONO-01 | Crear estructura `services/<patron>/` con hexagonal (domain/application/adapters) | Estructura | 1.5h |
| HU-ENA-0-04-MONO-02 | Crear `Dockerfile` multi-stage (JRE 21) con healthchecks | Container | 1h |

#### Slice 2: Servicio Patrón Spring Boot

| ID Tarea | Descripción | Capa | Estimación |
|----------|-------------|------|------------|
| HU-ENA-0-04-SVC-01 | Configurar Spring Boot con right-sizing (0.5 vCPU / 1GB) | Servicio | 2h |
| HU-ENA-0-04-SVC-02 | Configurar HikariCP pool ≤6 + connection timeout | Servicio | 1h |
| HU-ENA-0-04-SVC-03 | Configurar logs JSON estructurados (Logstash encoder) | Servicio | 1h |

#### Slice 3: Observabilidad

| ID Tarea | Descripción | Capa | Estimación |
|----------|-------------|------|------------|
| HU-ENA-0-04-OBS-01 | Integrar X-Ray SDK en Spring Boot | Observabilidad | 1.5h |
| HU-ENA-0-04-OBS-02 | Configurar sampling rules X-Ray por endpoint | Observabilidad | 0.5h |
| HU-ENA-0-04-OBS-03 | Configurar retención logs CloudWatch (30d/90d) | Observabilidad | 0.5h |

---

## 5. Estimación

### Desglose

| Factor | Valor | Justificación |
|--------|-------|---------------|
| Complejidad base | 5 SP | Spring Boot + X-Ray + estructura hexagonal |
| Incertidumbre | +2 SP | X-Ray puede requerir tuning |
| Riesgo | +1 SP | Right-sizing necesita validación en ECS |
| **Total SP** | **8 SP** | — |

### Estrategia Recomendada

- **Enfoque:** Incremental (estructura → servicio → observabilidad)
- **Razón:** Cada slice es validable con el pipeline de HU-ENA-0-03

---

## 6. Riesgos y Dependencias

### Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| X-Ray sampling genera overhead | Baja | Medio | Sampling rate bajo en dev |
| HikariCP pool insuficiente | Baja | Alto | Monitorear en ECS, ajustar si es necesario |

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

> **Archivo:** `artifacts/HU/HU-ENA-0-04/Refinamiento.md`
> **Creado por:** `refinar-hu`
