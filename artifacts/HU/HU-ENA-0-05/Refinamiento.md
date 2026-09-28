# Refinamiento: HU-ENA-0-05 - Entorno Local Reproducible

## Metadata

| Campo | Valor |
|-------|-------|
| **ID** | HU-ENA-0-05 |
| **Título** | Entorno Local Reproducible |
| **Complejidad** | 🟡 MEDIO |
| **Story Points** | 5 SP |
| **Estimación Horas** | 5-7 horas |
| **Fecha refinamiento** | 2026-09-12 |
| **Iteración** | 1 |
| **Modo** | Plano |
| **Tasks** | — |

---

## 1. Historia de Usuario

**Como** desarrollador nuevo,
**Quiero** levantar el entorno local con docker-compose y ejecutar un flujo en <1 día,
**Para** que la curva de onboarding sea mínima.

---

## 2. Criterios de Aceptación

- [ ] **CA-01:** Dado que ejecuto `docker compose up`, cuando verifico los servicios, entonces corren: PostgreSQL, Kafka KRaft, RabbitMQ management, Kafka UI
- [ ] **CA-02:** Dado que PostgreSQL está corriendo, cuando reviso las bases de datos, entonces existen BDs lógicas separadas por servicio (identidad, reserva, etc.)
- [ ] **CA-03:** Dado que Kafka está corriendo, cuando verifico KRaft, entonces funciona sin ZooKeeper (modo KRaft)
- [ ] **CA-04:** Dado que RabbitMQ está corriendo, cuando accedo a management UI, entonces puedo ver colas y exchanges
- [ ] **CA-05:** Dado que Kafka UI está corriendo, cuando accedo a localhost:8080, entonces puedo inspeccionar topics y mensajes
- [ ] **CA-06:** Dado que soy desarrollador nuevo, cuando sigo el README, entonces levanto el entorno y ejecuto un flujo en <1 día

---

## 3. Preguntas de Clarificación

### Resueltas ✅

| # | Pregunta | Respuesta | Impacto |
|---|----------|-----------|---------|
| 1 | ¿Kafka con ZooKeeper o KRaft? | KRaft (sin dependencia) | Alto |
| 2 | ¿RabbitMQ con management UI? | Sí, para debugging | Bajo |

### Pendientes ❓

| # | Pregunta | Prioridad |
|---|----------|-----------|
| 1 | ¿Usamos docker compose profiles para servicios opcionales? | Baja |

---

## 4. Desglose Técnico (Vertical)

### MODO PLANO

#### Slice 1: docker-compose core

| ID Tarea | Descripción | Capa | Estimación |
|----------|-------------|------|------------|
| HU-ENA-0-05-DC-01 | Crear `docker-compose.yml` con PostgreSQL 17 | Infra | 1h |
| HU-ENA-0-05-DC-02 | Agregar Kafka KRaft (sin ZooKeeper) | Infra | 1.5h |
| HU-ENA-0-05-DC-03 | Agregar RabbitMQ management | Infra | 0.5h |
| HU-ENA-0-05-DC-04 | Agregar Kafka UI | Infra | 0.5h |

#### Slice 2: Inicialización

| ID Tarea | Descripción | Capa | Estimación |
|----------|-------------|------|------------|
| HU-ENA-0-05-INIT-01 | Crear script de inicialización de BDs lógicas por servicio | Script | 1h |
| HU-ENA-0-05-INIT-02 | Documentar README con instrucciones de onboarding | Documentación | 0.5h |

---

## 5. Estimación

### Desglose

| Factor | Valor | Justificación |
|--------|-------|---------------|
| Complejidad base | 3 SP | docker-compose con 4 servicios |
| Incertidumbre | +1 SP | KRaft puede requerir tuning |
| Riesgo | +1 SP | Compatibilidad de versiones |
| **Total SP** | **5 SP** | — |

### Estrategia Recomendada

- **Enfoque:** Incremental (PostgreSQL → Kafka → RabbitMQ → UI → Documentación)
- **Razón:** Cada servicio es validable independientemente

---

## 6. Riesgos y Dependencias

### Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| KRaft inestable en docker | Media | Medio | Usar versión LTS de Confluent |
| BDs lógicas causan conflictos | Baja | Bajo | Script de inicialización idempotente |

### Dependencias

| Tipo | Referencia | Estado |
|------|------------|--------|
| HU previa | HU-ENA-0-02 (Terraform/docker-compose) | ✅ Completado |

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

> **Archivo:** `artifacts/HU/HU-ENA-0-05/Refinamiento.md`
> **Creado por:** `refinar-hu`
