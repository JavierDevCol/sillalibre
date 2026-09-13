# HU-ENA-0-10: Métricas de Cobertura de Tests

## Metadatos

| Campo | Valor |
|-------|-------|
| **ID** | HU-ENA-0-10 |
| **Título** | Métricas de Cobertura de Tests |
| **Tipo** | Enabler |
| **Proyecto** | SillaLibre |
| **Prioridad** | P1 |
| **Complejidad** | 🟡 MEDIO |
| **Story Points** | 5 SP |
| **Estimación** | 4-6 horas |
| **Fecha Creación** | 2026-09-12 |
| **Creado por** | Product Owner Agent |
| **Origen** | Blueprint §6 Gap #7 · Visión §15.5 |
| **Padre** | — |
| **Impl Proyecto** | — |

## Descripción

**Como** equipo de desarrollo,
**Quiero** tener métricas de cobertura de tests integradas al pipeline CI,
**Para** que el fail-gate ≥80% proteja la calidad de la lógica de negocio.

## Criterios de Aceptación

<!-- Los CAs se definen en Refinamiento.md como fuente de verdad -->

## Dependencias

| Tipo | Referencia | Estado |
|------|------------|--------|
| HU previa | HU-ENA-0-03 (Pipeline CI/CD) | ⏳ Pendiente |
| HU futura | HU-ENA-0-09 (Scaffold) | ⏳ Pendiente |

## Notas

- JaCoCo para servicios Java, cobertura nativa para Go
- Fail-gate: PR rechazado si cobertura < 80% en lógica de negocio
- Cobertura medida solo sobre `domain/` y `application/` (no adapters/infra)

---

> **Archivo:** `artifacts/HU/HU-ENA-0-10/HU.md`
> **Creado por:** `refinar-hu`
