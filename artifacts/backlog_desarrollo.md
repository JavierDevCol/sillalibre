# 📇 Backlog de Desarrollo — SillaLibre (app-barber)

| Campo | Valor |
|-------|-------|
| **Proyecto** | SillaLibre *(codename técnico: app-barber)* |
| **Fecha creación** | 2026-09-28 |
| **Versión** | 1.0 |
| **Estado** | ✅ Vigente — índice operativo de HUs/enablers; fuente de verdad = artefactos `artifacts/HU/<id>/` |
| **Roadmap maestro** | [`backlog_roadmap.md`](backlog_roadmap.md) (épicas, decisiones, calendario) |
| **Regla** | Los estados de esta tabla se deducen de `Plan.md` / `Refinamiento.md` — nunca al revés (`sincronizar-backlog`) |

> **Leyenda de estados:** `[ ]` Pendiente · `[R]` Refinada · `[A]` Aprobada · `[P]` Planificada · `[E]` En Ejecución · `[X]` Completada · `[B]` Bloqueada

---

## 📇 Índice Rápido

| ID | Título | Estado | Prioridad | Tipo | Proyecto | Tasks |
|----|--------|--------|-----------|------|----------|-------|
| **🔧 EN COURSE (En Ejecución)** |
| *(sin HUs en ejecución)* | | | | | | |
| **🆕 NEW (Pendientes / Refinadas / Aprobadas)** |
| ENA-0-10 | Métricas de Cobertura de Tests | [ ] Pendiente | P1 | Enabler | SillaLibre | 0 |
| ENA-0-03 | Pipeline Patrón CI/CD | [P] Planificada | P0 | Enabler | SillaLibre | 10 |
| ENA-0-04 | Monorepo + Servicio Patrón Observado | [R] Refinada | P0 | Enabler | SillaLibre | 8 |
| ENA-0-05 | Entorno Local Reproducible | [R] Refinada | P0 | Enabler | SillaLibre | 6 |
| ENA-0-06 | Contratos OpenAPI desde el Día 1 | [R] Refinada | P1 | Enabler | SillaLibre | 4 |
| ENA-0-07 | Reglas Arquitectónicas del Proyecto | [R] Refinada | P0 | Enabler | SillaLibre | 8 |
| ENA-0-08 | Estándares de Ingeniería y Convenciones | [R] Refinada | P0 | Enabler | SillaLibre | 7 |
| ENA-0-09 | Scaffold Base de los 8 Microservicios | [R] Refinada | P0 | Enabler | SillaLibre | 16 |
| ENA-0-11 | Spike Cumplimiento Ley 1581 de 2012 | [R] Refinada | P0 | Enabler | SillaLibre | 10 |
| **✅ CLOSED (Completadas)** |
| ENA-0-01 | Decisión de Región + FinOps Base | [X] Completada | P0 | Enabler | SillaLibre | 4 |
| ENA-0-02 | Terraform Base Endurecido | [X] Completada | P0 | Enabler | SillaLibre | 11 |

---

## Notas

- **Tasks** = tareas desglosadas en `Refinamiento.md` (ENA-0-10 aún sin refinamiento → 0).
- **HUs de negocio** (identidad-01/02, E1-01…, E8-01) están en nivel épic en [`backlog_roadmap.md`](backlog_roadmap.md) §4 — entran aquí cuando se ejecuten `refinar_hu`.
- **Sincronización:** ejecutar `sincronizar-backlog` tras cada cambio de estado en artefactos.
- **Issues GitHub:** 1 issue por HU, sincronizadas vía `scripts/sync_hu_issues.sh`; cierre solo con `Closes #N` en PR (decisión R5).

> **Archivo:** `artifacts/backlog_desarrollo.md`
