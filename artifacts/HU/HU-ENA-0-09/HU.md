# HU-ENA-0-09: Scaffold Base de los 8 Microservicios

## Metadatos

| Campo | Valor |
|-------|-------|
| **ID** | HU-ENA-0-09 |
| **Título** | Scaffold Base de los 8 Microservicios |
| **Tipo** | Enabler |
| **Proyecto** | SillaLibre |
| **Prioridad** | P0 |
| **Complejidad** | 🔴 ALTO |
| **Story Points** | 13 SP |
| **Estimación** | 12-16 horas |
| **Fecha Creación** | 2026-09-12 |
| **Creado por** | Product Owner Agent |
| **Origen** | ADR-001 F0 · ADR-008 · Solicitado por PO |
| **Padre** | — |
| **Impl Proyecto** | — |
| **Estado** | [R] Refinada |

## Descripción

**Como** equipo de desarrollo,
**Quiero** tener esqueletos template-driven para los 8 microservicios con estructura hexagonal,
**Para** que cada servicio esté listo para implementar lógica de negocio desde el día 1.

## Criterios de Aceptación

<!-- Los CAs se definen en Refinamiento.md como fuente de verdad -->

## Dependencias

| Tipo | Referencia | Estado |
|------|------------|--------|
| HU previa | HU-ENA-0-03 (Pipeline CI/CD) | ⏳ Pendiente |
| HU previa | HU-ENA-0-04 (Monorepo + patrón) | ⏳ Pendiente |
| HU previa | HU-ENA-0-07 (Reglas arquitectónicas) | ✅ Completado |
| HU previa | HU-ENA-0-08 (Estándares ingeniería) | ✅ Completado |
| HU previa | HU-ENA-0-10 (Cobertura tests) | ⏳ Pendiente |

## Notos

- **Muestreo por representatividad:** Spring + notificacion (Go) despliegan E2E
- Los 6 restantes compilan y pasan CI
- Patrones: Outbox (reserva), CQRS (descubrimiento), Kafka idempotente (fidelizacion, resena), bridge Kafka→RabbitMQ (notificacion), OIDC/JWT (identidad)
- Dockerfile multi-stage, healthchecks, logs JSON, X-Ray SDK, stub OpenAPI

---

> **Archivo:** `artifacts/HU/HU-ENA-0-09/HU.md`
> **Creado por:** `refinar-hu`
