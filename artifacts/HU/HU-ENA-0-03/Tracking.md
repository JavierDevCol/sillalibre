# Tracking: HU-ENA-0-03 - Pipeline Patrón CI/CD

## Metadata

| Campo | Valor |
|-------|-------|
| **HU** | HU-ENA-0-03 |
| **Inicio** | 2026-09-28 |
| **Estado** | EN_PROGRESO |
| **Modo ejecución** | fase_por_fase |
| **Rama de trabajo** | hu-HU-ENA-0-03-pipeline-cicd |
| **Progreso** | 91% (10/11 tareas) — fases 1-5 completadas |
| **Sección actual** | 6/6 - Fase Final: Validación CA |
| **Última actualización** | 2026-09-29 |

---

## Historial de Ejecución

| Fecha | Tarea | Acción | Resultado | Duración |
|-------|-------|--------|-----------|----------|
| 2026-09-28 | — | Inicio de ejecución (modo fase_por_fase) | — | — |
| 2026-09-28 | EJEC-01..03 | Fase 1 completada | ✅ terraform validate + plan + apply OK en workspace dev (12 recursos: ECR patron, ECS cluster+service, rol OIDC) | 35min |
| 2026-09-28 | EJEC-04..06 | Fase 2 completada | ✅ service-ci.yml creado (workflow_call + dispatch, OIDC, caches Gradle/Go); YAML validado | 20min |
| 2026-09-28 | EJEC-07..08 | Fase 3 completada | ✅ job security: SBOM CycloneDX (artifact 90d, antes del gate) + Trivy fail-gate CRITICAL/HIGH | 15min |
| 2026-09-28 | EJEC-09..10 | Fase 4 completada | ✅ jobs deploy-dev (auto en main, environment dev) y deploy-prod (environment prod = approval gate); YAML validado | 20min |
| 2026-09-29 | EJEC-11 | Config GitHub + runner | ✅ vars/environments del repo, runner self-hosted `floci-runner` online, 5 corridas E2E | 90min |
| 2026-09-29 | EJEC-11 | Fase 5 completada | ✅ Run 4 verde total (CA-06/07), Runs 1-2 fail-gate real (CA-02), SBOM artifact (CA-03), Run 5 prod skipped; workspace `prod` aplicado | 45min |

---

## Errores Encontrados

| Fecha | Tarea | Error | Resolución |
|-------|-------|-------|------------|
| 2026-09-29 | EJEC-11 | `trivy-action@0.28.0` no existe (tags usan prefijo `v`) | Fijar `aquasecurity/trivy-action@v0.36.0` |
| 2026-09-29 | EJEC-11 | `CreateOpenIDConnectProvider` 409 — provider OIDC es **global de cuenta** | Var `create_oidc_provider` (true solo en dev); prod.tfvars=false |
| 2026-09-29 | EJEC-11 | `RepositoryAlreadyExistsException` — registro ECR es **global de cuenta** | `terraform import` del repo al estado `prod` |
| 2026-09-29 | EJEC-11 | deploy-prod falló: family `sillalibre-prod-patron` inexistente | Aplicar workspace `prod` completo en floci |
| 2026-09-29 | EJEC-11 | Drift permanente task-def: floci no persiste `healthCheck` | Documentado (limitación emulador); no aplicar TF tras deploy del pipeline |

---

## Métricas

| Métrica | Valor |
|---------|-------|
| Tiempo total | ~4h |
| Tareas completadas | 11/11 |
| Errores encontrados | 5 |
| Reintentos de corridas | 3 (Runs 1-3) |

---

## Finalización

| Campo | Valor |
|-------|-------|
| **Fin** | — |
| **Duración total** | — |
| **Commit final** | — |
| **Tests ejecutados** | — |
| **Tests pasaron** | — |
| **Cobertura** | — |

---

> **Archivo:** `artifacts/HU/HU-ENA-0-03/Tracking.md`
> **Creado por:** `>ejecutar_plan`
> **Actualizado por:** `>ejecutar_plan` (en tiempo real)
