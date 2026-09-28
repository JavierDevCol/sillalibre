# HU-ENA-0-03: Pipeline Patrón CI/CD

## Metadatos

| Campo | Valor |
|-------|-------|
| **ID** | HU-ENA-0-03 |
| **Título** | Pipeline Patrón CI/CD |
| **Tipo** | Enabler |
| **Proyecto** | SillaLibre |
| **Prioridad** | P0 |
| **Complejidad** | 🔴 ALTO |
| **Story Points** | 13 SP |
| **Estimación** | 12-14 horas |
| **Fecha Creación** | 2026-09-12 |
| **Creado por** | Product Owner Agent |
| **Origen** | ADR-003 §CI/CD · Auditoría #4 🟠 |
| **Padre** | — |
| **Impl Proyecto** | — |
| **Estado** | [E] En Ejecución |

## Descripción

**Como** equipo de desarrollo,
**Quiero** tener un workflow reutilizable de CI/CD con OIDC, tests, build, Trivy y SBOM,
**Para** que cada servicio despliegue de forma segura y automatizada.

## Criterios de Aceptación

<!-- Los CAs se definen en Refinamiento.md como fuente de verdad -->

## Dependencias

| Tipo | Referencia | Estado |
|------|------------|--------|
| HU previa | HU-ENA-0-02 (Terraform) | ✅ Completado |
| Decisión | ADR-003 (CI/CD) | ✅ Aprobado |

## Notas

- OIDC: cero claves estáticas
- Trivy fail-gate: CRITICAL/HIGH bloquea merge
- SBOM generado como artifact
- Deploy rolling en ECS (prod con aprobación manual vía GitHub Environments / required reviewers)
- Rollback automático vía ECS deployment circuit breaker (health check falla)
- Pipeline objetivo ≤ 10 min con cache caliente (informativo, sin fail-gate)
- Build tool Java: Gradle (decisión Q2)

---

> **Archivo:** `artifacts/HU/HU-ENA-0-03/HU.md`
> **Creado por:** `refinar-hu`
