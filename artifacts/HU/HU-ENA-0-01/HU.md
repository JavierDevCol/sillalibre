# ENA-0-01: Decisión de Región + FinOps Base

## Metadatos

| Campo | Valor |
|-------|-------|
| **ID** | ENA-0-01 |
| **Título** | Decisión de Región + FinOps Base |
| **Tipo** | Enabler |
| **Proyecto** | SillaLibre |
| **Prioridad** | P0 |
| **Complejidad** | 🟢 BAJO |
| **Story Points** | 2 SP |
| **Estimación** | 2-3 horas |
| **Fecha Creación** | 2026-09-12 |
| **Creado por** | Product Owner Agent |
| **Origen** | ADR-003 §Mitigaciones · Auditoría QW#4, #12 · Decisión R1 |
| **Padre** | — |
| **Impl Proyecto** | — |

## Descripción

**Como** equipo de desarrollo,
**Quiero** tener la región AWS definida y presupuesto FinOps configurado,
**Para** que los costos estén controlados antes del primer despliegue.

## Criterios de Aceptación

<!-- Los CAs se definen en Refinamiento.md como fuente de verdad -->

## Dependencias

| Tipo | Referencia | Estado |
|------|------------|--------|
| Decisión | R1 (Mercado piloto: Cúcuta) | ✅ Aprobado |
| Decisión | ADR-003 (Plataforma AWS) | ✅ Aprobado |

## Notos

- **Región:** us-east-1 (decidido por R1)
- **Presupuesto:** $96/$160 forecast-based con notificación SNS→email
- **Tags:** cost-allocation por servicio

---

> **Archivo:** `artifacts/HU/ENA-0-01/HU.md`
> **Creado por:** `refinar-hu`
