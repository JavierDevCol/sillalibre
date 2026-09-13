# HU-ENA-0-05: Entorno Local Reproducible

## Metadatos

| Campo | Valor |
|-------|-------|
| **ID** | HU-ENA-0-05 |
| **Título** | Entorno Local Reproducible |
| **Tipo** | Enabler |
| **Proyecto** | SillaLibre |
| **Prioridad** | P0 |
| **Complejidad** | 🟡 MEDIO |
| **Story Points** | 5 SP |
| **Estimación** | 5-7 horas |
| **Fecha Creación** | 2026-09-12 |
| **Creado por** | Product Owner Agent |
| **Origen** | `arquitectura_aws` §4 · ADR-001 F0 · ADR-008 |
| **Padre** | — |
| **Impl Proyecto** | — |

## Descripción

**Como** desarrollador nuevo,
**Quiero** levantar el entorno local con docker-compose y ejecutar un flujo en <1 día,
**Para** que la curva de onboarding sea mínima.

## Criterios de Aceptación

<!-- Los CAs se definen en Refinamiento.md como fuente de verdad -->

## Dependencias

| Tipo | Referencia | Estado |
|------|------------|--------|
| HU previa | HU-ENA-0-02 (Terraform/docker-compose) | ⏳ Pendiente |

## Notas

- PostgreSQL con BDs lógicas por servicio
- Kafka KRaft (event streaming)
- RabbitMQ management (task queues)
- Kafka UI para inspección
- Regla: "lo que corre en local corre igual en AWS"

---

> **Archivo:** `artifacts/HU/HU-ENA-0-05/HU.md`
> **Creado por:** `refinar-hu`
