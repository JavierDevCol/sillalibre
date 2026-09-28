# HU-ENA-0-04: Monorepo + Servicio Patrón Observado

## Metadatos

| Campo | Valor |
|-------|-------|
| **ID** | HU-ENA-0-04 |
| **Título** | Monorepo + Servicio Patrón Observado |
| **Tipo** | Enabler |
| **Proyecto** | SillaLibre |
| **Prioridad** | P0 |
| **Complejidad** | 🟡 MEDIO |
| **Story Points** | 8 SP |
| **Estimación** | 8-10 horas |
| **Fecha Creación** | 2026-09-12 |
| **Creado por** | Product Owner Agent |
| **Origen** | ADR-002 · Auditoría #2, #5, #8 🔴🟠 |
| **Padre** | — |
| **Impl Proyecto** | — |
| **Estado** | [R] Refinada |

## Descripción

**Como** equipo de desarrollo,
**Quiero** tener un monorepo con estructura carpeta-por-servicio y un servicio patrón Spring Boot observado,
**Para** que la trazabilidad X-Ray cruce API Gateway → servicio → RDS.

## Criterios de Aceptación

<!-- Los CAs se definen en Refinamiento.md como fuente de verdad -->

## Dependencias

| Tipo | Referencia | Estado |
|------|------------|--------|
| HU previa | HU-ENA-0-03 (Pipeline CI/CD) | ⏳ Pendiente |
| Decisión | ADR-002 (Stack Poliglota) | ✅ Aprobado |

## Notas

- Servicio patrón: Spring Boot 0.5 vCPU / 1GB
- `-XX:MaxRAMPercentage=75`, pool HikariCP ≤6
- Logs JSON estructurados, retención 30d dev / 90d prod
- X-Ray SDK cableado, sampling rules configuradas

---

> **Archivo:** `artifacts/HU/HU-ENA-0-04/HU.md`
> **Creado por:** `refinar-hu`
