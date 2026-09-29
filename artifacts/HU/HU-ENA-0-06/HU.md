# HU-ENA-0-06: Contratos OpenAPI desde el Día 1

## Metadatos

| Campo | Valor |
|-------|-------|
| **ID** | HU-ENA-0-06 |
| **Título** | Contratos OpenAPI desde el Día 1 |
| **Tipo** | Enabler |
| **Sprint** | S0-B |
| **Proyecto** | SillaLibre |
| **Prioridad** | P1 |
| **Complejidad** | 🟢 BAJO |
| **Story Points** | 3 SP |
| **Estimación** | 3-4 horas |
| **Fecha Creación** | 2026-09-12 |
| **Creado por** | Product Owner Agent |
| **Origen** | ADR-002 §Validación · Auditoría #10 |
| **Padre** | — |
| **Impl Proyecto** | — |
| **Estado** | [R] Refinada |

## Descripción

**Como** equipo de desarrollo,
**Quiero** tener specs OpenAPI 3 versionadas por servicio con lint y chequeo de backward-compat,
**Para** que el pipeline rechace cambios rompientes sin bump de versión mayor.

## Criterios de Aceptación

<!-- Los CAs se definen en Refinamiento.md como fuente de verdad -->

## Dependencias

| Tipo | Referencia | Estado |
|------|------------|--------|
| HU previa | HU-ENA-0-03 (Pipeline CI/CD) | ⏳ Pendiente |
| Decisión | ADR-002 | ✅ Aprobado |

## Notas

- Spec OpenAPI 3 versionada por servicio
- Spectral lint integrado al pipeline
- Chequeo backward-compat: breaking change = fail

---

> **Archivo:** `artifacts/HU/HU-ENA-0-06/HU.md`
> **Creado por:** `refinar-hu`
