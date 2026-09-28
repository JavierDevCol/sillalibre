# HU-ENA-0-03: Pipeline Patrón CI/CD

## Metadatos

| Campo | Valor |
|-------|-------|
| **ID** | HU-ENA-0-03 |
| **Título** | Pipeline Patrón CI/CD |
| **Tipo** | Enabler |
| **Proyecto** | SillaLibre |
| **Prioridad** | P0 |
| **Complejidad** | 🟡 MEDIO |
| **Story Points** | 8 SP |
| **Estimación** | 8-10 horas |
| **Fecha Creación** | 2026-09-12 |
| **Creado por** | Product Owner Agent |
| **Origen** | ADR-003 §CI/CD · Auditoría #4 🟠 |
| **Padre** | — |
| **Impl Proyecto** | — |
| **Estado** | [R] Refinada |

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
- Deploy rolling en ECS (prod con aprobación manual)

---

> **Archivo:** `artifacts/HU/HU-ENA-0-03/HU.md`
> **Creado por:** `refinar-hu`
